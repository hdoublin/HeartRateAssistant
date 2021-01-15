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


