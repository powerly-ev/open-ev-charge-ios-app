//
//  User.swift
//  PowerShare
//
//  Created by admin on 18/12/21.

//

import Foundation
import SwiftyJSON

enum UserType: Int {
    case customer = 1
    case distributor = 2
}

public enum SocialType: String {
    case google
    case apple
}

public struct User: Codable {
    var contactNumber: String = ""
    var currencyIso: String = ""
    var customerType: String = ""
    var email: String = ""
    var lastName: String = ""
    var latitude: String = ""
    var loginSmsVerificationTimeoutMins: Int = 0
    var longitude: String = ""
    var currencyCountryId: Int?
    var recurringId: String = ""
    var id: Int?
    var userId: Int?
    var firstName: String = ""
    var userType: Int = 0
    var currency: String = ""
    var totalBalance: String = ""
    var vatId = ""
    var maintenanceMode: Bool = false
    var haveToWaitInMinutes: Int = 0
    var location: Location?
    var countryId: Int?
    init() {
    }
    enum CodingKeys: String, CodingKey {
        case contactNumber = "contact_number"
        case currencyIso = "currency_iso"
        case customerType = "customer_type"
        case email
        case lastName = "last_name"
        case latitude
        case loginSmsVerificationTimeoutMins = "login_sms_verification_timeout_mins"
        case longitude
        case currencyCountryId = "currency_country_id"
        case recurringId = "recurring_id"
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case userType = "user_type"
        case currency
        case totalBalance = "balance"
        case vatId = "vat_id"
        case maintenanceMode = "maintenance_mode"
        case haveToWaitInMinutes = "have_to_wait_in_minutes"
        case location
        case countryId = "country_id"
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contactNumber = decodeIfPresent(String.self, from: values, forKey: .contactNumber, defaultValue: "")
        currencyIso = decodeIfPresent(String.self, from: values, forKey: .currencyIso, defaultValue: "")
        customerType = decodeIfPresent(String.self, from: values, forKey: .customerType, defaultValue: "")
        email = decodeIfPresent(String.self, from: values, forKey: .email, defaultValue: "")
        lastName = decodeIfPresent(String.self, from: values, forKey: .lastName, defaultValue: "")
        latitude = decodeIfPresent(String.self, from: values, forKey: .latitude, defaultValue: "")
        loginSmsVerificationTimeoutMins = decodeIfPresent(Int.self, from: values, forKey: .loginSmsVerificationTimeoutMins, defaultValue: 0)
        longitude = decodeIfPresent(String.self, from: values, forKey: .longitude, defaultValue: "")
        currencyCountryId = decodeIfPresent(Int.self, from: values, forKey: .currencyCountryId, defaultValue: 0)
        recurringId = decodeIfPresent(String.self, from: values, forKey: .recurringId, defaultValue: "")
        id = decodeIfPresent(Int.self, from: values, forKey: .id, defaultValue: 0)
        userId = decodeUserID(from: values, forKey: .userId)
        firstName = decodeIfPresent(String.self, from: values, forKey: .firstName, defaultValue: "")
        userType = decodeIfPresent(Int.self, from: values, forKey: .userType, defaultValue: 0)
        currency = decodeIfPresent(String.self, from: values, forKey: .currency, defaultValue: "")
        totalBalance = decodeIfPresent(String.self, from: values, forKey: .totalBalance, defaultValue: "")
        vatId = decodeIfPresent(String.self, from: values, forKey: .vatId, defaultValue: "")
        maintenanceMode = decodeIfPresent(Bool.self, from: values, forKey: .maintenanceMode, defaultValue: false)
        haveToWaitInMinutes = decodeIfPresent(Int.self, from: values, forKey: .haveToWaitInMinutes, defaultValue: 0)
        location = try? values.decodeIfPresent(Location.self, forKey: .location)
        countryId = try? values.decodeIfPresent(Int.self, forKey: .countryId)
    }
    private func decodeUserID(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Int? {
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        } else {
            return nil
        }
    }
    
