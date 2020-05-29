//
//  WaitingVC.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 23/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class WaitingVC: UIViewController {

    
    @IBOutlet weak var heartLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let heartRateKitController = HeartRateKitController()
        heartRateKitController.delegate = self
        self.present(heartRateKitController, animated: true, completion: nil)
        self.measuringProcessing()
        
    }
 
    @objc func measuringProcessing() {
        
        //Because of .autoreverse, each heartbeat is a pair of animations (grow and shrink).
        //That's why the 60 is divided by 2.
        let options: UIView.AnimationOptions = [.repeat, .autoreverse, .curveEaseInOut];
        
        UIView.animate(                               //Call a type method of class UIView.
            withDuration: 0.5, //seconds
            delay: 60,
            options: options,
            animations: {
                self.heartLbl.transform = CGAffineTransform(scaleX: 1.125, y: 1.125);
            },
            completion: nil
        );
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}


extension WaitingVC: HeartRateKitControllerDelegate {
    
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
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        dateValue = formatter.string(from: Date())

        let alert = UIAlertController(title: "Your Heart Rate", message: heartRate, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SaveVC")
            self.present(controller, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
