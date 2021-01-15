//
//  DiaryVC.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 22/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import DatePickerDialog

class DiaryVC: UIViewController {

    @IBOutlet weak var tabBarView: UIView!
    
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var firstDotLbl: UILabel!
    
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var secondDotLbl: UILabel!
    
    @IBOutlet weak var plusBtn: UIButton!
    
    @IBOutlet weak var lastMeasureView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var bloodPressureLbl: UILabel!
    @IBOutlet weak var pulseLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var resultEmotiLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var mapLbl: UILabel!
    @IBOutlet weak var mapKeyContainer: UIView!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var keyImg: UIImageView!
    
    @IBOutlet weak var initialView: UIView!
        
    @IBOutlet weak var dataContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var periodContainer: UIView!
    @IBOutlet weak var periodLbl: UILabel!
    @IBOutlet weak var periodNoteContainer: UIView!
    @IBOutlet weak var periodBtn: UIButton!
    
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var shareHeartContainer: UIView!
    @IBOutlet weak var shareBtn: UIButton!
        
        
    let datePickerDialog = DatePickerDialog(
        textColor: .black,
        buttonColor: .black,
        font: UIFont.boldSystemFont(ofSize: 17),
        showCancelButton: true
    )
    
    var buttonArray: [UIButton] = []
    var count: Int = 0
    var myObject: [HeartRates] = []
    var filteredObject: [HeartRates] = []
    var tableObject:[HeartRates] = []
    var lastMeasurement = HeartRates()
        
    let period: Int = 7
    var endOfPeriod = Date()
    var dateArray: [String] = []
    
    var selectedHeartRates: [Int] = []
    var selectedDates: [String] = []

    let resultArray = ["💥", "🌤", "🌿", "👻"]
    let resultString = ["Hypertension 2", "Prehypertension", "Normal BP", "Low BP"]
    let containerColorArray = [#colorLiteral(red: 0.7517880722, green: 0.1749722764, blue: 0.1800241869, alpha: 1), #colorLiteral(red: 1, green: 0.4932053257, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)]
    let colorArray = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)]
    let statusArray = ["☕", "😴", "💪", "🛀", "🚴", "😊", "🚶", "😭"]
    
    var todayString = ""
    
    let userID = UIDevice.current.identifierForVendor!.uuidString
    
    var cellColor = UIColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIs()
        //read the saved records.
        getDataFromFirestore()

    }
    
    func setupUIs() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //ShareBtn
        shareContainer.layer.cornerRadius = 15 // shareContainer.frame.height/2
        shareHeartContainer.layer.cornerRadius = 13 // shareHeartContainer.frame.height/2
