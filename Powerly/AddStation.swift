//
//  AddStationModel.swift
//  PowerShare
//
//  Created by admin on 13/05/23.
//  
//
import CoreLocation
import Foundation
import RxSwift

enum AddStationType {
    case description, address, pinLocation, stations, hours, amenities, price, types, media
}
struct Station {
    let type: AddStationType
    let title: String
    let number: Int
}

enum PriceUnit: String {
    case energy
    case minutes
}

struct SoftPowerSource {
    let title: String
    var description: String
    var identifier: String?
    var category: String
}

enum PowerSourceCategory: String {
    case evCharger="EV_CHARGER"
    case smartPlug="SMART_PLUG"
    case smartMeter="SMART_METER"
}

struct StationAddress: Codable {
    var addressLine1: String?
    var addressLine2: String?
    var addressLine3: String?
    var city: String?
    var state: String?
    var zipcode: String?
    
    enum CodingKeys: String, CodingKey {
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case addressLine3 = "address_line_3"
        case city
        case state
        case zipcode
    }
    
    init(addressLine1: String? = nil,
         addressLine2: String? = nil,
         addressLine3: String? = nil,
         city: String? = nil,
         state: String? = nil,
         zipcode: String? = nil) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.city = city
        self.state = state
        self.zipcode = zipcode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.addressLine1 = try container.decodeIfPresent(String.self, forKey: .addressLine1)
        self.addressLine2 = try container.decodeIfPresent(String.self, forKey: .addressLine2)
        self.addressLine3 = try container.decodeIfPresent(String.self, forKey: .addressLine3)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.zipcode = try container.decodeIfPresent(String.self, forKey: .zipcode)
    }
}