    private func decodeIfPresent<T>(_ type: T.Type, from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys, defaultValue: T) -> T where T: Decodable {
        if let value = try? container.decodeIfPresent(type, forKey: key) {
            return value
        } else {
            return defaultValue
        }
    }
}

struct Customer: Codable {
    var balance: String
    var id: Int
    var customerType: String
    var lastName: String
    var email: String
    var fullName: String
    var accessToken: String
    var contactNumber: String
    var firstName: String

    enum CodingKeys: String, CodingKey {
        case balance
        case id
        case customerType = "customer_type"
        case lastName = "last_name"
        case email
        case fullName = "full_name"
        case accessToken = "access_token"
        case contactNumber = "contact_number"
        case firstName = "first_name"
    }

    // Initializer with default values
    init(balance: String = "0.00", 
         id: Int = 0, 
         customerType: String = "C",
         lastName: String = "", 
         email: String = "",
         fullName: String = "",
         accessToken: String = "",
         contactNumber: String = "",
         firstName: String = "") {
        self.balance = balance
        self.id = id
        self.customerType = customerType
        self.lastName = lastName
        self.email = email
        self.fullName = fullName
        self.accessToken = accessToken
        self.contactNumber = contactNumber
        self.firstName = firstName
    }

    // Custom initializer for handling type changes and setting default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.balance = (try? container.decode(String.self, forKey: .balance)) ?? "0.00"
        self.id = (try? container.decode(Int.self, forKey: .id)) ?? 0
        self.customerType = (try? container.decode(String.self, forKey: .customerType)) ?? "C"
        self.lastName = (try? container.decode(String.self, forKey: .lastName)) ?? ""
        self.email = (try? container.decode(String.self, forKey: .email)) ?? ""
        self.fullName = (try? container.decode(String.self, forKey: .fullName)) ?? ""
        self.accessToken = (try? container.decode(String.self, forKey: .accessToken)) ?? ""
        self.contactNumber = (try? container.decode(String.self, forKey: .contactNumber)) ?? ""
        self.firstName = (try? container.decode(String.self, forKey: .firstName)) ?? ""
    }
}

struct Country_New: Codable {
    var timeZone: String
    var iso: String
    var id: Int
    var currencyISO: String
    var flagURL: String
    var phoneCode: String
    var email: String
    var currency: String
    var name: String
    var contactNumber: String

    enum CodingKeys: String, CodingKey {
        case timeZone = "time_zone"
        case iso
        case id
        case currencyISO = "currency_iso"
        case flagURL = "flag_url"
        case phoneCode = "phone_code"
        case email
        case currency
        case name
        case contactNumber = "contact_number"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeZone = try container.decodeIfPresent(String.self, forKey: .timeZone) ?? ""
        iso = try container.decodeIfPresent(String.self, forKey: .iso) ?? ""
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        currencyISO = try container.decodeIfPresent(String.self, forKey: .currencyISO) ?? ""
        flagURL = try container.decodeIfPresent(String.self, forKey: .flagURL) ?? ""
        phoneCode = try container.decodeIfPresent(String.self, forKey: .phoneCode) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        contactNumber = try container.decodeIfPresent(String.self, forKey: .contactNumber) ?? ""
    }
}

struct City_New: Codable {
    var id: Int
    var name: String
    var countryID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryID = "country_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        countryID = try container.decodeIfPresent(Int.self, forKey: .countryID) ?? 0
    }
}

struct Location: Codable {
    var country: Country_New?
    var latitude: String
    var longitude: String
    var city: City_New?
    var address: String

    enum CodingKeys: String, CodingKey {
        case country
        case latitude
        case longitude
        case city
        case address
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        country = try container.decodeIfPresent(Country_New.self, forKey: .country)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude) ?? ""
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude) ?? ""
        city = try container.decodeIfPresent(City_New.self, forKey: .city)
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
    }
}
