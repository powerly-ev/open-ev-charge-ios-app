//
//  ChargePoint.swift
//  PowerShare
//
//  Created by ADMIN on 10/07/23.
//  
//
import Foundation
import GooglePlaces
import SwiftyJSON

struct ChargePoint: Codable {
    let title: String
    let openTime: String
    let closeTime: String
    let contactNumber: String
    let latitude: String
    let longitude: String
    let category: String
    let listed: Bool
    let sessionLimitType: String
    let sessionLimitValue: Double
    let id: String
    let identifier: String
    let priceUnit: String
    let token: String
    let connectors: [Connector]
    let address: StationAddress?
    let description: String
    let rating: Float
    let totalSessionsTime: Int
    let totalEnergy: Double
    let totalEarnings: Double
    let multiPrice: Bool
    let amenities: [Amenity]
    let price: Float
    let type: ChargerType
    let isExternal: Bool
    let reservationFee: Float
    let isInUse: Bool
    let onlineStatus: Int
    let isReserved: Bool
    let configured: Int
    let bookedByCurrentUser: Bool
    let usedByCurrentUser: Bool
    var isGoogle = false
    var weekDays: [String]?
    var isNearest = false
    
    enum CodingKeys: String, CodingKey {
        case title
        case openTime = "open_time"
        case closeTime = "close_time"
        case contactNumber = "contact_number"
        case latitude
        case longitude
        case category
        case listed
        case sessionLimitType = "session_limit_type"
        case sessionLimitValue = "session_limit_value"
        case id
        case identifier
        case priceUnit = "price_unit"
        case token
        case connectors
        case address
        case description
        case rating
        case totalSessionsTime = "total_sessions_time"
        case totalEnergy = "total_energy"
        case totalEarnings = "total_earnings"
        case multiPrice = "multi_price"
        case amenities
        case price
        case type
        case isExternal = "is_external"
        case reservationFee = "reservation_fee"
        case isInUse = "is_in_use"
        case onlineStatus = "online_status"
        case isReserved = "is_reserved"
        case configured
        case bookedByCurrentUser = "booked_by_current_user"
        case usedByCurrentUser = "used_by_current_user"
        case isGoogle
        case weekDays
        case isNearest
    }
    