//        shareBtn.layer.cornerRadius = 15
        
        //... Initialize LastMeasurement
        lastMeasureView.layer.cornerRadius = 20
        lastMeasureView.backgroundColor = containerColorArray[2]
        //MapContainer
        mapContainer.layer.cornerRadius = 15
        mapKeyContainer.layer.cornerRadius = 13
        mapContainer.backgroundColor = colorArray[3]
        keyImg.tintColor = colorArray[3]
        //HeartImg
        heartImg.tintColor = colorArray[3]
        //StatusLbl
        statusLbl.layer.masksToBounds = true
        statusLbl.layer.cornerRadius = 7
        //resultEmoti
        resultEmotiLbl.layer.masksToBounds = true
        resultEmotiLbl.layer.cornerRadius = 7
                
        
        //periodLbl, Btn
        periodContainer.layer.cornerRadius = 15
        periodNoteContainer.layer.cornerRadius = 13

        
        /*
        periodLbl.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(datePicker))
        periodLbl.addGestureRecognizer(tap)
        */
        periodBtn.addTarget(self, action: #selector(datePicker), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(rightBtnPressed), for: .touchUpInside)
        leftBtn.addTarget(self, action: #selector(leftBtnPressed), for: .touchUpInside)
                        
        //tabBar initialize, Plus button
        buttonArray.append(firstBtn)
        buttonArray.append(secondBtn)
        for i in buttonArray {
            i.addTarget(self, action: #selector(tabIdxChanged(sender: )), for: .touchDown)
        }
        tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        tabBarView.layer.borderWidth = 1.0
        
        plusBtn.layer.cornerRadius = 7
        plusBtn.addTarget(self, action: #selector(plusBtnPressed), for: .touchUpInside)
      
        ///...
        todayString = getDate().components(separatedBy: "at")[0].components(separatedBy: ",")[0]
        print("Today is \(todayString)")
        
    }
    
    func showInitialView() {
        if myObject.count == 0 {
            initialView.isHidden = false
            
        }else {
            initialView.isHidden = true
            
        }
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
            //to diary
            firstLbl.textColor = UIColor.black
            secondLbl.textColor = UIColor.lightGray
            firstDotLbl.isHidden = false
            secondDotLbl.isHidden = true
        }
        else// if count == 1
        {
            firstLbl.textColor = UIColor.lightGray
            secondLbl.textColor = UIColor.black
            firstDotLbl.isHidden = true
            secondDotLbl.isHidden = false
            //to analytics
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "analyticsVC")
            present(controller, animated: true, completion: nil)
            
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
        fromDiary = true
        //to InputVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InputVC")
        present(controller, animated: true, completion: nil)
    }
    
    func setValuesToWidget() {
        if myObject.count == 0 {
            dateLbl.text = "Today"
            timeLbl.text = getDate().components(separatedBy: "at")[1]
            resultLbl.text = "No Measurements"
            resultEmotiLbl.text = "👨🏼‍🦳"
        }
        else
        {
            let k: [String] = myObject[0].dateValue.components(separatedBy: "at")
            let kk: String = k[0].components(separatedBy: ",")[0]
            print("dddddddddd:   \(kk)")
            if kk == todayString
            {
                dateLbl.text = "Today"
            }
            else
            {
                dateLbl.text = k[0].components(separatedBy: ",")[0]
            }
            timeLbl.text = k[1]
            bloodPressureLbl.text = myObject[0].systolic + "/" + myObject[0].diastolic
            pulseLbl.text = myObject[0].pulse
            
            let tempIdx = myObject[0].bpmIdx
            resultEmotiLbl.layer.masksToBounds = true
            resultEmotiLbl.layer.cornerRadius = 7
            resultEmotiLbl.text = resultArray[tempIdx]
            resultLbl.text = resultString[tempIdx]
            statusLbl.text = statusArray[tempIdx]
            statusLbl.layer.masksToBounds = true
            statusLbl.layer.cornerRadius = 7
            heartImg.tintColor = colorArray[tempIdx]
            mapContainer.backgroundColor = colorArray[tempIdx]
            mapContainer.layer.cornerRadius = 15
            keyImg.tintColor = colorArray[tempIdx]
            mapKeyContainer.layer.cornerRadius = 13
        }
        
        tableView.reloadData()
        
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
    
    @objc func datePicker() {
        let fromDate = Calendar.current.date(byAdding: .year, value: -50, to: Date())
        let toDate = Calendar.current.date(byAdding: .year, value: 50, to: Date())
//        let datePicker = PopupDatePicker.init(currentDate: Date(), minLimitDate: nil, maxLimitDate: Date(), dpShowType: "yyyy-MM-dd", wildcardArray: nil, wildcardDefaults: nil) {(success, error) in
//            endOfPeriod = success
////            PopupDatePicker.selec
//        }
//        datePicker.show()
        datePickerDialog.show("End of Period",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        defaultDate: Date(),
                        minimumDate: fromDate, maximumDate: toDate,
                        datePickerMode: .date) { [self] (selectedEndDate) in
                            if selectedEndDate != nil {
                                endOfPeriod = selectedEndDate!
                            }
                            myFilter()
        }

        
    }
    
    @objc func rightBtnPressed() {
        for i in 1..<period {
            endOfPeriod = Calendar.current.date(byAdding: .day, value: 1, to: endOfPeriod)!
        }
        myFilter()
    }
    
    @objc func leftBtnPressed() {
        for i in 1..<period {
            endOfPeriod = Calendar.current.date(byAdding: .day, value: -1, to: endOfPeriod)!
        }
        myFilter()
    }

    // if possible, get data from firebase.
    func getDataFromFirestore() {
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
                    myFilter()
                }
            }
        }
    }
    
    func myFilter() {
        //make dateArray from 7,14,21
//        filteredObject.removeAll()
        tableObject.removeAll()
        dateArray.removeAll()
        var today = endOfPeriod
        
        dateArray.append(dateConvert(input: today))
        for i in 1..<period {
            today = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            dateArray.append(dateConvert(input: today))
        }
        /// MMMM DD -> MMM DD
        let startDay = dateArray[6].components(separatedBy: " ")[0].prefix(3) + " " + dateArray[6].components(separatedBy: " ")[1]
        let endDay = dateArray[0].components(separatedBy: " ")[0].prefix(3) + " " + dateArray[0].components(separatedBy: " ")[1]
        periodLbl.text = startDay + " - " + endDay
        
        var count = 0
        for i in myObject {
            let dateKey: String = i.dateValue.components(separatedBy: "at")[0].components(separatedBy: ",")[0]
            print(dateKey)
            if dateArray.contains(dateKey)
            {
//                filteredObject.append(i)
                if count == 0 {count += 1; continue}
                if dateArray.contains(dateKey) {tableObject.append(i)}
            }
            
        }
        setValuesToWidget()
    }
}

extension DiaryVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("recordingCell", owner: self, options: nil)?.first as! recordingCell
        cell.cellContainer.layer.cornerRadius = 20.0
        cell.cellContainer.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.cellContainer.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.cellContainer.layer.shadowOpacity = 0.8
                
        let k: [String] = tableObject[indexPath.row].dateValue.components(separatedBy: "at")
        let kk: String = k[0].components(separatedBy: ",")[0]
        if kk == todayString
        {
            cell.dateLbl.text = "Today"
        }
        else
        {
            cell.dateLbl.text = k[0].components(separatedBy: ",")[0]
        }
        cell.timeLbl.text = k[1]
        
        cell.bloodPressureLbl.text = tableObject[indexPath.row].systolic + "/" + tableObject[indexPath.row].diastolic
        cell.pulseLbl.text = tableObject[indexPath.row].pulse
        
        let tempIdx: Int = tableObject[indexPath.row].bpmIdx
        cell.resultEmotiLbl.layer.masksToBounds = true
        cell.resultEmotiLbl.layer.cornerRadius = 7
        cell.resultEmotiLbl.text = resultArray[tempIdx]
        cell.resultLbl.text = resultString[tempIdx]
        cell.statusLbl.text = statusArray[tempIdx]
        cell.statusLbl.layer.masksToBounds = true
        cell.statusLbl.layer.cornerRadius = 7
        cell.statusImg.tintColor = colorArray[tempIdx]
        cell.mapContainer.backgroundColor = colorArray[tempIdx]
        cell.mapContainer.layer.cornerRadius = 15
        cell.keyImg.tintColor = colorArray[tempIdx]
        cell.keyContainer.layer.cornerRadius = 13
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



