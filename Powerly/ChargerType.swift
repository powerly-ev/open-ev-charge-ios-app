//
//  Type.swift
//  PowerShare
//
//  Created by ADMIN on 13/07/23.
//  
//

import Foundation

struct ChargerType: Codable {
    let id: Int
    let name: String
    let img: String?
    let currentType: String
    let maxPower: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case img
        case currentType = "current_type"
        case maxPower = "max_power"
    }
}
