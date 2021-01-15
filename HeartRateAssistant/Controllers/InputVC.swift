//
//  InputVC.swift
//  HeartRateAssistant
//
//  Created by mymac on 2021/1/13.
//  Copyright © 2021 iOS. All rights reserved.
//

import UIKit

class InputVC: UIViewController {

    @IBOutlet weak var sysTxt: UITextField!
    @IBOutlet weak var diaTxt: UITextField!
    @IBOutlet weak var pulseTxt: UITextField!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var tabBarView: UIView!
    
    @IBOutlet weak var continueContainer: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var continueArrowContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUIs()

    }

    func setupUIs() {
        
        sysValue = "-1"; diaValue = "-1"; pulseValue = "-1"

        sysTxt.delegate = self
        diaTxt.delegate = self
        pulseTxt.delegate = self
        
        //
        tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        tabBarView.layer.borderWidth = 1.0
        
        //
        continueContainer.layer.cornerRadius = 15 // shareContainer.frame.height/2
        continueArrowContainer.layer.cornerRadius = 13 // shareHeartContainer.frame.height/2
//        shareBtn.layer.cornerRadius = 15
        
        //
        sysTxt.becomeFirstResponder()
        sysTxt.addTarget(self, action: #selector(sysTxtAction), for: .editingChanged)
        diaTxt.addTarget(self, action: #selector(diaTxtAction), for: .editingChanged)
        pulseTxt.addTarget(self, action: #selector(pulseTxtAction), for: .editingChanged)
        
    }
    
    @objc func sysTxtAction() {
        if sysTxt.text?.count == 3 {
            diaTxt.becomeFirstResponder()
        }
    }
    
    @objc func diaTxtAction() {
        if diaTxt.text?.count == 2 {
            pulseTxt.becomeFirstResponder()
        }
    }
    
    @objc func pulseTxtAction() {
        
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueBtnPressed(_ sender: Any) {
        if !inputValidate() {return}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SaveVC")
        present(controller, animated: true, completion: nil)
    }
    
    @objc func inputValidate() -> Bool {
        sysValue = sysTxt.text ?? "-1"
        diaValue = diaTxt.text ?? "-1"
        pulseValue = pulseTxt.text ?? "-1"
        if sysValue == "-1" || diaValue == "-1" || pulseValue == "-1" {showToast(message: "Please fill the all blanks. 👨🏼‍🦳"); return false}
        
        return true
    }
    
}

extension InputVC: UITextFieldDelegate {
    
    //text keyboard disappearing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if (textField == sysTxt) {
//            sysTxt.becomeFirstResponder()
//        }
//        else if (textField == diaTxt) {
//            diaTxt.becomeFirstResponder()
//
//        } else { //} if (textField == pulseTxt) {
//            pulseTxt.becomeFirstResponder()
//        }
//
//        return true
//    }
    
}