    init(title: String,
         openTime: String,
         closeTime: String,
         contactNumber: String,
         latitude: String,
         longitude: String,
         category: String,
         listed: Bool,
         sessionLimitType: String,
         sessionLimitValue: Double,
         id: String,
         identifier: String,
         priceUnit: String,
         token: String,
         connectors: [Connector],
         address: StationAddress?,
         description: String,
         rating: Float,
         totalSessionsTime: Int,
         totalEnergy: Double,
         totalEarnings: Double,
         multiPrice: Bool,
         amenities: [Amenity],
         price: Float,
         type: ChargerType,
         isExternal: Bool,
         reservationFee: Float,
         isInUse: Bool,
         onlineStatus: Int,
         isReserved: Bool,
         configured: Int,
         bookedByCurrentUser: Bool,
         usedByCurrentUser: Bool,
         isGoogle: Bool,
         weekDays: [String]?) {
            self.title = title
            self.openTime = openTime
            self.closeTime = closeTime
            self.contactNumber = contactNumber
            self.latitude = latitude
            self.longitude = longitude
            self.category = category
            self.listed = listed
            self.sessionLimitType = sessionLimitType
            self.sessionLimitValue = sessionLimitValue
            self.id = id
            self.identifier = identifier
            self.priceUnit = priceUnit
            self.token = token
            self.connectors = connectors
            self.address = address
            self.description = description
            self.rating = rating
            self.totalSessionsTime = totalSessionsTime
            self.totalEnergy = totalEnergy
            self.totalEarnings = totalEarnings
            self.multiPrice = multiPrice
            self.amenities = amenities
            self.price = price
            self.type = type
            self.isExternal = isExternal
            self.reservationFee = reservationFee
            self.isInUse = isInUse
            self.onlineStatus = onlineStatus
            self.isReserved = isReserved
            self.configured = configured
            self.bookedByCurrentUser = bookedByCurrentUser
            self.usedByCurrentUser = usedByCurrentUser
            self.isGoogle = isGoogle
            self.weekDays = weekDays
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let intValue = try? container.decode(Int.self, forKey: .sessionLimitType) {
            sessionLimitType = intValue.description
        } else {
            sessionLimitType = (try? container.decodeIfPresent(String.self, forKey: .sessionLimitType)) ?? ""
        }
        if let strPrice = try? container.decodeIfPresent(String.self, forKey: .price), let doublePrice = Float(strPrice) {
            price = doublePrice
        } else {
            price = (try? container.decodeIfPresent(Float.self, forKey: .price)) ?? 0.0
        }
        
        if let strRating = try? container.decodeIfPresent(String.self, forKey: .rating), let floatRating = Float(strRating) {
            rating = floatRating
        } else {
            rating = (try? container.decodeIfPresent(Float.self, forKey: .rating)) ?? 0.0
        }
        
        title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        openTime = (try? container.decodeIfPresent(String.self, forKey: .openTime)) ?? ""
        closeTime = (try? container.decodeIfPresent(String.self, forKey: .closeTime)) ?? ""
        contactNumber = (try? container.decodeIfPresent(String.self, forKey: .contactNumber)) ?? ""
        latitude = (try? container.decodeIfPresent(String.self, forKey: .latitude)) ?? ""
        longitude = (try? container.decodeIfPresent(String.self, forKey: .longitude)) ?? ""
        category = (try? container.decodeIfPresent(String.self, forKey: .category)) ?? ""
        listed = (try? container.decodeIfPresent(Bool.self, forKey: .listed)) ?? false
        sessionLimitValue = (try? container.decodeIfPresent(Double.self, forKey: .sessionLimitValue)) ??
                              (Double((try? container.decodeIfPresent(String.self, forKey: .sessionLimitValue)) ?? "") ?? 0.0)
        if let intId = try? container.decodeIfPresent(Int.self, forKey: .id) {
            self.id = String(intId)
        } else if let stringId = try? container.decodeIfPresent(String.self, forKey: .id) {
            self.id = stringId
        } else {
            self.id = ""
        }
        identifier = (try? container.decodeIfPresent(String.self, forKey: .identifier)) ?? ""
        priceUnit = (try? container.decodeIfPresent(String.self, forKey: .priceUnit)) ?? ""
        token = (try? container.decodeIfPresent(String.self, forKey: .token)) ?? ""
        connectors = (try? container.decodeIfPresent([Connector].self, forKey: .connectors)) ?? []
        address = (try? container.decodeIfPresent(StationAddress.self, forKey: .address))
        description = (try? container.decodeIfPresent(String.self, forKey: .description)) ?? ""
        if let doubleValue = try? container.decode(Double.self, forKey: .totalSessionsTime) {
            totalSessionsTime = Int(doubleValue)
        } else if let intValue = try? container.decode(Int.self, forKey: .totalSessionsTime) {
            totalSessionsTime = intValue
        } else {
            totalSessionsTime = 0
        }
        totalEnergy = (try? container.decodeIfPresent(Double.self, forKey: .totalEnergy)) ?? 0.0
        if let strPrice = try? container.decodeIfPresent(String.self, forKey: .totalEarnings), let doublePrice = Double(strPrice) {
            totalEarnings = doublePrice
        } else {
            totalEarnings = (try? container.decodeIfPresent(Double.self, forKey: .totalEarnings)) ?? 0.0
        }
        multiPrice = (try? container.decodeIfPresent(Bool.self, forKey: .multiPrice)) ?? false
        amenities = (try? container.decodeIfPresent([Amenity].self, forKey: .amenities)) ?? []
        
        type = (try? container.decodeIfPresent(ChargerType.self, forKey: .type)) ?? .init(id: 0, name: "", img: "", currentType: "", maxPower: "")
        isExternal = (try? container.decodeIfPresent(Bool.self, forKey: .isExternal)) ?? false
        
        if let strReservation = try? container.decodeIfPresent(String.self, forKey: .reservationFee), let floatPrice = Float(strReservation) {
            reservationFee = floatPrice
        } else {
            reservationFee = (try? container.decodeIfPresent(Float.self, forKey: .reservationFee)) ?? 0.0
        }
        isInUse = (try? container.decodeIfPresent(Bool.self, forKey: .isInUse)) ?? false
        if let strOnlineStatus = try? container.decodeIfPresent(String.self, forKey: .onlineStatus) {
            onlineStatus = Int(strOnlineStatus) ?? 0
        } else {
            onlineStatus = (try? container.decodeIfPresent(Int.self, forKey: .onlineStatus)) ?? 0
        }
        isReserved = (try? container.decodeIfPresent(Bool.self, forKey: .isReserved)) ?? false
        configured = (try? container.decodeIfPresent(Int.self, forKey: .configured)) ?? 0
        bookedByCurrentUser = (try? container.decodeIfPresent(Bool.self, forKey: .bookedByCurrentUser)) ?? false
        usedByCurrentUser = (try? container.decodeIfPresent(Bool.self, forKey: .usedByCurrentUser)) ?? false
    }
}

