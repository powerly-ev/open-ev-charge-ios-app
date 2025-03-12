//
//  Response.swift
//  PowerShare
//
//  Created by ADMIN on 10/08/23.
//  
//

import Foundation
import SwiftyJSON

struct Response {
    let success: Int
    let message: String
    let json: JSON
}

struct ApiResponse<T: Codable>: Codable {
    let success: Int
    let msg: String?
    let results: T?
    
    enum CodingKeys: String, CodingKey {
        case success
        case msg
        case results
    }
}

struct NewResponse<T: Codable>: Codable {
    let success: Int
    let message: String?
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

struct GenericApiResponse<T: Codable, T1: Codable>: Codable {
    let success: Int
    let message: String
    let data: T?
    let errors: T1?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data 
        case errors
    }
}

protocol JSONConvertible {
    associatedtype JsonConvertible
    
    static func fromJSON(json: JSON) -> JsonConvertible
    func toJSON() -> JSON
}

extension JSONConvertible {
    func toJSON() -> JSON {
        let jsonDict = [String: Any]()
        return JSON(jsonDict)
    }
}
