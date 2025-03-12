//
//  Country.swift
//  PowerShare
//
//  Created by admin on 04/12/21.

//

import Foundation
import SwiftyJSON

public struct Country {
    let id: Int
    let email: String
    let currency: String
    let flagUrl: String
    let latitude: String
    let longitude: String
    let currencyIso: String
    let phoneCode: String
    let contactNumber: String
    let timeZone: String
    let name: String
    let iso: String
}

extension Country: JSONConvertible {
    static func fromJSON(json: JSON) -> Country {
        return Country(id: json["id"].intValue,
                       email: json["email"].stringValue,
                       currency: json["currency"].stringValue,
                       flagUrl: json["flag_url"].stringValue,
                       latitude: json["latitude"].stringValue,
                       longitude: json["longitude"].stringValue,
                       currencyIso: json["currency_iso"].stringValue,
                       phoneCode: json["phone_code"].stringValue,
                       contactNumber: json["contact_number"].stringValue,
                       timeZone: json["time_zone"].stringValue,
                       name: json["name"].stringValue,
                       iso: json["iso"].stringValue)
    }
}

public struct City {
    var cityId: String
    var cityNameArabic: String
    var cityNameEnglish: String
}

extension City: JSONConvertible {
    static func fromJSON(json: JSON) -> City {
        return City(cityId: json["city_id"].stringValue,
                    cityNameArabic: json["city_name_arabic"].stringValue,
                    cityNameEnglish: json["city_name_english"].stringValue)
    }
}

public struct Area {
    var areaId: String
    var areaNameArabic: String
    var areaNameEnglish: String
}

extension Area: JSONConvertible {
    static func fromJSON(json: JSON) -> Area {
        return Area(areaId: json["area_id"].stringValue,
                    areaNameArabic: json["area_name_arabic"].stringValue,
                    areaNameEnglish: json["area_name_english"].stringValue)
    }
}

struct Currency: Codable {
    let currencyIso: String

    // Define custom parameter names for coding keys
    enum CodingKeys: String, CodingKey {
        case currencyIso = "currency_iso" // Map "currency_iso" in JSON to "currencyIso"
    }
}
