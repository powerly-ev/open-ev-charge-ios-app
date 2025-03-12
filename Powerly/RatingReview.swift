//
//  RatingReview.swift
//  PowerShare
//
//  Created by ADMIN on 27/07/23.
//  
//

import Foundation

struct ReviewObject: Codable {
    let overall: String
    let countPerRating: [CountRating]
    let totalCount: Int
    let detailed: [RatingReview]
    
    enum CodingKeys: String, CodingKey {
        case overall
        case countPerRating = "count_per_rating"
        case totalCount = "total_count"
        case detailed
    }
}

struct CountRating: Codable {
    let count: Int
    let rating: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let strCount = try? container.decodeIfPresent(String.self, forKey: .count) {
            count = Int(strCount) ?? 0
        } else {
            count = (try? container.decodeIfPresent(Int.self, forKey: .count)) ?? 0
        }
        if let strRating = try? container.decodeIfPresent(String.self, forKey: .rating) {
            rating = Int(strRating) ?? 0
        } else {
            rating = (try? container.decodeIfPresent(Int.self, forKey: .rating)) ?? 0
        }
    }
}

struct RatingReview: Codable {
    let rating: String
    let orderId: Int
    let id: Int
    let content: String
    let createdAt: String
    let updatedAt: String
    var user: ReviewUser?
    
    enum CodingKeys: String, CodingKey {
        case rating
        case orderId = "order_id"
        case id
        case content = "content"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rating = try container.decodeIfPresent(String.self, forKey: .rating) ?? ""
        
        if let strOrderId = try? container.decodeIfPresent(String.self, forKey: .orderId) {
            orderId = Int(strOrderId) ?? 0
        } else {
            orderId = (try? container.decodeIfPresent(Int.self, forKey: .orderId)) ?? 0
        }
        
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
        user = try container.decodeIfPresent(ReviewUser.self, forKey: .user) ?? nil
    }
}

struct ReviewUser: Codable {
    let id: Int
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    var fullName: String {
            [firstName, lastName].compactMap { $0 }.joined(separator: " ")
        }
}

