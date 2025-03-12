//
//  VerificationResponse.swift
//  Powerly
//
//  Created by ADMIN on 20/05/24.
//  
//

import Foundation


struct VerificationInfo: Codable {
    let requireVerification: Int
    let verificationToken: String
    let canResendInSeconds: Int
    let availableAttempts: Int
    let sentTo: String

    enum CodingKeys: String, CodingKey {
        case requireVerification = "require_verification"
        case verificationToken = "verification_token"
        case canResendInSeconds = "can_resend_in_seconds"
        case availableAttempts = "available_attempts"
        case sentTo = "sent_to"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        requireVerification = (try? container.decodeIfPresent(Int.self, forKey: .requireVerification)) ?? 0
        verificationToken = (try? container.decodeIfPresent(String.self, forKey: .verificationToken)) ?? ""
        canResendInSeconds = (try? container.decodeIfPresent(Int.self, forKey: .canResendInSeconds)) ?? 0
        availableAttempts = (try? container.decodeIfPresent(Int.self, forKey: .availableAttempts)) ?? 0
        sentTo = (try? container.decodeIfPresent(String.self, forKey: .sentTo)) ?? ""
    }
}
