//
//  NetworkManager.swift
//  Created by admin on 18/10/21.
//
import Foundation
import Moya
import Reachability
import SwiftyJSON

typealias GenericNetworkCompletion = (_ json: JSON?, _ error: Error?) -> Void
typealias GenericNetworkStatusCompletion = (_ status: Int, _ json: JSON?, _ error: Error?) -> Void

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

public enum APIError: Error {
    case invalidResponse
    case decodingError
    case apiFailure(message: String)
}

struct NetworkManager {
    func maintenanceMode(completion: @escaping (Int, String, JSON) -> Void) {
        performAPIRequest(request: .maintenanceMode) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func jsonNilMessage() -> String {
        return CommonUtils.getStringFromXML(name: "check_internet_connection")
    }
    
    static func jsonNilMessage() -> String {
        return CommonUtils.getStringFromXML(name: "check_internet_connection")
    }
    
    func deleteUser(id: String, completion: @escaping (Int, String) -> Void) {
        CommonUtils.showProgressHud()
        performAPIRequest(request: .deleteUser(id)) { json, _ in
            CommonUtils.hideProgressHud()
            guard let json = json else {
                completion(0, jsonNilMessage())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message)
        }
    }
    
    func serviceCheck(completion: @escaping (Int, String, JSON) -> Void) {
        performAPIRequest(request: .serviceCheck) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func refillBalance(params: [String: Any], completion: @escaping (Int, String, JSON) -> Void) {
        performAPIRequest(request: .refillBalance(params)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func logout(params: [String: Any], completion: @escaping (Int, String, JSON) -> Void) {
        performAPIRequest(request: .logout(params)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func updateDeviceInfo(params: [String: Any], completion: @escaping (Int, String, JSON) -> Void) {
        CommonUtils.showProgressHud()
        performAPIRequest(request: .updateDeviceInfo(params)) { json, _ in
            CommonUtils.hideProgressHud()
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func editCard(params: [String: Any], completion: @escaping (Int, String, JSON) -> Void) {
        CommonUtils.showProgressHud()
        performAPIRequest(request: .editCard(params)) { json, _ in
            CommonUtils.hideProgressHud()
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func addCard(params: [String: Any], completion: @escaping (Int, String, JSON) -> Void) {
        CommonUtils.showProgressHud()
        performAPIRequest(request: .addCard(params)) { json, _ in
            CommonUtils.hideProgressHud()
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func deleteCard(cardId: String, completion: @escaping (Int, String, JSON) -> Void) {
        CommonUtils.showProgressHud()
        performAPIRequest(request: .deleteCard(cardId)) { json, _ in
            CommonUtils.hideProgressHud()
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func getCards(completion: @escaping (Int, String, [Card]) -> Void) {
        performAPIRequest(request: .getCards) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [Card]())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let results = json["data"]
                var cardList = [Card]()
                if let resultsArray = results.array {
                    cardList = resultsArray.map({ return Card.fromJSON(json: $0) })
                }
                completion(sucess, message, cardList)
            } else {
                completion(sucess, message, [Card]())
            }
        }
    }
    
    func getStaticReviewMessage() async throws -> NewResponse<[String: [String]]>? {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .getFeedbackReasons) { (apiResponse: NewResponse<[String: [String]]>?, _, _) in
                return continuation.resume(returning: apiResponse)
            }
        }
    }
    
    func setDefaultCard(cardId: String, completion: @escaping (Int, String) -> Void) {
        CommonUtils.showProgressHud()
        performAPIRequest(request: .setDefaultCard(cardId)) { json, _ in
            CommonUtils.hideProgressHud()
            guard let json = json else {
                completion(0, jsonNilMessage())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message)
        }
    }
    
    func getDefaultCard(completion: @escaping (Int, String, Card?) -> Void) {
        performAPIRequest(request: .getDefaultCard) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), nil)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let results = json["results"]
                let card = Card.fromJSON(json: results)
                completion(sucess, message, card)
            } else {
                completion(sucess, message, nil)
            }
        }
    }
    
    func getBalances(countryId: Int?, completion: @escaping (Int, String, [Balance]?) -> Void) {
        performAPIRequest(request: .getBalances(countryId)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [Balance]())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let results = json["data"]
                var balanceList = [Balance]()
                if let resultsArray = results.array {
                    balanceList = resultsArray.map({ return Balance.fromJSON(json: $0) })
                }
                completion(sucess, message, balanceList)
            } else {
                completion(sucess, message, [Balance]())
            }
        }
    }
    
    func countryList(completion: @escaping (Int, String, [Country]) -> Void) {
        performAPIRequest(request: .countryList) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [Country]())
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let results = json["data"]
                var countryList = [Country]()
                if let resultsArray = results.array {
                    countryList = resultsArray.map({ return Country.fromJSON(json: $0) })
                }
                completion(sucess, message, countryList)
            } else {
                completion(sucess, message, [Country]())
            }
        }
    }
    
