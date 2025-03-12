//
//  KeychainHelper.swift
//  Powerly
//
//  Created by ADMIN on 22/12/23.

import Foundation
import Security

class KeychainHelper {
    
    // MARK: - Get
    
    class func getValue(forKey key: String) -> String? {
        var query = keychainQuery(withKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        if status == errSecSuccess {
            if let data = result as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
        }
        
        return nil
    }
    
    // MARK: - Set
    
    class func setValue(_ value: String, forKey key: String) -> Bool {
        if let data = value.data(using: .utf8) {
            var query = keychainQuery(withKey: key)
            query[kSecValueData as String] = data

            SecItemDelete(query as CFDictionary)

            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }

        return false
    }
    
    // MARK: - Delete
    
    class func deleteValue(forKey key: String) -> Bool {
        let query = keychainQuery(withKey: key)
        let status = SecItemDelete(query as CFDictionary)
        if #available(iOS 11.3, *) {
            if let errSecValue = SecCopyErrorMessageString(status, nil) {
                let errorMessage = String(errSecValue)
                print("Keychain Error: \(errorMessage)")
            }
        } else {
            // Fallback on earlier versions
        }
        return status == errSecSuccess
    }

    // MARK: - Private
    
    private class func keychainQuery(withKey key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
//            kSecMatchLimit as String  : kSecMatchLimitOne,
            kSecAttrAccount as String: key
        ]
    }
    
    class func getValue(forKey key: String, accessGroup: String? = nil) -> String? {
            var query = keychainQuery(withKey: key, accessGroup: accessGroup)
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnData as String] = kCFBooleanTrue

            var result: AnyObject?
            let status = withUnsafeMutablePointer(to: &result) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }

            if status == errSecSuccess {
                if let data = result as? Data, let value = String(data: data, encoding: .utf8) {
                    return value
                }
            }
        if #available(iOS 11.3, *) {
            if let errSecValue = SecCopyErrorMessageString(status, nil) {
                let errorMessage = String(errSecValue)
                print("Keychain Error: \(errorMessage)")
            }
        } else {
            // Fallback on earlier versions
        }

            return nil
        }
        
        // MARK: - Set
        
        class func setValue(_ value: String, forKey key: String, accessGroup: String? = nil) -> Bool {
            if let data = value.data(using: .utf8) {
                var query = keychainQuery(withKey: key, accessGroup: accessGroup)
                query[kSecValueData as String] = data

                let status = SecItemAdd(query as CFDictionary, nil)
                return status == errSecSuccess
            }

            return false
        }
        
        // MARK: - Delete
        
        class func deleteValue(forKey key: String, accessGroup: String? = nil) -> Bool {
            let query = keychainQuery(withKey: key, accessGroup: accessGroup)
            let status = SecItemDelete(query as CFDictionary)
            return status == errSecSuccess
        }

        // MARK: - Private
        
        private class func keychainQuery(withKey key: String, accessGroup: String? = nil) -> [String: Any] {
            var query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
//                kSecMatchLimit as String  : kSecMatchLimitOne,
                kSecAttrService as String: key,
                kSecAttrAccount as String: key
            ]

            if let accessGroup = accessGroup {
                query[kSecAttrAccessGroup as String] = accessGroup
            }

            return query
        }
}
