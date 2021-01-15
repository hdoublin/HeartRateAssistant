//
//  AppDelegate.swift
//  MyHealthApp
//
//  Created by Stuti on 14/10/18.
//  Copyright © 2018 iOS. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

var sysValue: String = "120"
var diaValue: String = "80"
var pulseValue: String = "60"
var dateValue: String = "none"
var conditionIdx : Int = -1
var bpmIdx: Int = -1

let dateFormatter = DateFormatter()

var fromDiary: Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true
        
        return true
    }
}
