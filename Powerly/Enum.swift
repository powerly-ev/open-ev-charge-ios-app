//
//  Enum.swift
//  PowerShare
//
//  Created by admin on 19/01/22.
//  
//

import Foundation
import UIKit

enum OrderColor: String {
    case open = "7A7A7A"
    case confirmed = "008CE9"
    case onTheWay = "F79E1B"
    case delivered = "7DBD00"
    case cancelled = "CANCEL_TEXT"
}

enum ServiceType: Int {
    case new = 1
    case refill = 2
    case installation = 3
}

enum PaymentMethod: Int {
    case cash = 0
    case payFort = 1
    case pointCheckout = 2
    case efawateer = 3
    case paypal = 4
    case applePay = 5
    case balance = 6
}

enum PayFortStatus: Int {
    case success = 1
    case cancelled = 2
    case failed = 3
}

enum CurrentProgress: Int {
    case notCompleted = 0
    case current = 1
    case completed = 2
}
