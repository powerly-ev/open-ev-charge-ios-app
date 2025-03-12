//
//  AdditionalService.swift
//  PowerShare
//
//  Created by admin on 22/02/22.
//  
//

import Foundation

enum SubTotalType: Int {
    case productPrice = 0
    case deliveryFees = 1
    case discount = 2
    case vat = 3
    case total = 4
    case expressFees = 5
    case nightShiftFees = 6
    case installationFees = 7
    case dueBalance = 8
}

public struct SubTotal {
    let name: String
    let type: SubTotalType
    let price: String
}
