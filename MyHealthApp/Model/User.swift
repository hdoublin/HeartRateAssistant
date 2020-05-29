//
//  User.swift
//  MyHealthApp
//
//  Created by Stuti on 10/10/18.
//  Copyright © 2018 iOS. All rights reserved.
//

import Foundation

struct User: Decodable {
    var email: String?
    var password: String?
    var firstname: String?
    var lastname: String?
    var dob: String?
    var geneticResult: [GeneticData]?
}

struct GeneticData: Decodable {
    var name: String?
    var symbol: String?
}
