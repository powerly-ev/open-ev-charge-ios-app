//  Created by admin on 15/10/21.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

public enum OpensourceAPI {
    case checkAppVersion
    case determineMethod(String)
    case signin([String: String])
    case registration([String: Any])
    case countryList
    case currencies
    case getBalances(Int?)
    case getDefaultCard
    case setDefaultCard(String)
    case getFeedbackReasons
    case getCards
    case deleteCard(String)
    case addCard([String: Any])
    case editCard([String: Any])
    case updateDeviceInfo([String: Any])
    case logout([String: Any])
    case refillBalance([String: Any])
    case serviceCheck
    case deleteUser(String)
    case maintenanceMode
    case powerSourceReview(String)
    case getPowerSourceMediaList(String)
    
    // powershare api
    case getEVConnectors(String)
    case getEVAmenities
    case getPowerSources(Bool?, Bool?)
    case getPowerSource(String)
    case startTransaction(String, String, [Connector])
    case stopTransaction(String, Int, Int)
    case activeSession
    case completedSession(Int)
    case getPowerSourceByIdentifier(String)
    case getPowerSourceNearest(String, String, Int)
    case addReviewToOrders(Int, Float, String)
    case getSessionDetailByOrderId(Int)
    case addMediaToPowerSource(String, String, [Data])
    case deleteMediaFromPowersource(String, Int)
    case skipReviewForOrder(Int)
    case addRequestedPowerSource([String: Any])
    case powerSourceCredentials(String)
    case loginQRCodeURL(String)
    
    // Vehicle api
    case getMakeList
    case getModelList(Int)
    case addVehicle([String: Any])
    case updateVehicle(Int, [String: Any])
    case getVehicleList
    case deleteVehicle(Int)
    
    // Auth
    case emailCheck(String)
    case loginByEmail(String, String)
    case registerByEmail(RegisterEmail)
    case verifyEmail(String, String)
    case resetVerify(String, String)
    case resendEmailVerification(String)
    case getUsers
    case socialLogin(SocialType, String, String?)
    case updateUsers(Int, UpdateProfile)
    case resetPassword(String, String, String)
    case forgotPassword(String)
    case authCheck
    
    case getWallets
    case requestPayout
}

extension OpensourceAPI: TargetType {
    public var baseURL: URL {
        switch self {
        default:
            return URL(string: CommonUtils.getStringFromPlist("BASE_URL"))!
        }
    }

