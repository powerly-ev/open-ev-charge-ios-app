//
//  AddVehicle.swift
//  PowerShare
//
//  Created by ADMIN on 19/05/23.
//  
//

import Foundation
import SwiftyJSON

enum VehicleType {
    case manufacturer, model, details
}

struct Make: Codable {
   // let code:String
    let id: Int
    let name: String
    let logo: String?
}

extension Make {
    var nameFirstLetter: String {
        return self.name.first?.uppercased() ?? ""
    }
}

struct VehicleModel: Codable {
   // let code:String
    let id: Int
    let name: String
}

extension VehicleModel {
    var nameFirstLetter: String {
        return self.name.first?.uppercased() ?? ""
    }
}

struct VehicleDetail {
    let type: VehicleType
    let title: String
}

struct AddVehicle {
    let details: [VehicleDetail]
    var manufacturer: Make?
    var model: VehicleModel?
    var title: String?
    var year: Int?
    var color: String?
    var fuelType: String?
    var connector: Connector?
}

struct MakeSection {
    let name: String
    let makes: [Make]
}

struct CarColor {
    let id: Int
    let name: String
    let hex: String
    var isLight = false
}
