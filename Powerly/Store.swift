//
//  Store.swift
//  PowerShare
//
//  Created by admin on 02/06/22.
//  
//

import Foundation
import SwiftyJSON

enum WeekDay: String {
    case sun
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    var value: Int {
        switch self {
        case .sun:
            return 1
            
        case .mon:
            return 2
            
        case .tue:
            return 3
            
        case .wed:
            return 4
            
        case .thu:
            return 5
            
        case .fri:
            return 6
            
        case .sat:
            return 7
        }
    }
}

struct Availability {
    let closeTime: String
    let id: String
    let day: WeekDay?
    let storeId: String
    let openTime: String
}

extension Availability {
    static func fromJSON(json: JSON) -> Availability {
        return Availability(closeTime: json["close_time"].stringValue,
                            id: json["id"].stringValue,
                            day: WeekDay(rawValue: json["day"].stringValue),
                            storeId: json["store_id"].stringValue,
                            openTime: json["open_time"].stringValue)
    }
}

public struct Store {
    let longitude: Double
    let id: String
    let distance: String
    let email: String
    let latitude: Double
    let phoneNumber: String
    let name: String
    let logo: String
    let storeName: String
    var orderLimit = 3
    let address: String
    let vatNo: String
    let availability: [Availability]
    let isOpen: Bool
}

extension Store: JSONConvertible {
    static func fromJSON(json: JSON) -> Store {
        var availabilityList: Array = [Availability]()
        if let availabilityArray = json["availability"].array {
            availabilityList = availabilityArray.map({ return Availability.fromJSON(json: $0) })
        }
        return Store(longitude: json["longitude"].doubleValue,
                     id: json["id"].stringValue,
                     distance: json["distance"].stringValue,
                     email: json["email"].stringValue,
                     latitude: json["latitude"].doubleValue,
                     phoneNumber: json["phone_number"].stringValue,
                     name: json["name"].stringValue,
                     logo: json["logo"].stringValue,
                     storeName: json["store_name"].stringValue,
                     address: json["address"].stringValue,
                     vatNo: json["vat_no"].stringValue,
                     availability: availabilityList,
                     isOpen: json["is_open"].boolValue)
    }
}