    public var path: String {
        switch self {
        case .checkAppVersion:
            return "check_app_version"
            
        case .determineMethod:
            return "determine_method"
            
        case .signin:
            return "sign_in"
            
        case .registration:
            return "registration"
            
        case .countryList:
            return "countries"
            
        case .currencies:
            return "countries/currencies"

        case .getBalances:
            return "balance/offers"
            
        case .getDefaultCard:
            return "payment-cards/default"
            
        case .setDefaultCard(let id):
            return "payment-cards/default/\(id)"
            
        case .getFeedbackReasons:
            return "reviews/options"
            
        case .getCards:
            return "payment-cards"
            
        case .deleteCard(let id):
            return "payment-cards/\(id)"
            
        case .addCard:
            return "payment-cards"
            
        case .editCard:
            return "edit_card"
            
        case .updateDeviceInfo:
            return "device"
            
        case .logout:
            return "auth/logout"
            
        case .refillBalance:
            return "balance/top-up"
            
        case .serviceCheck:
            return "service_check"
            
        case .deleteUser(let id):
            return "users/\(id)"
            
        case .maintenanceMode:
            return "maintenance_mode"
            
        case .getEVConnectors:
            return "vehicles/connectors"
            
        case .getEVAmenities:
            return "power-source/amenities"
            
        case .getPowerSources:
            return "power-source"
            
        case .getPowerSource(let id):
            return "stations/\(id)"
            
        case .startTransaction:
            return "orders"
            
        case .stopTransaction:
            return "orders/stop"
            
        case .activeSession:
            return "orders"
            
        case .completedSession:
            return "orders"
            
        case .getPowerSourceByIdentifier(let identifier):
            return "stations/token/\(identifier)"
            
        case .getPowerSourceNearest:
            return "stations"
            
        case .addReviewToOrders(let orderId, _, _):
            return "orders/\(orderId)/review"
            
        case .powerSourceReview(let chargeId):
            return "stations/\(chargeId)/reviews"
            
        case .getSessionDetailByOrderId(let orderId):
            return "orders/\(orderId)"
            
        case .addMediaToPowerSource(let chargeId, _, _):
            return "power-source/\(chargeId)/media"
            
        case .getPowerSourceMediaList(let chargeId):
            return "stations/\(chargeId)/media"
            
        case .deleteMediaFromPowersource(let chargeId, let mediaId):
            return "power-source/\(chargeId)/media/\(mediaId)"
            
        case .skipReviewForOrder(let orderId):
            return "orders/\(orderId)/review/skip"
            
        case .addRequestedPowerSource:
            return "power-source/request"
            
        case .getMakeList:
            return "vehicles/makes"
            
        case .getModelList(let makeId):
            return "vehicles/models/\(makeId)"
            
        case .addVehicle:
            return "vehicles"
            
        case .getVehicleList:
            return "vehicles"
            
        case .deleteVehicle(let id):
            return "vehicles/\(id)"
            
        case .updateVehicle(let id, _):
            return "vehicles/\(id)"
            
        case .powerSourceCredentials(let id):
            return "power-source/owner/\(id)/credentials"
            
        case .loginQRCodeURL:
            return "login-qrcode-url"
            
        case .emailCheck:
            return "auth/email/check"
            
        case .loginByEmail:
            return "auth/login"
            
        case .registerByEmail:
            return "auth/register"
            
        case .verifyEmail:
            return "auth/email/verify"
            
        case .resendEmailVerification:
            return "auth/resend-verification"
            
        case .getUsers:
            return "users/me"
            
        case .socialLogin(let type, _, _):
            return "auth/\(type.rawValue)"
            
        case .updateUsers:
            return "users/me"
            
        case .resetPassword:
            return "auth/password/reset"
            
        case .forgotPassword:
            return "auth/password/forgot"
            
        case .authCheck:
            return "auth/check"
            
        case .resetVerify:
            return "auth/password/reset/verify"
            
        case .getWallets:
            return "wallets"
            
        case .requestPayout:
            return "request-payout"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .getEVConnectors, .getEVAmenities, .getPowerSources, .getPowerSource, .activeSession, .completedSession, .getPowerSourceByIdentifier, .getPowerSourceNearest, .getMakeList, .getModelList, .powerSourceReview, .getFeedbackReasons, .getPowerSourceMediaList, .getVehicleList, .powerSourceCredentials, .getSessionDetailByOrderId, .countryList, .getUsers, .getCards, .authCheck, .getDefaultCard, .getBalances, .getWallets, .currencies:
            return .get
            
        case .deleteMediaFromPowersource, .deleteVehicle, .deleteCard, .deleteUser:
            return .delete
            
        case .updateVehicle, .updateUsers, .skipReviewForOrder, .updateDeviceInfo:
            return .put
            
        default:
            return .post
        }
    }

