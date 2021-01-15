//
//  HeartRates.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 23/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

struct HeartRates: Codable {
    var documentID: String? = ""
    var dateValue: String = ""
    var systolic: String = ""
    var diastolic: String = ""
    var pulse: String = ""
    var conditionIdx: Int = -1
    var bpmIdx: Int = -1
    var userId: String = ""
}
