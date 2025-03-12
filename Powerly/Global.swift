//
//  Global.swift
//  Created by admin on 21/10/21.
//

import Foundation
import UIKit

let DELEGATE = UIApplication.shared.delegate as? AppDelegate
var isLanguageType: String {
    return userDefault.value(forKey: UserDefaultKey.languageType.rawValue) as? String ?? "en"
}
var isLanguageArabic: Bool {
    let language = userDefault.value(forKey: UserDefaultKey.languageType.rawValue) as? String ?? "en"
    return language == "ar"
}
var isShowVerifiedCPOnly: Bool {
    let verifiedCP = userDefault.value(forKey: UserDefaultKey.kSavedIsShowVerifiedCP.rawValue) as? Bool ?? false
    return verifiedCP
}
let userDefault = UserDefaults.standard
let kVersionLabel = CommonUtils.getStringFromPlist("VERSION_LABEL")
let kGMSApiKey = CommonUtils.getStringFromPlist("GMS_API_KEY")

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height
let showSensorModule = true

enum UserDefaultKey: String {
    case languageType = "LanguageType"
    case kUserDefaultEmail = "kUserDefaultEmail"
    case kUserLastSavedKey = "last_saved_screen"
    case kUserName = "nameaccount"
    case kUserLastName = "lastnameaccount"
    case kUserDefaultBalance = "kUserDefaultBalance"
    case kUserDefaultCurrency = "kUserDefaultCurrency"
    case kSavedCurrency = "savedCurrency"
    case kSavedIsShowVerifiedCP
}

enum KeyChainkey: String {
    case accessToken
    case userId
    case uniqueIdentifier
    case storeUserOnboarding
}

enum OrderStatus: Int {
    case open = 0
    case completed = 1
}
