//
//  Connector.swift
//  PowerShare
//
//  Created by ADMIN on 14/06/23.
//  
//

import Foundation
import SwiftyJSON

public struct Connector: Codable {
    let id: Int
    var number: Int?
    let name: String
    let icon: String?
    let type: String?
    let maxPower: Int
    let connectorCurrentType: String?
    let status: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        number = (try? container.decodeIfPresent(Int.self, forKey: .number)) ?? nil
        name = (try? container.decodeIfPresent(String.self, forKey: .name)) ?? ""
        icon = (try? container.decodeIfPresent(String.self, forKey: .icon)) ?? ""
        type = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        if let strValue = try? container.decode(String.self, forKey: .maxPower) {
            maxPower = Int(strValue) ?? 0
        } else {
            maxPower = (try? container.decodeIfPresent(Int.self, forKey: .maxPower)) ?? 0
        }
        connectorCurrentType = (try? container.decodeIfPresent(String.self, forKey: .connectorCurrentType)) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case number
        case name
        case icon
        case type
        case maxPower = "max_power"
        case connectorCurrentType = "connector_current_type"
        case status
    }
}

struct Amenity: Codable {
    let id: Int
    let name: String
    let icon: String?
    var isSelected: Bool? = false
}
