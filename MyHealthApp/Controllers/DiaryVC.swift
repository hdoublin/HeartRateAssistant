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

var dateValue: String = "none"
var heartRate: String = "none"
var conditionIdx : Int = -1
var bpmIdx: Int = -1

var fromDiaryOrAnalytics: Bool = true
var isPurchase : Bool = false

let dateFormatter = DateFormatter()

class DiaryVC: UIViewController {
    
    @IBOutlet weak var measureBtn: UIButton!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var redContainer: UIView!
    @IBOutlet weak var greenContainer: UIView!
    @IBOutlet weak var blueContainer: UIView!
    @IBOutlet weak var dataContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var redLbl: UILabel!
    @IBOutlet weak var greenLbl: UILabel!
    @IBOutlet weak var blueLbl: UILabel!
    
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var purchaseBtn: UIButton!
    
    
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var periodLbl: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    
        
    let datePickerDialog = DatePickerDialog(
        textColor: .black,
        buttonColor: .black,
        font: UIFont.boldSystemFont(ofSize: 17),
        showCancelButton: true
    )
    
    
    let onTabImgs: [UIImage] = [#imageLiteral(resourceName: "black_diary"), #imageLiteral(resourceName: "black_analysis"), #imageLiteral(resourceName: "black_workout")]
    let offTabImgs: [UIImage] = [#imageLiteral(resourceName: "gray_diary"), #imageLiteral(resourceName: "gray_analysis"), #imageLiteral(resourceName: "gray_workout")]
    var selectedTabIdx : Int = 0
    var buttonArray: [UIButton] = []
    var count: Int = 0
    var myObject: [HeartRates] = []
    var filteredObject: [HeartRates] = []
    
    let period: Int = 7
    var endOfPeriod = Date()
    var dateArray: [String] = []
    
    var selectedHeartRates: [Int] = []
    var selectedDates: [String] = []

    
    let userID = UIDevice.current.identifierForVendor!.uuidString
    
    var cellColor = UIColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isPurchase = UserDefaults.standard.bool(forKey: "isPurchase")
        if isPurchase {
            self.measureBtn.backgroundColor = #colorLiteral(red: 1, green: 0.3960784314, blue: 0.3176470588, alpha: 1)
            self.measureBtn.isEnabled = true
            self.purchaseView.isHidden = true
        }
        else
        {
            self.measureBtn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            self.measureBtn.isEnabled = false
            self.purchaseView.isHidden = false
        }
        self.measureBtn.layer.cornerRadius = self.measureBtn.frame.height/2
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        //
        self.redContainer.layer.cornerRadius = 10
        self.greenContainer.layer.cornerRadius = 10
        self.blueContainer.layer.cornerRadius = 10
        
        //tabBar initialize
        self.buttonArray.append(self.firstBtn)
        self.buttonArray.append(self.secondBtn)
        self.buttonArray.append(self.thirdBtn)
        for i in buttonArray {
            i.addTarget(self, action: #selector(tabIdxChanged(sender: )), for: .touchDown)
        }
        self.periodLbl.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(datePicker))
        self.periodLbl.addGestureRecognizer(tap)
        self.rightBtn.addTarget(self, action: #selector(rightBtnPressed), for: .touchUpInside)
        self.leftBtn.addTarget(self, action: #selector(leftBtnPressed), for: .touchUpInside)
        

        
        
        self.tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.tabBarView.layer.borderWidth = 1.0
        
        
        
        //read the saved records.
        self.getDataFromFirestore()

    }
    
    func setUIs() {
        if self.myObject.count == 0 {
            self.initialView.isHidden = false
            self.dataContainer.isHidden = true
            self.popView.isHidden = true
        }else {
            self.initialView.isHidden = true
            self.dataContainer.isHidden = false
            self.popView.isHidden = true
        }
    }
    
    @objc func tabIdxChanged(sender: UIButton) {
        self.initializeTabIcons()
        count = 0
        for i in buttonArray {
            if sender == i {
                sender.setImage(onTabImgs[count], for: .normal)
                break
            }
            count += 1
        }
        if count == 0
        {
            //to diary
            
        }
        else if count == 1
        {
            //to analysis
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "analyticsVC")
            present(controller, animated: true, completion: nil)
            
        }
        else
        {
            //to workout
            self.showToast(message: "Workout is still in developing proces. 😊")
        }
    }
    
    func initializeTabIcons () {
        self.firstBtn.setImage(offTabImgs[0], for: .normal)
        self.secondBtn.setImage(offTabImgs[1], for: .normal)
        self.thirdBtn.setImage(offTabImgs[2], for: .normal)
    }

    
    func setValuesToWidget() {
        self.selectedDates.removeAll()
        self.selectedHeartRates.removeAll()
        for i in self.filteredObject {
            let k : String = i.dateValue.components(separatedBy: "at")[0]
            self.selectedDates.append(k.components(separatedBy: ",")[0])
            let kk: NSString = i.heartRate as NSString
            self.selectedHeartRates.append(Int(kk.intValue))
        }
        
        if selectedHeartRates.count == 0 {
            self.greenLbl.text = "     "
            self.redLbl.text = "     "
            self.blueLbl.text = "     "
        }else{
            self.greenLbl.text = String(self.average(input: self.selectedHeartRates))
            self.redLbl.text = String(self.selectedHeartRates.max()!)
            self.blueLbl.text = String(self.selectedHeartRates.min()!)
        }
        self.tableView.reloadData()
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
//            self.endOfPeriod = success
////            PopupDatePicker.selec
//        }
//        datePicker.show()
        datePickerDialog.show("End of Period",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        defaultDate: Date(),
                        minimumDate: fromDate, maximumDate: toDate,
                        datePickerMode: .date) { (selectedEndDate) in
                            if selectedEndDate != nil {
                                self.endOfPeriod = selectedEndDate!
                            }
                            self.myFilter()
        }

        
    }
    
    @objc func rightBtnPressed() {
        for i in 1..<self.period {
            endOfPeriod = Calendar.current.date(byAdding: .day, value: 1, to: endOfPeriod)!
        }
        self.myFilter()
    }
    
    @objc func leftBtnPressed() {
        for i in 1..<self.period {
            endOfPeriod = Calendar.current.date(byAdding: .day, value: -1, to: endOfPeriod)!
        }
        self.myFilter()
    }

    // if possible, get data from firebase.
    func getDataFromFirestore() {
        self.showLoading()
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("post").order(by: "dateValue", descending: true).addSnapshotListener { (snapshot, error) in
            self.stopLoading()
            
            if error != nil {
                self.showToast(message: error?.localizedDescription ?? "")
                print(error?.localizedDescription ?? "")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    self.myObject.removeAll()
                    for document in snapshot!.documents {
                        let documentID =  document.documentID
                        var object = HeartRates()
                        
                        object.documentID = documentID
                        if let postedDate = document.get("dateValue") as? String {
                            object.dateValue = postedDate
                        }
                        if let postHeartRate = document.get("heartRate") as? String{
                            object.heartRate = postHeartRate
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
                        if object.userId == self.userID {
                            self.myObject.append(object)
                        }
                    }
                    //UI initialize
                    self.setUIs()
                    self.myFilter()
                }
            }
        }
    }
    
    func myFilter() {
        //make dateArray from 7,14,21
        self.filteredObject.removeAll()
        self.dateArray.removeAll()
        var today = self.endOfPeriod
        
        self.dateArray.append(self.dateConvert(input: today))
        for i in 1..<self.period {
            today = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            self.dateArray.append(self.dateConvert(input: today))
        }
        self.periodLbl.text = self.dateArray[6] + " - " + self.dateArray[0]
        for i in self.myObject {
            
            let dateKey: String = i.dateValue.components(separatedBy: "at")[0].components(separatedBy: ",")[0]
            print(dateKey)
            if dateArray.contains(dateKey) { self.filteredObject.append(i)}
        }
        
        self.setValuesToWidget()
    }
    
    @IBAction func purchaseBtnPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isPurchase")
        self.showToast(message: "Your app have been purchased.")
        self.viewDidLoad()
    }
    
    
    @IBAction func measureBtnPressed(_ sender: Any) {
        
//        self.dataContainer.isHidden = true
        
        popView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            //use if you want to darken the background
            //self.viewDim.alpha = 0.8
            //go back to original form
            self.popView.isHidden = false
            self.popView.transform = .identity
        })
    }
    
    @IBAction func startBtnPressed(_ sender: Any) {
    
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
          //use if you wish to darken the background
          //self.viewDim.alpha = 0
          self.popView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (success) in
            self.popView.isHidden = true
        }
        let heartRateKitController = HeartRateKitController()
        heartRateKitController.modalPresentationStyle = .fullScreen
        heartRateKitController.delegate = self
        self.present(heartRateKitController, animated: true, completion: nil)
    }
}

