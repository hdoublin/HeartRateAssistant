//
//  analyticsVC.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 23/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit
import Charts
import CoreCharts
import Firebase
import FirebaseStorage


class analyticsVC: UIViewController {
    
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button14: UIButton!
    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var redLbl: UILabel!
    @IBOutlet weak var greenLbl: UILabel!
    @IBOutlet weak var blueLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pieChart: PieChartView!

    @IBOutlet weak var barChart: VCoreBarChart!
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var measureBtn: UIButton!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    
    @IBOutlet weak var redContainer: UIView!
    @IBOutlet weak var greenContainer: UIView!
    @IBOutlet weak var blueContainer: UIView!
    
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var popView: UIView!
    
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var purchaseBtn: UIButton!
    
    
    let onTabImgs: [UIImage] = [#imageLiteral(resourceName: "black_diary"), #imageLiteral(resourceName: "black_analysis"), #imageLiteral(resourceName: "black_workout")]
    let offTabImgs: [UIImage] = [#imageLiteral(resourceName: "gray_diary"), #imageLiteral(resourceName: "gray_analysis"), #imageLiteral(resourceName: "gray_workout")]
    var selectedTabIdx : Int = 0
    var buttonArray: [UIButton] = []
    var count: Int = 0

    var selectedBackgroundColor : UIColor = .lightGray
    var dayPickers: [UIButton] = []
    var dayArray: [Int] = [7, 14, 30]
    
    var myObject: [HeartRates] = []
    var filteredObject: [HeartRates] = []
    
    var period: Int = 7
    var dateArray: [String] = []
    //Graph and show red,blue,greenlabel
    var selectedHeartRates: [Int] = []
    var selectedDates: [String] = []
    var dataEntries: [BarChartDataEntry] = []
    
    let userID = UIDevice.current.identifierForVendor!.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        barChart.dataSource = self
        barChart.displayConfig.barWidth = 20
        barChart.displayConfig.barSpace = 30
        barChart.displayConfig.titleFontSize = 11
        barChart.displayConfig.topSpace = 5
        
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
        
        self.measureBtn.layer.cornerRadius = self.measureBtn.frame.height/2
        

        self.scrollView.contentSize = self.containerView.bounds.size
        //
//        self.barChart.noDataText = "You need to provide data for the chart."
        self.pieChart.noDataText = "You need to provide data for the chart."

        self.redContainer.layer.cornerRadius = 10
        self.greenContainer.layer.cornerRadius = 10
        self.blueContainer.layer.cornerRadius = 10
        
        //upButtons
        self.dayPickers.append(button7)
        self.dayPickers.append(button14)
        self.dayPickers.append(button30)
        
        for i in dayPickers {
            i.addTarget(self, action: #selector(upDaysChanged), for: .touchUpInside)
            i.layer.cornerRadius = i.frame.height/2
            i.layer.borderColor = selectedBackgroundColor.withAlphaComponent(0.5).cgColor
            i.layer.borderWidth = 1.0
        }
        button7.backgroundColor = selectedBackgroundColor.withAlphaComponent(0.5)
        //tabBar initialize
        self.buttonArray.append(self.firstBtn)
        self.buttonArray.append(self.secondBtn)
        self.buttonArray.append(self.thirdBtn)
        for i in buttonArray {
            i.addTarget(self, action: #selector(tabIdxChanged(sender: )), for: .touchDown)
        }
        
        self.tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.tabBarView.layer.borderWidth = 1.0
        
        self.getData()
        
    }
    
    func drawGraph() {
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
            
            self.barChart.reload()
//            barChart
            
        }

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
                    self.period = 7
                    self.myFilter()
                }
            }
        }
    }

    func setUIs() {
        if self.myObject.count == 0 {
            self.initialView.isHidden = false
            self.scrollView.isHidden = true
            self.popView.isHidden = true
        }else {
            self.initialView.isHidden = true
            self.scrollView.isHidden = false
            self.popView.isHidden = true
        }
    }
    
    
    @IBAction func purchaseBtnPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isPurchase")
        self.showToast(message: "Your app have been purchased.")
        self.viewDidLoad()
    }
    
    @objc func upDaysChanged(sender: UIButton) {
        count = 0
        button7.backgroundColor = .clear
        button14.backgroundColor = .clear
        button30.backgroundColor = .clear
        for i in self.dayPickers {
            if i == sender {
                sender.backgroundColor = selectedBackgroundColor.withAlphaComponent(0.5)
                break
            }
            count += 1
        }
        
        self.period = self.dayArray[count]
        self.myFilter()
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "DiaryVC")
            
            present(controller, animated: true, completion: nil)
        }
        else if count == 1
        {
            //to analysis
            
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
    
    func myFilter() {
        //make dateArray from 7,14,21
        self.filteredObject.removeAll()
        self.dateArray.removeAll()
        var today = Date()
        print("self.period = \(self.period)")
        self.dateArray.append(self.dateConvert(input: today))
        for i in 1..<self.period {
            today = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            self.dateArray.append(self.dateConvert(input: today))
        }
        
        for i in self.myObject {
            
            let dateKey: String = i.dateValue.components(separatedBy: "at")[0].components(separatedBy: ",")[0]
            print(dateKey)
            if dateArray.contains(dateKey) { self.filteredObject.append(i)}
        }
        
        print(self.filteredObject.count)
        self.drawGraph()
    }

}


extension analyticsVC: HeartRateKitControllerDelegate {
    
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
            
            fromDiaryOrAnalytics = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SaveVC")
            self.present(controller, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension analyticsVC: CoreChartViewDataSource {
    
    func didTouch(entryData: CoreChartEntry) {
        print(entryData.barTitle)
    }
    
    func loadCoreChartData() -> [CoreChartEntry] {
        
        return getTurkeyFamouseCityList()
        
    }
    
    
    func getTurkeyFamouseCityList()->[CoreChartEntry] {
        var graphValues = [CoreChartEntry]()

       
        for index in 0..<self.selectedDates.count {
            
            let newEntry = CoreChartEntry(id: "\(self.selectedHeartRates[index])",
                barTitle: self.selectedDates[index],
                barHeight: Double(self.selectedHeartRates[index]),
                                          barColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) )
                                          
                                         
            graphValues.append(newEntry)
            
        }
        
        return graphValues
        
    }
    
}
