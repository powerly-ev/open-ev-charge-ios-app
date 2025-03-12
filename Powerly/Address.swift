//
//  Address.swift
//  PowerShare
//
//  Created by admin on 12/12/21.

//

import Foundation
import SwiftyJSON

public struct Address {
    var country: Country?
    var city: City?
    var area: Area?
    var addressLineEn: String = ""
    var addressLineAr: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var productsLimit = 3
}

extension Address: JSONConvertible {
    static func fromJSON(json: JSON) -> Address {
        let address = json["address"]
        let country = json["country"] == JSON.null ? nil : Country.fromJSON(json: json["country"])
        let city = json["city"] == JSON.null ? nil : City.fromJSON(json: json["city"])
        let area = json["area"] == JSON.null ? nil : Area.fromJSON(json: json["area"])
        return Address(country: country,
                       city: city,
                       area: area,
                       addressLineEn: address["en"].stringValue,
                       addressLineAr: address["ar"].stringValue,
                       latitude: "",
                       longitude: "",
                       productsLimit: json["products_limit"].intValue)
    }
}
