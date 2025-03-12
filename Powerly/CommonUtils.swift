import CoreLocation
import FirebaseAnalytics
import Foundation
import Photos
import UIKit

class CommonUtils {
    class func getStringFromPlist(_ keyName: String?) -> String {
        let mainBundle = Bundle.main
        return mainBundle.object(forInfoDictionaryKey: keyName ?? "") as? String ?? ""
    }
    
    class func getCommonRequestParam() -> [String: Any] {
        var dic = [String: Any]()
        dic["device_version"] = UIDevice.current.systemVersion
        dic["device_type"] = "2"
        dic["app_type"] = "3"
        dic["device_model"] = UIDevice().type.rawValue
        dic["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if let userid = UserSessionManager.shared.getUserId() {
            dic["user_id"] = userid
        }
        return dic
    }
    
    class func getCurrentLanguage() -> String {
        if let languageType = userDefault.object(forKey: UserDefaultKey.languageType.rawValue) as? String {
            return languageType
        }
        return "en"
    }
    
    class func getStringFromXML(name: String) -> String {
        return DELEGATE?.languageStrings[name] as? String ?? ""
    }
    
    class func updateShowVerifiedCPDefault() {
        let currentStatus = isShowVerifiedCPOnly
        userDefault.setValue(!currentStatus, forKey: UserDefaultKey.kSavedIsShowVerifiedCP.rawValue)
        userDefault.synchronize()
    }
    
    class func lastPageSaved(name: String) {
        userDefault.set(name, forKey: UserDefaultKey.kUserLastSavedKey.rawValue)
        userDefault.synchronize()
    }
    
    class func getLastPageSaved() -> String {
        if userDefault.object(forKey: UserDefaultKey.kUserLastSavedKey.rawValue) != nil {
            return userDefault.object(forKey: UserDefaultKey.kUserLastSavedKey.rawValue) as? String ?? ""
        }
        return ""
    }
    
    class func validateEmail(with email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    class func logFacebookCustomEvents(
        _ eventName: String,
        contentType parameter: [String: String]
    ) {
        var commonParams = ["device": "iOS"]
        if let userid = UserManager.shared.user?.id {
            commonParams["userid"] = userid.description
        }
        commonParams = commonParams.merge(dict: parameter)
        Analytics.logEvent(eventName, parameters: commonParams)
    }
    
    class func showProgressHud() {
        DispatchQueue.main.async {
            LoadingIndicatorView.show()
        }
    }
    
    class func hideProgressHud() {
        DispatchQueue.main.async {
            LoadingIndicatorView.hide()
        }
    }
    
    class func getCurrentCustomerType() -> String {
        if let customerType = UserManager.shared.user?.customerType {
            return customerType
        }
        return "C"
    }
    
    class func getCurrency() -> String {
        if let currency = userDefault.object(forKey: UserDefaultKey.kUserDefaultCurrency.rawValue) as? String {
            return currency
        } else {
            if let currency = UserManager.shared.user?.currency {
                return currency
            }
        }
        return ""
    }
    
    class func isUserLoggedIn() -> Bool {
        return (UserSessionManager.shared.getSession() == nil) ? false:true
    }
    
    class func validatePhone(_ phoneNumber: String?) -> Bool {
        let phoneRegex = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    class func isValidPassword(_ passwordString: String?) -> Bool {
        let stricterFilterString = "^.*(?=.{6,16})(?=.*\\d)(?=.*[a-z])(?=[A-Z]*)(?=[@#$!&]*).*$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        return passwordTest.evaluate(with: passwordString)
    }
    
    class func alertViewAttributedString(_ body: NSMutableAttributedString?, viewcontroller: UIViewController?) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.setValue(body, forKey: "attributedMessage")

        let ok = UIAlertAction(title: CommonUtils.getStringFromXML(name: "options_Ok"), style: .default, handler: nil)
        alertController.addAction(ok)
        viewcontroller?.present(alertController, animated: true, completion: nil)
    }
    
    class func getCurrentUserBalance() -> Double {
        if userDefault.object(forKey: UserDefaultKey.kUserDefaultBalance.rawValue) != nil {
            if let balance = userDefault.object(forKey: UserDefaultKey.kUserDefaultBalance.rawValue) as? String {
                return Double(balance) ?? 0.0
            }
            return userDefault.object(forKey: UserDefaultKey.kUserDefaultBalance.rawValue) as? Double ?? 0.0
        } else {
            return 0.0
        }
    }
    
    class func setCurrentUserBalance(_ balance: String) {
        userDefault.set(balance, forKey: UserDefaultKey.kUserDefaultBalance.rawValue)
        userDefault.synchronize()
    }
    
    class func setViewControllerToRoot(controller: UIViewController) {
        DELEGATE?.window?.rootViewController = controller
    }
    class func navigationToController(controllers: [UIViewController]) {
        guard let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController else {
            return
        }
        navVC.setNavigationBarHidden(true, animated: true)
        navVC.viewControllers = controllers
        DELEGATE?.window?.rootViewController = navVC
    }
    
    class func navigationToController() -> UINavigationController {
        guard let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: NavigationViewController.className) as? NavigationViewController else {
            return UINavigationController()
        }
        navVC.setNavigationBarHidden(true, animated: true)
        navVC.modalPresentationStyle = .fullScreen
        return navVC
    }
    