    public var task: Task {
        switch self {
        case .checkAppVersion:
            return .requestParameters(parameters: CommonUtils.getCommonRequestParam(), encoding: URLEncoding.default)
            
        case .updateUsers(_, let updateProfile):
            var dic = CommonUtils.getCommonRequestParam()
            if let firstName = updateProfile.firstName {
                dic["first_name"] = firstName
            }
            if let lastName = updateProfile.lastName {
                dic["last_name"] = lastName
            }
            if let vatId = updateProfile.vatId {
                dic["vat_id"] = vatId
            }
            if let password = updateProfile.password {
                dic["password"] = password
            }
            if let countryId = updateProfile.countryId {
                dic["country_id"] = countryId
            }
            if let currency = updateProfile.currency {
                dic["currency"] = currency
            }
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .determineMethod(let contactNumber):
            var dic = CommonUtils.getCommonRequestParam()
            dic["user_type"] = "1"
            dic["contact_number"] = contactNumber
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .signin(let param):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: param)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .registration(let param):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: param)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .addCard(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .editCard(let params):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: params)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .updateDeviceInfo(let params):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: params)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .logout(let params):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: params)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
               
        case .refillBalance(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .serviceCheck:
            let dic = CommonUtils.getCommonRequestParam()
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .maintenanceMode:
            let dic = CommonUtils.getCommonRequestParam()
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
        
        case .getPowerSources(let owner, let listed):
            var dic = [String: Any]()
            if let owner = owner {
                dic["owner"] = owner
            }
            if let listed = listed {
                dic["listed"] = listed
            }
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .getEVConnectors(let category):
            return .requestParameters(parameters: ["category": category, "search": ""], encoding: URLEncoding.default)
            
        case .startTransaction(let id, let quantity, let connectors):
            var dic = CommonUtils.getCommonRequestParam()
            dic["power_source_id"] = id
            dic["quantity"] = quantity
            if let connector = connectors.first {
                dic["connector"] = connector.number
            }
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .completedSession(let page):
            return .requestParameters(parameters: ["page": page, "status": "complete"], encoding: URLEncoding.default)
            
        case .stopTransaction(let id, let orderId, let number):
            return .requestParameters(parameters: ["power_source_id": id, "order_id": orderId], encoding: URLEncoding.default)
            
        case .getPowerSourceNearest(let latitude, let longitude, let limit):
            return .requestParameters(parameters: ["latitude": latitude, "longitude": longitude, "limit": limit], encoding: URLEncoding.default)
            
        case .activeSession:
            return .requestParameters(parameters: ["status": "active"], encoding: URLEncoding.default)
            
        case .getEVAmenities, .getPowerSource, .getPowerSourceByIdentifier, .getFeedbackReasons, .getSessionDetailByOrderId, .getPowerSourceMediaList, .deleteMediaFromPowersource, .skipReviewForOrder, .getVehicleList, .getMakeList, .powerSourceReview, .getModelList, .deleteVehicle, .powerSourceCredentials, .authCheck, .getDefaultCard, .getUsers, .deleteUser, .deleteCard, .getCards, .setDefaultCard, .countryList, .getWallets, .requestPayout, .currencies:
            return .requestPlain
            
        case .getBalances(let countryId):
            if let countryId = countryId {
                return .requestParameters(parameters: ["country_id": countryId], encoding: URLEncoding.default)
            } else {
                return .requestPlain
            }
            
        case .addReviewToOrders(_, let rating, let review):
            var dic: [String: Any] = CommonUtils.getCommonRequestParam()
            dic["rating"] = rating
            dic["content"] = review
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .addMediaToPowerSource(_, _, let medias):
            var count = 0
            var multipart = [MultipartFormData]()
            for media in medias {
                multipart.append(MultipartFormData(provider: .data(media), name: "media[\(count)]", fileName: CommonUtils.generateRandomFiveDigitString() + ".jpg", mimeType: "image/jpg"))
                count += 1
            }
            return .uploadCompositeMultipart(multipart, urlParameters: [:])
            
        case .addRequestedPowerSource(let params), .addVehicle(let params):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: params)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .updateVehicle(_, let params):
            let dic = CommonUtils.getCommonRequestParam().merge(dict: params)
            return .requestParameters(parameters: dic, encoding: URLEncoding.default)
            
        case .loginQRCodeURL(let token):
            return .requestParameters(parameters: ["token": token], encoding: URLEncoding.default)
            
        case .emailCheck(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
            
        case .loginByEmail(let email, let password):
            return .requestParameters(parameters: ["email": email, "password": password, "device_imei": UserSessionManager.shared.getUUID(), "device_token": DELEGATE?.deviceToken ?? ""], encoding: URLEncoding.default)

        case .registerByEmail(let register):
            return .requestParameters(parameters: ["email": register.email, "password": register.password, "country_id": register.countryId, "device_imei": register.deviceImei, "device_token": register.deviceToken], encoding: URLEncoding.default)
            
        case .verifyEmail(let email, let code):
            return .requestParameters(parameters: ["email": email, "code": code], encoding: URLEncoding.default)
            
        case .resendEmailVerification(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
    
        case .socialLogin(_, let token, let countryId):
            var params = ["jwt_token": token, "device_imei": UserSessionManager.shared.getUUID(), "device_token": DELEGATE?.deviceToken ?? ""]
            if let countryId = countryId {
                params["country_id"] = countryId
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .resetPassword(let code, let email, let password):
            return .requestParameters(parameters: ["code": code, "email": email, "password": password, "password_confirmation": password], encoding: URLEncoding.default)
            
        case .forgotPassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)

        case .resetVerify(let token, let code):
            return .requestParameters(parameters: ["verification_token": token, "verification_code": code], encoding: URLEncoding.default)
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .checkAppVersion:
            return .successCodes
            
        default:
            return .none
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    public var headers: [String: String]? {
        var commonParameter: [String: String] = ["Accept-Language": isLanguageType, "App-Type": "3", "App-Version": (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""), "Device-Type": "2", "Device-Model": UIDevice().type.rawValue, "Device-Version": UIDevice.current.systemVersion]
        let openApiKey = CommonUtils.getStringFromPlist("OPEN_API_KEY")
        if openApiKey != "" {
            commonParameter["API-KEY"] = openApiKey
        }
        if let token = UserSessionManager.shared.getSession()?.accessToken {
            commonParameter["Authorization"] = "Bearer \(token)"
        }
        return commonParameter
    }
}

public func url(_ route: TargetType) -> String {
    route.baseURL.appendingPathComponent(route.path).absoluteString
}

// MARK: - Response Handlers

extension Moya.Response {
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}
