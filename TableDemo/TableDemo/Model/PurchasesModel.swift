//
//  PurchasesModel.swift
//  TableDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

struct Purchases: Codable {
    var id: Int?
    var userInfo: UserInfo?
    var paymentInfo: PaymentInfo?
}


struct UserInfo: Codable {
    var id: Int?
    var username: String?
}


struct PaymentInfo: Codable {
    var creditCard: String?
    var creditCardType: String?
    var amount: String?
    var purchaseTypes: [String]?
}
