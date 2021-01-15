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

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var bloodPressureLbl: UILabel!
    @IBOutlet weak var pulseLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var resultEmotiLbl: UILabel!
    
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
    
    let resultArray = ["💥", "🌤", "🌿", "👻"]
    let resultString = ["Hypertension 2", "Prehypertension", "Normal BP", "Low BP"]
    let containerColorArray = [#colorLiteral(red: 0.7517880722, green: 0.1749722764, blue: 0.1800241869, alpha: 1), #colorLiteral(red: 1, green: 0.4932053257, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)]
    let colorArray = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)]
    let statusArray = ["☕", "😴", "💪", "🛀", "🚴", "😊", "🚶", "😭"]
    let userID = UIDevice.current.identifierForVendor!.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIs()
        getData()

    }
    
    func setupUIs() {
        
        buttonArray.append(wokeupBtn)
        buttonArray.append(beforebedBtn)
        buttonArray.append(workoutBtn)
        buttonArray.append(restingBtn)
        buttonArray.append(cardioBtn)
        buttonArray.append(happyBtn)
        buttonArray.append(walkBtn)
        buttonArray.append(stressBtn)
        for i in buttonArray {
            i.addTarget(self, action: #selector(conditionChanged(sender:)), for: .touchUpInside)
        }

        lblArray.append(workupLbl)
        lblArray.append(beforebedLbl)
        lblArray.append(workoutLbl)
        lblArray.append(restingLbl)
        lblArray.append(cardioLbl)
        lblArray.append(happyLbl)
        lblArray.append(walkLbl)
        lblArray.append(stressLbl)
        
        labelArray.append(wokeupLabel)
        labelArray.append(beforebedLabel)
        labelArray.append(workoutLabel)
        labelArray.append(restingLabel)
        labelArray.append(cardioLabel)
        labelArray.append(happyLabel)
        labelArray.append(walkLabel)
        labelArray.append(stressLabel)
        
        initializeButtons()
        containerView.layer.cornerRadius = 20
        
    }
    
    //... condition initialize
    func initializeButtons() {
        for i in 0..<8 {
            initialLbl(input: lblArray[i])
            initialLabel(input: labelArray[i])
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
        for i in buttonArray {
            if sender == i {
                conditionIdx = count
                break
            }
            count += 1
        }
        initializeButtons()
        lblArray[count].backgroundColor = selectedBackgroundColor.withAlphaComponent(0.5)
        labelArray[count].textColor = .black

    }
        
    //... fetch data from InputVC
    func getData() {
        dateValue = getDate()
        let k : [String] = dateValue.components(separatedBy: "at")
        dateLbl.text = k[0].components(separatedBy: ",")[0]
        timeLbl.text = k[1]
        
        let kk = (pulseValue as NSString).doubleValue
        if kk <= 60
        {
            bpmIdx = 0// low pulse
        }
        else if (kk > 60) && (kk <= 90)
        {
            bpmIdx = 1// normal pulse
        }
        else if (kk > 90) && (kk <= 120)
        {
            bpmIdx = 2// prehyper
        }
        else
        {
            bpmIdx = 3//Hyper
        }
        
        heartImg.tintColor = colorArray[bpmIdx]
        resultLbl.textColor = colorArray[bpmIdx]
        resultLbl.text = resultString[bpmIdx]
        resultEmotiLbl.text = resultArray[bpmIdx]
        
        
    }
    /*
    heartRate = String(format: "%0.2f bpm", result.bpm)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm a"
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    dateValue = dateFormatter.string(from: Date())
    */
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if !myValidate() {return}
        // if possible, we can save the date to Firebase.
        saveDataTo()
    }
    
    func saveDataTo() {
        var fireReference : DocumentReference? = nil
        let fireData = Firestore.firestore()
        let firePost = ["dateValue": dateValue,
                        "systolic": sysValue,
                        "diastolic": diaValue,
                        "pulse": pulseValue,
                        "conditionIdx": conditionIdx,
                        "bpmIdx": bpmIdx,
                        "userID": userID
            ] as [String : Any]
        showLoading()
        fireReference = fireData.collection("post").addDocument(data: firePost, completion: { [self] (error) in
            stopLoading()
            if error != nil{
                showWarningAlert(title: "MyHealthApp", message: error?.localizedDescription ?? "")
            } else {
               myPresentViewController()
            }
        })
    }
    
    func myValidate() -> Bool {
        if conditionIdx == -1 {showToast(message: "Please select the measuring condition. 😊👆👆") ; return false}
        return true
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        myPresentViewController()
    }
    
    func myPresentViewController() {
        if fromDiary {
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