    class func getTabBarView() -> TabViewController? {
        if let navVC = DELEGATE?.window?.rootViewController as? UINavigationController {
            return navVC.viewControllers.first as? TabViewController
        }
        return nil
    }
    
    class func distanceBetweenTwoLocations(source: CLLocation, destination: CLLocation) -> Double {
        let distanceMeters = source.distance(from: destination)
        let distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM
        return roundedTwoDigit
    }
    
    class func isTimeWithinRange(currentTime: Date, openTime: Date, closeTime: Date) -> Bool {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentTime)
        let currentMinute = calendar.component(.minute, from: currentTime)
        let openHour = calendar.component(.hour, from: openTime)
        let openMinute = calendar.component(.minute, from: openTime)
        let closeHour = calendar.component(.hour, from: closeTime)
        let closeMinute = calendar.component(.minute, from: closeTime)
        
        if currentHour > openHour && currentHour < closeHour {
            return true
        } else if currentHour == openHour && currentMinute >= openMinute {
            return true
        } else if currentHour == closeHour && currentMinute < closeMinute {
            return true
        }
        
        return false
    }
    
    class func getTimeDifference(startDate: Date, endDate: Date) -> (hours: Int, minutes: Int, seconds: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        return (hours, minutes, seconds)
    }
    
    class func getTimeDifferenceInMinutes(startDate: Date, endDate: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        return (Double((hours*60) + minutes) + (Double(seconds)/60.0))
    }
    
    static func requestGalleryPermission() async throws {
        let status = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        switch status {
        case .authorized:
            break
            
        case .denied, .restricted:
            throw ImageSaveError.permissionDenied
            
        case .notDetermined:
            throw ImageSaveError.permissionNotDetermined
            
        case .limited:
            break
            
        @unknown default:
            throw ImageSaveError.unknownError
        }
    }
    
    static func saveImageToGallery(_ image: UIImage) async throws {
        try await requestGalleryPermission()
        
        do {
            let _ = try await withCheckedThrowingContinuation { continuation in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, _ in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: ImageSaveError.saveError)
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    static func createQR(for qrString: String?, withSize size: CGSize = CGSize(width: 512, height: 512)) -> UIImage? {
        guard let qrString = qrString, let stringData = qrString.data(using: .isoLatin1) else {
            return nil
        }
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        
        if let outputImage = qrFilter?.outputImage {
            let scale = size.width / outputImage.extent.size.width
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
            if let cgImage = CIContext().createCGImage(transformedImage, from: transformedImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                return uiImage
            }
        }
        
        return nil
    }
    
    static func generateRandomFiveDigitString() -> String {
        let randomNumber = Int(arc4random_uniform(90000)) + 10000
        return String(randomNumber)
    }
    
    static func allCarColors() -> [CarColor] {
        return [
            CarColor(id: 1, name: "White", hex: "#FFFFFF", isLight: true),
            CarColor(id: 2, name: "Black", hex: "#000000"),
            CarColor(id: 3, name: "Silver", hex: "#C0C0C0"),
            CarColor(id: 4, name: "Gray", hex: "#808080"),
            CarColor(id: 5, name: "Blue", hex: "#0000FF"),
            CarColor(id: 6, name: "Red", hex: "#FF0000"),
            CarColor(id: 7, name: "Green", hex: "#008000"),
            CarColor(id: 8, name: "Brown", hex: "#A52A2A"),
            CarColor(id: 9, name: "Beige", hex: "#F5F5DC", isLight: true),
            CarColor(id: 10, name: "Yellow", hex: "#FFFF00"),
            CarColor(id: 11, name: "Orange", hex: "#FFA500"),
            CarColor(id: 12, name: "Gold", hex: "#FFD700"),
            CarColor(id: 13, name: "Purple", hex: "#800080"),
            CarColor(id: 14, name: "Bronze", hex: "#CD7F32"),
            CarColor(id: 15, name: "Charcoal", hex: "#36454F"),
            CarColor(id: 16, name: "Maroon", hex: "#800000"),
            CarColor(id: 17, name: "Navy", hex: "#000080"),
            CarColor(id: 18, name: "Dark Blue", hex: "#00008B"),
            CarColor(id: 19, name: "Dark Gray", hex: "#A9A9A9"),
            CarColor(id: 20, name: "Light Gray", hex: "#D3D3D3"),
            CarColor(id: 21, name: "Dark Green", hex: "#006400"),
            CarColor(id: 22, name: "Light Green", hex: "#90EE90"),
            CarColor(id: 23, name: "Dark Red", hex: "#8B0000"),
            CarColor(id: 24, name: "Light Red", hex: "#FF6347"),
            CarColor(id: 25, name: "Dark Silver", hex: "#696969"),
            CarColor(id: 26, name: "Light Silver", hex: "#D8D8D8"),
            CarColor(id: 27, name: "Dark Brown", hex: "#5B3B0A"),
            CarColor(id: 28, name: "Light Brown", hex: "#D2B48C"),
            CarColor(id: 29, name: "Dark Beige", hex: "#D2B48C"),
            CarColor(id: 30, name: "Light Beige", hex: "#F5F5DC", isLight: true)
        ]
    }
    
    static func generateRandomNumber(lowerBound: Int, upperBound: Int) -> Int {
        return Int.random(in: lowerBound...upperBound)
    }
    
    struct ChargePointStatus {
        let statusText: String
        let statusImage: UIImage?
        let primaryColor: UIColor?
        let secondaryColor: UIColor?
        let iconImage: UIImage?
    }

    static func getCorrectStatus(chargePoint: ChargePoint) -> ChargePointStatus {
        if chargePoint.onlineStatus == 0 {
            return ChargePointStatus(
                statusText: NSLocalizedString("Unavailable", comment: ""),
                statusImage: UIImage(named: "wifi.exclamationmark"),
                primaryColor: UIColor(named: "E6352B"),
                secondaryColor: UIColor(named: "222222"),
                iconImage: UIImage(named: "unavailable")
            )
        } else if chargePoint.isInUse {
            if chargePoint.usedByCurrentUser {
                return ChargePointStatus(
                    statusText: NSLocalizedString("used_by_you", comment: ""),
                    statusImage: UIImage(named: "bolt.badge.clock"),
                    primaryColor: UIColor(named: "E6352B"),
                    secondaryColor: UIColor(named: "222222"),
                    iconImage: UIImage(named: "bolt.badge.clock")
                )
            }
            return ChargePointStatus(
                statusText: NSLocalizedString("busy", comment: ""),
                statusImage: UIImage(named: "bolt.badge.clock"),
                primaryColor: UIColor(named: "E6352B"),
                secondaryColor: UIColor(named: "222222"),
                iconImage: UIImage(named: "bolt.badge.clock")
            )
        } else if chargePoint.isReserved {
            return ChargePointStatus(
                statusText: NSLocalizedString("booked", comment: ""),
                statusImage: UIImage(named: "bolt.badge.clock"),
                primaryColor: UIColor(named: "E6352B"),
                secondaryColor: UIColor(named: "222222"),
                iconImage: UIImage(named: "bolt.badge.clock")
            )
        } else if chargePoint.bookedByCurrentUser {
            return ChargePointStatus(
                statusText: NSLocalizedString("booked_by_you", comment: ""),
                statusImage: UIImage(named: "bolt.badge.clock"),
                primaryColor: UIColor(named: "E6352B"),
                secondaryColor: UIColor(named: "222222"),
                iconImage: UIImage(named: "bolt.badge.clock")
            )
        }
        return ChargePointStatus(
            statusText: "",
            statusImage: nil,
            primaryColor: .black,
            secondaryColor: UIColor(named: "008CE9"),
            iconImage: nil
        )
    }
    
    static func callGetPowerSourceApiByIdentifier(identifier: String, viewController: UIViewController) {
        if !CommonUtils.isUserLoggedIn() {
            return
        }
        CommonUtils.showProgressHud()
        NetworkManager().getPowerSourceByIdentifier(identifier: identifier) { success, message, powerSource in
            CommonUtils.hideProgressHud()
            if success == 1 {
                viewController.tabBarController?.selectedIndex = 0
                if let powerSource = powerSource {
                    if let storeListVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: PowerSourceDetailViewController.className) as? PowerSourceDetailViewController {
                        storeListVC.viewModel = ChargePointDetailViewModel(chargePoint: powerSource)
                        storeListVC.modalPresentationStyle = .overFullScreen
                        viewController.present(storeListVC, animated: true, completion: nil)
                    }
                }
            } else {
                TSMessage.showNotification(withTitle: "", subtitle: message, type: .error)
            }
        }
    }
    
    class func generateMerchantReference() -> String {
        let random = "\(Int(Date().timeIntervalSince1970 * 1000))D\(generateRandomNumericString(length: 5))"
        if random.count > 15 {
            return String(random.suffix(15))
        }
        return random
    }
    
    static func generateRandomNumericString(length: Int) -> String {
        let numbers = "0123456789"
        return String((0..<length).map { _ in numbers.randomElement()! })
    }
    
    class func getFullAddress(from address: StationAddress) -> String {
        var components: [String] = []
        
        if let addressLine1 = address.addressLine1, !addressLine1.isEmpty {
            components.append(addressLine1)
        }
        if let addressLine2 = address.addressLine2, !addressLine2.isEmpty {
            components.append(addressLine2)
        }
        if let addressLine3 = address.addressLine3, !addressLine3.isEmpty {
            components.append(addressLine3)
        }
        if let city = address.city, !city.isEmpty {
            components.append(city)
        }
        if let state = address.state, !state.isEmpty {
            components.append(state)
        }
        if let zipcode = address.zipcode, !zipcode.isEmpty {
            components.append(zipcode)
        }
        
        return components.joined(separator: ", ")
    }
}

enum ImageSaveError: Error {
    case permissionDenied
    case permissionNotDetermined
    case unknownError
    case saveError
}