extension DiaryVC: HeartRateKitControllerDelegate {
    
    func heartRateKitController(_ controller: HeartRateKitController, didFinishWith result: HeartRateKitResult) {
        self.dismiss(animated: true) {
            self.showHeartRateResult(result)
        }
    }
    
    func heartRateKitControllerDidCancel(_ controller: HeartRateKitController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showHeartRateResult(_ result: HeartRateKitResult) {
        heartRate = String(format: "%0.2f bpm", result.bpm)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateValue = dateFormatter.string(from: Date())
        
        let alert = UIAlertController(title: "Your Heart Rate", message: heartRate, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            
            fromDiaryOrAnalytics = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SaveVC")
            self.present(controller, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


extension DiaryVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        cell.containerView.layer.cornerRadius = 20.0
        cell.containerView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.containerView.layer.shadowOpacity = 0.4
        
        
        let k: [String] = self.filteredObject[indexPath.row].dateValue.components(separatedBy: "at")
        cell.dateLbl.text = k[0].components(separatedBy: ",")[0]
        cell.timeLbl.text = k[1]
        let result:String = self.filteredObject[indexPath.row].heartRate.components(separatedBy: "bpm")[0]
        cell.valueLbl.text = result
        
        if self.filteredObject[indexPath.row].bpmIdx == 0 {
            self.cellColor = .blue
            cell.resultLbl.text = "Low pulse"
        }else if bpmIdx == 1 {
            self.cellColor = .green
            cell.resultLbl.text = "Normal pulse"
        }else{
            self.cellColor = #colorLiteral(red: 1, green: 0.3960784314, blue: 0.3176470588, alpha: 1)
            cell.resultLbl.text = "High pulse"
        }
        cell.heartImg.tintColor = self.cellColor
        cell.resultLbl.textColor = self.cellColor
        cell.phaseLbl.layer.masksToBounds = true
        cell.phaseLbl.layer.cornerRadius = 10.0
        switch  self.filteredObject[indexPath.row].conditionIdx {
        case 0:
            cell.phaseLbl.text = "☕"; break
        case 1:
            cell.phaseLbl.text = "😴"; break
        case 2:
            cell.phaseLbl.text = "💪"; break
        case 3:
            cell.phaseLbl.text = "🛀"; break
        case 4:
            cell.phaseLbl.text = "🚴"; break
        case 5:
            cell.phaseLbl.text = "😊"; break
        case 6:
            cell.phaseLbl.text = "🚶"; break
        case 7:
            cell.phaseLbl.text = "😭"; break
        default:
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145.0
    }

}