struct ActiveSession: Codable {
    let chargePoint: ChargePoint?
    let id: Int
    let userId: Int
    let status: Int
    let price: Float
    let appFees: Float
    let paymentType: String
    let deliveryDate: String
    let createdAt: String
    let requestedQuantity: String
    let chargingSessionEnergy: Double
    let quantity: String
    let unit: String
    let unitPrice: Float
    let prices: [Prices]?
    
    enum CodingKeys: String, CodingKey {
        case chargePoint = "charge_point"
        case id
        case userId = "user_id"
        case status
        case price
        case appFees = "app_fees"
        case paymentType = "payment_type"
        case deliveryDate = "delivery_date"
        case createdAt = "created_at"
        case requestedQuantity = "requested_quantity"
        case chargingSessionEnergy = "charging_session_energy"
        case quantity
        case unit
        case unitPrice = "unit_price"
        case prices
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        chargePoint = try? container.decodeIfPresent(ChargePoint.self, forKey: .chargePoint)
        id = try container.decode(Int.self, forKey: .id)
        
        if let strUserId = try? container.decodeIfPresent(String.self, forKey: .userId) {
            userId = Int(strUserId) ?? 0
        } else {
            userId = (try? container.decodeIfPresent(Int.self, forKey: .userId)) ?? 0
        }
        
        if let strStatus = try? container.decodeIfPresent(String.self, forKey: .status) {
            status = Int(strStatus) ?? 0
        } else {
            status = (try? container.decodeIfPresent(Int.self, forKey: .status)) ?? 0
        }
        
        paymentType = (try? container.decodeIfPresent(String.self, forKey: .paymentType)) ?? ""
        deliveryDate = (try? container.decodeIfPresent(String.self, forKey: .deliveryDate)) ?? ""
        createdAt = (try? container.decodeIfPresent(String.self, forKey: .createdAt)) ?? ""
        requestedQuantity = (try? container.decodeIfPresent(String.self, forKey: .requestedQuantity)) ?? ""
        
        if let strPrice = try? container.decodeIfPresent(String.self, forKey: .price), let floatPrice = Float(strPrice) {
            price = floatPrice
        } else {
            price = (try? container.decodeIfPresent(Float.self, forKey: .price)) ?? 0.0
        }
        
        if let strAppFees = try? container.decodeIfPresent(String.self, forKey: .appFees), let floatAppFees = Float(strAppFees) {
            appFees = floatAppFees
        } else {
            appFees = (try? container.decodeIfPresent(Float.self, forKey: .appFees)) ?? 0.0
        }
        
        if let energy = try? container.decodeIfPresent(String.self, forKey: .chargingSessionEnergy), let doubleAppFees = Double(energy) {
            chargingSessionEnergy = doubleAppFees
        } else {
            chargingSessionEnergy = (try? container.decodeIfPresent(Double.self, forKey: .chargingSessionEnergy)) ?? 0.0
        }
        
        quantity = (try? container.decodeIfPresent(String.self, forKey: .quantity)) ?? ""
        unit = (try? container.decodeIfPresent(String.self, forKey: .unit)) ?? ""
        
        if let strUnitPrice = try? container.decodeIfPresent(String.self, forKey: .unitPrice), let floatUnitPrice = Float(strUnitPrice) {
            unitPrice = floatUnitPrice
        } else {
            unitPrice = (try? container.decodeIfPresent(Float.self, forKey: .unitPrice)) ?? 0.0
        }
        
        prices = try? container.decodeIfPresent([Prices].self, forKey: .prices)
    }
}

struct Prices: Codable {
    let quantity: Int?
    let id: Int
    var price: Double

    enum CodingKeys: String, CodingKey {
        case quantity
        case id
        case price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quantity = try? container.decode(Int.self, forKey: .quantity)
        id = try container.decode(Int.self, forKey: .id)
        if let strPrice = try? container.decodeIfPresent(String.self, forKey: .price), let floatPrice = Double(strPrice) {
            price = floatPrice
        } else {
            price = (try? container.decodeIfPresent(Double.self, forKey: .price)) ?? 0.0
        }
    }
}
