//
//  EmailViewModel.swift
//  Powerly
//
//  Created by ADMIN on 18/05/24.
//  
//

import Foundation

struct EmailViewModel {
    var email: String?
    var verificationInfo: VerificationInfo?
    
    func checkEmailExist (email: String) async throws -> (Bool, Bool) {
        if let response = try? await NetworkManager().emailCheck(email: email) {
            if response.success == 1 {
                let json = response.json
                let emailExists = json["data"]["email_exists"].boolValue
                let requireVerification = json["data"]["require_verification"].boolValue
                return (emailExists, requireVerification)
            }
        }
        return (false, true)
    }
    
    func registerByEmail(register: RegisterEmail) async throws -> (Int, String?, VerificationInfo?) {
        if let response = try? await NetworkManager().registerByEmail(register: register) {
            if response.success == 1 {
                return (response.success, nil, response.data)
            } else {
                return (response.success, response.message, nil)
            }
        }
        return (0, nil, nil)
    }

    func verifyEmail(email: String, code: String) async throws -> (Int, String?, Customer?) {
        if let response = try? await NetworkManager().verifyEmail(email: email, code: code) {
            if response.success == 1 {
                return (response.success, nil, response.data)
            } else {
                return (response.success, response.message, nil)
            }
        }
        return (0, nil, nil)
    }
    
    func resetEmail(token: String, code: String) async throws -> (Int, String?, Customer?) {
        if let response = try? await NetworkManager().verifyResetEmail(token: token, code: code) {
            if response.success == 1 {
                return (response.success, nil, response.data)
            } else {
                return (response.success, response.message, nil)
            }
        }
        return (0, nil, nil)
    }
    
    func loginByEmail(email: String, password: String, completion: @escaping (Int, String?, Customer?, VerificationInfo?) -> Void) {
        NetworkManager().loginEmail(email: email, password: password) { status, response in
            let success = response["success"].intValue
            let message = response["message"].stringValue
            
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? response["data"].rawData() {
                    if status == 200, let customerResponse = try? decoder.decode(Customer.self, from: jsonData) {
                        completion(success, message, customerResponse, nil)
                    } else if status == 202, let verificationResponse = try? decoder.decode(VerificationInfo.self, from: jsonData) {
                        completion(success, message,nil, verificationResponse)
                    } else {
                        completion(success, message,nil, nil)
                    }
                }
            } else {
                completion(success, message,nil, nil)
            }
        }
    }
    
    func resendEmailVerification(email: String) async throws -> (Int, String?, VerificationInfo?) {
        if let response = try? await NetworkManager().resendEmailVerification(email: email) {
            if response.success == 1 {
                return (response.success, nil, response.data)
            } else {
                return (response.success, response.message, nil)
            }
        }
        return (0, nil, nil)
    }
    
    func socialLogin(type: SocialType, idToken: String, countryId: String) async throws -> (Int, String?, Customer?) {
        if let response = try? await NetworkManager().socialLogin(type: type, idToken: idToken, countryId: countryId) {
            if response.success == 1 {
                return (response.success, nil, response.data)
            } else {
                return (response.success, response.message, nil)
            }
        }
        return (0, nil, nil)
    }
    
    func resetPassword(code: String, email: String, password: String) async throws -> (Int, String?, VerificationInfo?) {
        if let response = try? await NetworkManager().resetPassword(code: code, email: email, password: password) {
            if response.success == 1 {
                return (response.success, response.message, response.data)
            } else {
                return (response.success, response.message, response.data)
            }
        }
        return (0, nil, nil)
    }
    
    func forgotPassword(email: String) async throws -> (Int, String?, VerificationInfo?) {
        if let response = try? await NetworkManager().forgotPassword(email: email) {
            if response.success == 1 {
                return (response.success, response.message, response.data)
            } else {
                return (response.success, response.message, response.data)
            }
        }
        return (0, nil, nil)
    }
    
    func getCountryId() -> String {
        if let country = UserManager.shared.country {
            return country.id.description
        }
        return ""
    }
    
    func getCountry() -> Country? {
        if let country = UserManager.shared.country {
            return country
        }
        return nil
    }
}


public struct RegisterEmail {
    let email: String
    let password: String
    let countryId: Int
    let deviceImei: String
    let deviceToken: String
}