    func currencyList(completion: @escaping (Int, String, [Currency]) -> Void) {
        performAPIRequest(request: .currencies) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [Currency]())
                return
            }
            let success = json["success"].intValue
            let message = json["message"].stringValue
            if success == 1 {
                let decoder = JSONDecoder()
                do {
                    let jsonData = try json["data"].rawData()
                    let activeSessions = try decoder.decode([Currency].self, from: jsonData)
                    completion(success, message, activeSessions)
                } catch {
                    debugPrint("Decoding error: \(error)")
                    completion(success, "Data decoding failed", [])
                }
                if let jsonData = try? json["data"].rawData(),
                   let activeSessions = try? decoder.decode([Currency].self, from: jsonData) {
                    completion(success, message, activeSessions)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [Currency]())
            }
        }
    }
    
    func register(param: [String: Any], completion: @escaping (JSON) -> Void) {
        performAPIRequest(request: .registration(param)) { json, _ in
            guard let json = json else {
                completion(JSON())
                return
            }
            completion(json)
        }
    }
    
    func signIn(param: [String: String], completion: @escaping (JSON) -> Void) {
        performAPIRequest(request: .signin(param)) { json, _ in
            guard let json = json else {
                completion(JSON())
                return
            }
            completion(json)
        }
    }
    
    func determineMethod(contactNumber: String, completion: @escaping (JSON) -> Void) {
        performAPIRequest(request: .determineMethod(contactNumber)) { json, _ in
            guard let json = json else {
                completion(JSON())
                return
            }
            completion(json)
        }
    }
    
    func userDetails() async throws -> NewResponse<User>? {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .getUsers) { (apiResponse: NewResponse<User>?, _, _) in
                return continuation.resume(returning: apiResponse)
            }
        }
    }
    
    func authCheck() async throws -> (NewResponse<User>?, Bool) {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .authCheck) { (apiResponse: NewResponse<User>?, _, tokenRefresh) in
                return continuation.resume(returning: (apiResponse, tokenRefresh))
            }
        }
    }
    
    func updateProfile(updateProfile: UpdateProfile, completion: @escaping (Response) -> Void) {
        guard let userId = UserManager.shared.user?.id else {
            completion(Response(success: 0, message: jsonNilMessage(), json: JSON.null))
            return
        }
        performAPIRequest(request: .updateUsers(userId, updateProfile)) { json, _ in
            guard let json = json else {
                completion(Response(success: 0, message: jsonNilMessage(), json: JSON.null))
                return
            }
            let success = json["success"].intValue
            let message = json["message"].stringValue
            completion(Response(success: success, message: message, json: json))
        }
    }
    
    func updateProfile(updateProfile: UpdateProfile) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            guard let userId = UserManager.shared.user?.id else {
                continuation.resume(throwing: APIError.apiFailure(message: jsonNilMessage()))
                return
            }
            performAPIRequest(request: .updateUsers(userId, updateProfile)) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: jsonNilMessage()))
                    return
                }
                let sucess = json["success"].intValue
                let message = json["message"].stringValue
                continuation.resume(returning: Response(success: sucess, message: message, json: json))
            }
        }
    }
    
    func checkAppVersion(completion: @escaping (Int, String) -> Void) {
        performAPIRequest(request: .checkAppVersion) { json, _ in
            guard let json = json else {
                return
            }
            let sucess = json["success"].intValue
            if sucess == 1 {
                let result = json["results"]
                let needToUpdate = result["need_to_update"].intValue
                let actualVersion = result["actual_version_app"].stringValue
                completion(needToUpdate, actualVersion)
            }
        }
    }
    
    func getEvConnectors(category: String, completion: @escaping (Int, String, [Connector]) -> Void) {
        performAPIRequest(request: .getEVConnectors(category)) { json, _ in
            guard let json = json else {
                return
            }
            let success = json["success"].intValue
            let message = json["message"].stringValue
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let makeList = try? decoder.decode([Connector].self, from: jsonData) {
                    completion(success, message, makeList)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [Connector]())
            }
        }
    }
    
    func getEvAmenities(completion: @escaping (Int, String, [Amenity]) -> Void) {
        performAPIRequest(request: .getEVAmenities) { json, _ in
            guard let json = json else {
                return
            }
            let success = json["success"].intValue
            let message = json["message"].stringValue
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["results"].rawData(),
                   let makeList = try? decoder.decode([Amenity].self, from: jsonData) {
                    completion(success, message, makeList)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [Amenity]())
            }
        }
    }
    
    func getPowerSource(id: String, completion: @escaping (Int, String, ChargePoint?) -> Void) {
        performAPIRequest(request: .getPowerSource(id)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), nil)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let chargePoint = try? decoder.decode(ChargePoint.self, from: jsonData) {
                    completion(sucess, message, chargePoint)
                } else {
                    completion(sucess, message, nil)
                }
            } else {
                completion(sucess, message, nil)
            }
        }
    }
    
    func getPowerSourceCredential(id: String) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .powerSourceCredentials(id)) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: "failed"))
                    return
                }
                let sucess = json["success"].intValue
                let message = json["message"].stringValue
                continuation.resume(returning: Response(success: sucess, message: message, json: json))
            }
        }
    }
    
    func getPowerSources(owner: Bool?, listed: Bool?, completion: @escaping (Int, String, [ChargePoint]) -> Void) {
        performAPIRequest(request: .getPowerSources(owner, listed)) { json, _ in
            guard let json = json else {
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["results"].rawData(),
                   let chargePoints = try? decoder.decode([ChargePoint].self, from: jsonData) {
                    completion(sucess, message, chargePoints)
                } else {
                    completion(sucess, message, [])
                }
            } else {
                completion(sucess, message, [])
            }
        }
    }
    
    func startTransaction(id: String, quantity: String, connectors: [Connector]) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .startTransaction(id, quantity, connectors)) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: "failed"))
                    return
                }
                let sucess = json["success"].intValue
                let message = json["message"].stringValue
                continuation.resume(returning: Response(success: sucess, message: message, json: json))
            }
        }
    }
    
    func stopTransaction(id: String, orderId: Int, completion: @escaping (Int, String, SwiftyJSON.JSON) -> Void) {
        performAPIRequest(request: .stopTransaction(id, orderId, 1)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON.null)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func activeSession(completion: @escaping (Int, String, [ActiveSession]) -> Void) {
        performAPIRequest(request: .activeSession) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let activeSessions = try? decoder.decode([ActiveSession].self, from: jsonData) {
                    completion(sucess, message, activeSessions)
                } else {
                    completion(sucess, message, [])
                }
            } else {
                completion(sucess, message, [])
            }
        }
    }
    
    func completedSession(page: Int, completion: @escaping (Int, String, [ActiveSession]) -> Void) {
        performAPIRequest(request: .completedSession(page)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                do {
                    let jsonData = try json["data"].rawData()
                    let activeSessions = try decoder.decode([ActiveSession].self, from: jsonData)
                    completion(sucess, message, activeSessions)
                } catch {
                    completion(sucess, message, [])
                }
            } else {
                completion(sucess, message, [])
            }
        }
    }
    
    func getPowerSourceByIdentifier(identifier: String, completion: @escaping (Int, String, ChargePoint?) -> Void) {
        performAPIRequest(request: .getPowerSourceByIdentifier(identifier)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), nil)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let chargePoint = try? decoder.decode(ChargePoint.self, from: jsonData) {
                    completion(sucess, message, chargePoint)
                } else {
                    completion(sucess, message, nil)
                }
            } else {
                completion(sucess, message, nil)
            }
        }
    }
    
    func getSessionByOrderId(orderId: Int, completion: @escaping (Int, String, ActiveSession?) -> Void) {
        performAPIRequest(request: .getSessionDetailByOrderId(orderId)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), nil)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let activeSession = try? decoder.decode(ActiveSession.self, from: jsonData) {
                    completion(sucess, message, activeSession)
                } else {
                    completion(sucess, message, nil)
                }
            } else {
                completion(sucess, message, nil)
            }
        }
    }
    
    func getPowerSourcesNearest(latitude: String, longitude: String, limit: Int, completion: @escaping (Int, String, [ChargePoint]) -> Void) {
        performAPIRequest(request: .getPowerSourceNearest(latitude, longitude, limit)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            
            let success = json["success"].intValue
            let message = json["message"].stringValue
            if success == 1 {
                let decoder = JSONDecoder()
                do {
                    let jsonData = try json["data"].rawData()
                    let chargePoints = try decoder.decode([ChargePoint].self, from: jsonData)
                    completion(success, message, chargePoints)
                } catch {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [])
            }
        }
    }
    
    func getMakeList(completion: @escaping (Int, String, [Make]) -> Void) {
        performAPIRequest(request: .getMakeList) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            if sucess == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let makeList = try? decoder.decode([Make].self, from: jsonData) {
                    completion(sucess, message, makeList)
                } else {
                    completion(sucess, message, [])
                }
            } else {
                completion(sucess, message, [Make]())
            }
        }
    }
    
    func getModelList(makeId: Int, completion: @escaping (Int, String, [VehicleModel]) -> Void) {
        performAPIRequest(request: .getModelList(makeId)) { json, _ in
            // Handle API request error
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            
            let success = json["success"].intValue
            let message = json["message"].stringValue
            
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let makeList = try? decoder.decode([VehicleModel].self, from: jsonData) {
                    completion(success, message, makeList)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [])
            }
        }
    }
    
    func addPowerSourceReview(orderId: Int, rating: Float, review: String, completion: @escaping (Int, String, JSON) -> Void) {
        performAPIRequest(request: .addReviewToOrders(orderId, rating, review)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON.null)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func addPowerSourceSkipReview(orderId: Int, completion: @escaping (Int, String, JSON) -> Void) {
        performAPIRequest(request: .skipReviewForOrder(orderId)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON.null)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func powerSourceReviews(chargeId: String, completion: @escaping (Int, String, [RatingReview]) -> Void) {
        performAPIRequest(request: .powerSourceReview(chargeId)) { json, _ in
            // Handle API request error
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            
            let success = json["success"].intValue
            let message = json["message"].stringValue
            
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let makeList = try? decoder.decode([RatingReview].self, from: jsonData) {
                    completion(success, message, makeList)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [])
            }
        }
    }
    
    func loginQRCodeUrl(token: String) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .loginQRCodeURL(token)) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: jsonNilMessage()))
                    return
                }
                let success = json["success"].intValue
                let message = json["message"].stringValue
                if success == 1 {
                    continuation.resume(returning: Response(success: success, message: message, json: json))
                } else {
                    continuation.resume(returning: Response(success: success, message: message, json: json))
                }
            }
        }
    }
    
    func addRequestPowerSource(requestPowerSource: RequestAddress, completion: @escaping (Int, String, JSON) -> Void) {
        var dic: [String: Any] = ["address": requestPowerSource.address, "city": requestPowerSource.city, "state": requestPowerSource.state, "latitude": requestPowerSource.latitude, "longitude": requestPowerSource.longitude, "address_type": requestPowerSource.addressType, "owned_address": requestPowerSource.ownedAddress]
        if requestPowerSource.ownedAddress == 0 {
            dic["contact_number"] = requestPowerSource.contactNumber
        }
        performAPIRequest(request: .addRequestedPowerSource(dic)) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), JSON.null)
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(sucess, message, json)
        }
    }
    
    func addVehicle(dic: [String: Any], completion: @escaping (Response) -> Void) {
        performAPIRequest(request: .addVehicle(dic)) { json, _ in
            guard let json = json else {
                completion(Response(success: 0, message: jsonNilMessage(), json: JSON.null))
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(Response(success: sucess, message: message, json: json))
        }
    }
    
    func updateVehicle(id: Int, dic: [String: Any], completion: @escaping (Response) -> Void) {
        performAPIRequest(request: .updateVehicle(id, dic)) { json, _ in
            guard let json = json else {
                completion(Response(success: 0, message: jsonNilMessage(), json: JSON.null))
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(Response(success: sucess, message: message, json: json))
        }
    }
    
    func deleteVehicle(id: Int, completion: @escaping (Response) -> Void) {
        performAPIRequest(request: .deleteVehicle(id)) { json, _ in
            guard let json = json else {
                completion(Response(success: 0, message: jsonNilMessage(), json: JSON.null))
                return
            }
            let sucess = json["success"].intValue
            let message = json["message"].stringValue
            completion(Response(success: sucess, message: message, json: json))
        }
    }
    
    func getVehicleList(completion: @escaping (Int, String, [Vehicle]) -> Void) {
        performAPIRequest(request: .getVehicleList) { json, _ in
            guard let json = json else {
                completion(0, jsonNilMessage(), [])
                return
            }
            
            let success = json["success"].intValue
            let message = json["message"].stringValue
            
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["data"].rawData(),
                   let makeList = try? decoder.decode([Vehicle].self, from: jsonData) {
                    completion(success, message, makeList)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [])
            }
        }
    }
    
    func emailCheck(email: String) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .emailCheck(email)) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: "failed"))
                    return
                }
                let sucess = json["success"].intValue
                let message = json["message"].stringValue
                if sucess == 1 {
                    continuation.resume(returning: Response(success: sucess, message: message, json: json))
                } else {
                    continuation.resume(returning: Response(success: sucess, message: message, json: json))
                }
            }
        }
    }
    
    func registerByEmail(register: RegisterEmail) async throws -> GenericApiResponse<VerificationInfo, [String: [String]]> {
        return try await withCheckedThrowingContinuation { continuation in
            performGenericAPIRequest(request: .registerByEmail(register)) { (apiResponse: GenericApiResponse<VerificationInfo, [String: [String]]>?, error) in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func verifyEmail(email: String, code: String) async throws -> GenericApiResponse<Customer, [String: [String]]> {
        return try await withCheckedThrowingContinuation { continuation in
            performGenericAPIRequest(request: .verifyEmail(email, code)) { (apiResponse: GenericApiResponse<Customer, [String: [String]]>?, error) in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func verifyResetEmail(token: String, code: String) async throws -> GenericApiResponse<Customer, [String: [String]]> {
        return try await withCheckedThrowingContinuation { continuation in
            performGenericAPIRequest(request: .resetVerify(token, code)) { (apiResponse: GenericApiResponse<Customer, [String: [String]]>?, error) in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func loginEmail(email: String, password: String, completion: @escaping (Int, JSON) -> Void) {
        performAPIRequestWithStatus(request: .loginByEmail(email, password)) { status, json, _ in
            guard let json = json else {
                completion(0, JSON())
                return
            }
            completion(status, json)
        }
    }
    
    func resendEmailVerification(email: String) async throws -> GenericApiResponse<VerificationInfo, [String: [String]]> {
        return try await withCheckedThrowingContinuation { continuation in
            performGenericAPIRequest(request: .resendEmailVerification(email)) { (apiResponse: GenericApiResponse<VerificationInfo, [String: [String]]>?, error) in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func socialLogin(type: SocialType, idToken: String, countryId: String) async throws -> GenericApiResponse<Customer, [String: [String]]> {
        return try await withCheckedThrowingContinuation { continuation in
            performGenericAPIRequest(request: .socialLogin(type, idToken, countryId)) { (apiResponse: GenericApiResponse<Customer, [String: [String]]>?, error) in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func resetPassword(code: String, email: String, password: String) async throws -> NewResponse<VerificationInfo> {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .resetPassword(code, email, password)) { (apiResponse: NewResponse<VerificationInfo>?, error, _)  in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func forgotPassword(email: String) async throws -> NewResponse<VerificationInfo> {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .forgotPassword(email)) { (apiResponse: NewResponse<VerificationInfo>?, error, _)  in
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func getWallets() async throws -> NewResponse<[Wallet]> {
        return try await withCheckedThrowingContinuation { continuation in
            CommonUtils.showProgressHud()
            performAPIRequest(request: .getWallets) { (apiResponse: NewResponse<[Wallet]>?, error, _) in
                CommonUtils.hideProgressHud()
                if let apiResponse = apiResponse {
                    continuation.resume(returning: apiResponse)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
                }
            }
        }
    }
    
    func reqeustPayout() async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            performAPIRequest(request: .requestPayout) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: "failed"))
                    return
                }
                let sucess = json["success"].intValue
                let message = json["message"].stringValue
                if sucess == 1 {
                    continuation.resume(returning: Response(success: sucess, message: message, json: json))
                } else {
                    continuation.resume(returning: Response(success: sucess, message: message, json: json))
                }
            }
        }
    }
    
    var provider = MoyaProvider<OpensourceAPI>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
                                                                                                 logOptions: .verbose))])
    
    func performAPIRequest(showExpiryError: Bool = true, request: OpensourceAPI, completion: @escaping GenericNetworkCompletion) {
        if !checkForConnectivity() {
            completion(nil, nil)
            return
        }
        provider.request(request) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 401:
                    if showExpiryError {
                        completion(nil, nil)
                        DELEGATE?.logoutWhenSessionExpire()
                        return
                    }
                
                case 426:
                    DELEGATE?.forceUpdatePopup()
                    return
                    
                case 429:
                    do {
                        var message = ""
                        let json: JSON
                        if let dictJSON = try response.mapJSON() as? [String: Any] {
                            json = JSON(dictJSON)
                            message = json["message"].stringValue
                        } else {
                            json = try JSON(data: response.data)
                            message = json["message"].stringValue
                        }
                        if let presentedVC = DELEGATE?.window?.rootViewController?.presentedViewController {
                            TSMessage.showNotification(in: presentedVC, title: "", subtitle: message, type: .error)
                        }
                        completion(json, nil)
                        return
                    } catch {
                        // Handle the error if JSON parsing fails
                        print("Error parsing JSON: \(error)")
                    }
                    completion(JSON(), nil)
                    return
                
                default:
                    break
                }
                do {
                    if let dictJSON = try response.mapJSON() as? [String: Any] {
                        completion(JSON(dictJSON), nil)
                    } else {
                        let json = try JSON(data: response.data)
                        completion(json, nil)
                    }
                } catch {
                    completion(nil, nil)
                }
                
            case let .failure(error):
                debugPrint(error.errorCode)
                completion(nil, error)
            }
        }
    }
    
    func performAPIRequest<T: Codable>(request: OpensourceAPI, completion: @escaping (ApiResponse<T>?, Error?) -> Void) {
        if !checkForConnectivity() {
            completion(nil, nil)
            return
        }
        provider.request(request) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 401:
                    completion(nil, nil)
                    DELEGATE?.logoutWhenSessionExpire()
                    return
                
                case 426:
                    DELEGATE?.forceUpdatePopup()
                    return
                
                case 429:
                    do {
                        let apiResponse = try response.map(NewResponse<T>.self)
                        if let presentedVC = DELEGATE?.window?.rootViewController?.presentedViewController {
                            TSMessage.showNotification(in: presentedVC, title: "", subtitle: apiResponse.message, type: .error)
                        }
                    } catch {
                    }
                    completion(nil, nil)
                    return
                    
                default:
                    break
                }
                do {
                    let apiResponse = try response.map(ApiResponse<T>.self)
                    completion(apiResponse, nil)
                } catch {
                    completion(nil, error)
                }
                
            case let .failure(error):
                debugPrint(error.errorCode)
                completion(nil, error)
            }
        }
    }
    
    func performAPIRequest<T: Codable>(request: OpensourceAPI, completion: @escaping (NewResponse<T>?, Error?, Bool) -> Void) {
        if !checkForConnectivity() {
            completion(nil, nil, false)
            return
        }
        provider.request(request) { result in
            switch result {
            case let .success(response):
                let tokenRefreshRequired = response.response?.value(forHTTPHeaderField: "token-refresh-required") ?? "0"
                if tokenRefreshRequired == "1" {
                    completion(nil, nil, true)
                    return
                }
                switch response.statusCode {
                case 401:
                    completion(nil, nil, false)
                    DELEGATE?.logoutWhenSessionExpire()
                    return
                
                case 426:
                    DELEGATE?.forceUpdatePopup()
                    return
                    
                case 429:
                    do {
                        let apiResponse = try response.map(NewResponse<T>.self)
                        if let presentedVC = DELEGATE?.window?.rootViewController?.presentedViewController {
                            TSMessage.showNotification(in: presentedVC, title: "", subtitle: apiResponse.message, type: .error)
                        }
                    } catch {
                        
                    }
                    completion(nil, nil, false)
                    return
                
                default:
                    break
                }
                do {
                    let apiResponse = try response.map(NewResponse<T>.self)
                    completion(apiResponse, nil, false)
                } catch {
                    completion(nil, error, false)
                }
                
            case let .failure(error):
                debugPrint(error.errorCode)
                completion(nil, error, false)
            }
        }
    }
    
    func performGenericAPIRequest<T: Codable, U: Codable>(request: OpensourceAPI, completion: @escaping (GenericApiResponse<T, U>?, Error?) -> Void) {
        if !checkForConnectivity() {
            completion(nil, nil)
            return
        }
        provider.request(request) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 401:
                    completion(nil, nil)
                    DELEGATE?.logoutWhenSessionExpire()
                    return
                    
                case 426:
                    DELEGATE?.forceUpdatePopup()
                    return
                    
                case 429:
                    do {
                        let apiResponse = try response.map(NewResponse<T>.self)
                        if let presentedVC = DELEGATE?.window?.rootViewController?.presentedViewController {
                            TSMessage.showNotification(in: presentedVC, title: "", subtitle: apiResponse.message, type: .error)
                        }
                    } catch {
                        completion(nil, nil)
                    }
                    return
                    
                default:
                    break
                }
                
                do {
                    let apiResponse = try response.map(GenericApiResponse<T, U>.self)
                    completion(apiResponse, nil)
                } catch {
                    completion(nil, error)
                    debugPrint(error)
                }
                
            case let .failure(error):
                debugPrint(error.errorCode)
                completion(nil, error)
            }
        }
    }

    func performAPIRequestWithStatus(showExpiryError: Bool = true, request: OpensourceAPI, completion: @escaping  GenericNetworkStatusCompletion) {
        if !checkForConnectivity() {
            completion(0, nil, nil)
            return
        }
        provider.request(request) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 401:
                    completion(response.statusCode, nil, nil)
                    DELEGATE?.logoutWhenSessionExpire()
                    return
                
                case 426:
                    DELEGATE?.forceUpdatePopup()
                    return
                    
                case 429:
                    do {
                        let json = try JSON(data: response.data)
                        let message = json["message"].stringValue
                        if let presentedVC = DELEGATE?.window?.rootViewController?.presentedViewController {
                            TSMessage.showNotification(in: presentedVC, title: "", subtitle: message, type: .error)
                        }
                    } catch {
                        // Handle the error if JSON parsing fails
                        print("Error parsing JSON: \(error)")
                    }
                    completion(response.statusCode, nil, nil)
                    return
                
                default:
                    break
                }
                do {
                    if let dictJSON = try response.mapJSON() as? [String: Any] {
                        completion(response.statusCode, JSON(dictJSON), nil)
                    } else {
                        let json = try JSON(data: response.data)
                        completion(response.statusCode, json, nil)
                    }
                } catch {
                    completion(response.statusCode, nil, nil)
                }
                
            case let .failure(error):
                debugPrint(error.errorCode)
                completion(0, nil, error)
            }
        }
    }
    
    func checkForConnectivity() -> Bool {
        do {
            let reachability = try Reachability()
            if reachability.connection == .wifi || reachability.connection == .cellular {
                return true
            }
            DELEGATE?.checkInternetConnection()
            return false
        } catch {
            return false
        }
    }
}
