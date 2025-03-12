//
//  UserSessionManager.swift
//  PowerShare
//
//  Created by ADMIN on 19/08/23.
//  
//

import Foundation

struct UserSession {
    var accessToken: String
    var userId: String
}

class UserSessionManager {
    static let shared = UserSessionManager()
    
    func getUUID() -> String {
        if let uniqueIdentifier = KeychainHelper.getValue(forKey: KeyChainkey.uniqueIdentifier.rawValue, accessGroup: privateAccessToken) {
            return uniqueIdentifier
        } else {
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            _ = KeychainHelper.setValue(uuid, forKey: KeyChainkey.uniqueIdentifier.rawValue, accessGroup: privateAccessToken)
            return uuid
        }
    }

    func saveSession(_ session: UserSession) {
        _ = KeychainHelper.setValue(session.accessToken, forKey: KeyChainkey.accessToken.rawValue, accessGroup: privateAccessToken)
        _ = KeychainHelper.setValue(session.userId, forKey: KeyChainkey.userId.rawValue, accessGroup: privateAccessToken)
    }
    
    func saveUserId(_ userId: String) {
        _ = KeychainHelper.setValue(userId, forKey: KeyChainkey.userId.rawValue, accessGroup: privateAccessToken)
    }
    
    func saveToken(_ token: String) {
        _ = KeychainHelper.setValue(token, forKey: KeyChainkey.accessToken.rawValue, accessGroup: privateAccessToken)
    }
    
    func getUserId() -> String? {
        if let userId = KeychainHelper.getValue(forKey: KeyChainkey.userId.rawValue, accessGroup: privateAccessToken) {
            return userId
        }
        return nil
    }

    func getSession() -> UserSession? {
        if let accessToken = KeychainHelper.getValue(forKey: KeyChainkey.accessToken.rawValue, accessGroup: privateAccessToken),
           let userId = KeychainHelper.getValue(forKey: KeyChainkey.userId.rawValue, accessGroup: privateAccessToken) {
            return UserSession(accessToken: accessToken, userId: userId)
        }
        return nil
    }

    func clearSession() {
        _ = KeychainHelper.deleteValue(forKey: KeyChainkey.accessToken.rawValue, accessGroup: privateAccessToken)
        _ = KeychainHelper.deleteValue(forKey: KeyChainkey.userId.rawValue, accessGroup: privateAccessToken)
    }
}
