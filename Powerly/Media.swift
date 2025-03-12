//
//  Media.swift
//  PowerShare
//
//  Created by ADMIN on 31/07/23.
//  
//

import Foundation

struct Media: Codable {
    let id: Int
    let title: String?
    let updatedAt: String
    let url: String
    let type: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case updatedAt = "updated_at"
        case url
        case type
        case createdAt = "created_at"
    }
}
