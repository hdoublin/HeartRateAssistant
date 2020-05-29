//
//  SaveVC.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 23/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class SaveVC: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var heartRateLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var estimateLbl: UILabel!
    
    @IBOutlet weak var workupLbl: UILabel!
    @IBOutlet weak var wokeupLabel: UILabel!
    
    @IBOutlet weak var beforebedLbl: UILabel!
    @IBOutlet weak var beforebedLabel: UILabel!
    
    @IBOutlet weak var workoutLbl: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    
    @IBOutlet weak var restingLbl: UILabel!
    @IBOutlet weak var restingLabel: UILabel!
    
    @IBOutlet weak var cardioLbl: UILabel!
    @IBOutlet weak var cardioLabel: UILabel!
    
    @IBOutlet weak var happyLbl: UILabel!
    @IBOutlet weak var happyLabel: UILabel!
    
    @IBOutlet weak var walkLbl: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    
    @IBOutlet weak var stressLbl: UILabel!
    @IBOutlet weak var stressLabel: UILabel!
    
    @IBOutlet weak var wokeupBtn: UIButton!
    @IBOutlet weak var beforebedBtn: UIButton!
    @IBOutlet weak var workoutBtn: UIButton!
    @IBOutlet weak var restingBtn: UIButton!
    @IBOutlet weak var cardioBtn: UIButton!
    @IBOutlet weak var happyBtn: UIButton!
    @IBOutlet weak var walkBtn: UIButton!
    @IBOutlet weak var stressBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var buttonArray: [UIButton] = []
    var lblArray: [UILabel] = []
    var labelArray:  [UILabel] = []
    let selectedBackgroundColor: UIColor = UIColor.lightGray
    var count : Int = 0
    
    let colorArray: [UIColor] = [ #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3960784314, blue: 0.3176470588, alpha: 1)]
    let userID = UIDevice.current.identifierForVendor!.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonArray.append(wokeupBtn)
        self.buttonArray.append(beforebedBtn)
        self.buttonArray.append(workoutBtn)
        self.buttonArray.append(restingBtn)
        self.buttonArray.append(cardioBtn)
        self.buttonArray.append(happyBtn)
        self.buttonArray.append(walkBtn)
        self.buttonArray.append(stressBtn)
        for i in buttonArray {
            i.addTarget(self, action: #selector(conditionChanged(sender:)), for: .touchUpInside)
        }

        self.lblArray.append(workupLbl)
        self.lblArray.append(beforebedLbl)
        self.lblArray.append(workoutLbl)
        self.lblArray.append(restingLbl)
        self.lblArray.append(cardioLbl)
        self.lblArray.append(happyLbl)
        self.lblArray.append(walkLbl)
        self.lblArray.append(stressLbl)
        
        self.labelArray.append(wokeupLabel)
        self.labelArray.append(beforebedLabel)
        self.labelArray.append(workoutLabel)
        self.labelArray.append(restingLabel)
        self.labelArray.append(cardioLabel)
        self.labelArray.append(happyLabel)
        self.labelArray.append(walkLabel)
        self.labelArray.append(stressLabel)
        self.initializeButtons()
        self.getData()

    }
    
    func initializeButtons() {
        for i in 0..<8 {
            self.initialLbl(input: self.lblArray[i])
            self.initialLabel(input: self.labelArray[i])
        }
    }
    
    func initialLbl(input: UILabel){
        input.layer.masksToBounds = true
        input.layer.cornerRadius = 10
        input.layer.borderColor = selectedBackgroundColor.withAlphaComponent(0.5).cgColor
        input.backgroundColor = .clear
    }
    
    func initialLabel(input: UILabel){
        input.textColor = .lightGray
    }
    
    @objc func conditionChanged(sender: UIButton) {
        count = 0
        for i in self.buttonArray {
            if sender == i {
                conditionIdx = count
                break
            }
            count += 1
        }
        self.initializeButtons()
        self.lblArray[count].backgroundColor = self.selectedBackgroundColor.withAlphaComponent(0.5)
        self.labelArray[count].textColor = .black

    }
    
    
    func getData() {
        let k : [String] = dateValue.components(separatedBy: "at")
        self.dateLbl.text = k[0].components(separatedBy: ",")[0]
        self.timeLbl.text = k[1]
        self.heartRateLbl.text = heartRate.components(separatedBy: "bpm")[0]
        let kk = (heartRate as NSString).doubleValue
        if kk <= 69
        {
            bpmIdx = 0// low pulse
            self.estimateLbl.text = "Low pulse"
        }
        else if (kk > 69) && (kk <= 120)
        {
            bpmIdx = 1// normal pulse
            self.estimateLbl.text = "Normal pulse"
        }
        else
        {
            bpmIdx = 2// high pulse
            self.estimateLbl.text = "High pulse"
        }
        
         self.heartImg.tintColor = self.colorArray[bpmIdx]
         self.estimateLbl.textColor = self.colorArray[bpmIdx]
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if !self.myValidate() {return}
        // if possible, we can save the date to Firebase.
        self.saveDataTo()
    }
    
    func saveDataTo() {
        var fireReference : DocumentReference? = nil
        let fireData = Firestore.firestore()
        let firePost = ["dateValue": dateValue,
                        "heartRate": heartRate,
                        "conditionIdx": conditionIdx,
                        "bpmIdx": bpmIdx,
                        "userID": userID
            ] as [String : Any]
        self.showLoading()
        fireReference = fireData.collection("post").addDocument(data: firePost, completion: { (error) in
            self.stopLoading()
            if error != nil{
                self.showWarningAlert(title: "MyHealthApp", message: error?.localizedDescription ?? "")
            } else {
               self.myPresentViewController()
            }
        })
    }
    
    func myValidate() -> Bool {
        if conditionIdx == -1 {self.showToast(message: "Please select the measuring condition. 😊👆👆") ; return false}
        return true
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.myPresentViewController()
    }
    
    func myPresentViewController() {
        if fromDiaryOrAnalytics {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "DiaryVC")
            present(controller, animated: true, completion: nil)
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "analyticsVC")
            present(controller, animated: true, completion: nil)
        }
    }
}
