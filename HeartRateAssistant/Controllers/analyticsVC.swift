//
//  analyticsVC.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 23/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class analyticsVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var shareHeartContainer: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var firstDotLbl: UILabel!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var secondDotLbl: UILabel!
    @IBOutlet weak var plusBtn: UIButton!
    
    @IBOutlet weak var sysChart: LineChart!
    @IBOutlet weak var diaChart: LineChart!
    @IBOutlet weak var pulseChart: LineChart!
    
    
    
    var buttonArray: [UIButton] = []
    var count: Int = 0
    var myObject: [HeartRates] = []

    var sysObject: [PointEntry] = []
    var diaObject: [PointEntry] = []
    var pulseObject: [PointEntry] = []
    
    ///.... temp values
    var tempDay: String = ""
    var tempPulse: NSString = "0"
    var tempSys: NSString = "0"
    var tempDia: NSString = "0"
    
    let userID = UIDevice.current.identifierForVendor!.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIs()
        getData()
//
    }
    
    func setupUIs() {
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)//containerView.bounds.size
        
        //ShareBtn
        shareContainer.layer.cornerRadius = 15 // shareContainer.frame.height/2
        shareHeartContainer.layer.cornerRadius = 13 // shareHeartContainer.frame.height/2
//        shareBtn.layer.cornerRadius = 15
        
        
        
        //tabBar initialize
        buttonArray.append(firstBtn)
        buttonArray.append(secondBtn)
        for i in buttonArray {
            i.addTarget(self, action: #selector(tabIdxChanged(sender: )), for: .touchDown)
        }
        
        tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        tabBarView.layer.borderWidth = 1.0
        
        //plusBtn
        plusBtn.layer.cornerRadius = 7
        plusBtn.addTarget(self, action: #selector(plusBtnPressed), for: .touchUpInside)
        
        // chartView setting
        sysChart.isCurved = true
        diaChart.isCurved = true
        pulseChart.isCurved = true

    }
    
    @objc func tabIdxChanged(sender: UIButton) {
        initializeTabIcons()
        count = 0
        for i in buttonArray {
            if sender == i {
//                sender.setImage(onTabImgs[count], for: .normal)
                break
            }
            count += 1
        }
        
        if count == 0
        {
            firstLbl.textColor = UIColor.black
            secondLbl.textColor = UIColor.lightGray
            firstDotLbl.isHidden = false
            secondDotLbl.isHidden = true
            //to diary
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "DiaryVC")
            present(controller, animated: true, completion: nil)
        }
        else// if count == 1
        {
            firstLbl.textColor = UIColor.lightGray
            secondLbl.textColor = UIColor.black
            firstDotLbl.isHidden = true
            secondDotLbl.isHidden = false
            //to analytics
            
        }
    }
    
    func initializeTabIcons () {
//        firstBtn.setImage(offTabImgs[0], for: .normal)
//        secondBtn.setImage(offTabImgs[1], for: .normal)
        firstLbl.textColor = UIColor.lightGray
        secondLbl.textColor = UIColor.lightGray
        firstDotLbl.isHidden = true
        secondDotLbl.isHidden = true
    }
       
    
    @objc func plusBtnPressed() {
        fromDiary = false
        //to InputVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InputVC")
        present(controller, animated: true, completion: nil)
    }
    
    
    func average(input : [Int]) -> Int {
        var sum: Int = 0
        var count: Int = 0
        for i in input
        {
            count += 1
            sum += i
        }
        return Int(sum/count)
    }
    
    func getData() {
        showLoading()
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("post").order(by: "dateValue", descending: true).addSnapshotListener { [self] (snapshot, error) in
            stopLoading()
            
            if error != nil {
                showToast(message: error?.localizedDescription ?? "")
                print(error?.localizedDescription ?? "")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    myObject.removeAll()
                    for document in snapshot!.documents {
                        let documentID =  document.documentID
                        var object = HeartRates()
                        
                        object.documentID = documentID
                        if let postedDate = document.get("dateValue") as? String {
                            object.dateValue = postedDate
                        }
                        if let postSys = document.get("systolic") as? String{
                            object.systolic = postSys
                        }
                        if let postDia = document.get("diastolic") as? String{
                            object.diastolic = postDia
                        }
                        if let postPulse = document.get("pulse") as? String{
                            object.pulse = postPulse
                        }
                        if let postConditionIdx = document.get("conditionIdx") as? Int{
                            object.conditionIdx = postConditionIdx
                        }
                        if let postbpmIdx = document.get("bpmIdx") as? Int{
                            object.bpmIdx = postbpmIdx
                        }
                        if let uID = document.get("userID") as? String{
                            object.userId = uID
                        }
                        if object.userId == userID {
                            myObject.append(object)
                        }
                    }
                    //UI initialize
                    showInitialView()
                    MyClassify()
                }
            }
        }
    }

    func showInitialView() {
//        if myObject.count == 0 {
//            initialView.isHidden = false
//            scrollView.isHidden = true
//            popView.isHidden = true
//        }else {
//            initialView.isHidden = true
//            scrollView.isHidden = false
//            popView.isHidden = true
//        }
    }
   
    func MyClassify() {
        if myObject.count == 0 {return}
        sysObject.removeAll(); diaObject.removeAll(); pulseObject.removeAll()
        for i in myObject
        {
            let k : String = i.dateValue.components(separatedBy: "at")[0]
            tempSys = i.systolic as NSString
            tempDia = i.diastolic as NSString
            tempPulse = i.pulse as NSString
            tempDay = k.components(separatedBy: ",")[0].prefix(3) + " " + k.components(separatedBy: ",")[0].components(separatedBy: " ")[1]
            
            sysObject.append(PointEntry(value: Int(tempSys.intValue), label: tempDay))
            diaObject.append(PointEntry(value: Int(tempDia.intValue), label: tempDay))
            pulseObject.append(PointEntry(value: Int(tempPulse.intValue), label: tempDay))
        }
        
        pulseChart.dataEntries = pulseObject
        sysChart.dataEntries = sysObject
        diaChart.dataEntries = diaObject
    }

}

