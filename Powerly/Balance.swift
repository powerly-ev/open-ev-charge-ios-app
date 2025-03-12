//
//  Balance.swift
//  PowerShare
//
//  Created by admin on 27/12/21.

//

import Foundation
import SwiftyJSON

public struct Balance {
    let active: Bool
    let bonus: String
    let currency: String
    let id: String
    let popular: Int
    let price: String
    let title: String
    let totalBalance: String
    let totalPrice: String
    let vat: String
}

extension Balance: JSONConvertible {
    static func fromJSON(json: JSON) -> Balance {
        return Balance(active: json["active"].boolValue,
                       bonus: json["bonus"].stringValue,
                       currency: json["currency"].stringValue,
                       id: json["id"].stringValue,
                       popular: json["popular"].intValue,
                       price: json["price"].stringValue,
                       title: json["title"].stringValue,
                       totalBalance: json["total_balance"].stringValue,
                       totalPrice: json["total_price"].stringValue,
                       vat: json["vat"].stringValue)
    }
}
