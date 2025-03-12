//
//  Card.swift
//  PowerShare
//
//  Created by admin on 01/01/22.
//  
//

import Foundation
import SwiftyJSON

public struct Card {
    let balance: String
    let cardNumber: String
    let id: String
    let isDefault: Int
    let paymentOption: String
    let paymentType: PaymentMethod
    let tokenName: String
}

extension Card: JSONConvertible {
    static func fromJSON(json: JSON) -> Card {
        return Card(balance: json["balance"].stringValue,
                    cardNumber: json["card_number"].stringValue,
                    id: json["id"].stringValue,
                    isDefault: json["default"].intValue,
                    paymentOption: json["payment_option"].stringValue,
                    paymentType: PaymentMethod.payFort,
                    tokenName: json["token_name"].stringValue)
    }
}
