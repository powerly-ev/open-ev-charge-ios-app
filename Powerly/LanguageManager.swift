//
//  LanguageManager.swift
//  PowerShare
//
//  Created by ADMIN on 05/08/23.
//  
//

import Foundation

class LanguageManager {
    static let shared = LanguageManager()
    
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        Bundle.swizzleLocalization()
    }
}

extension Bundle {
    static func swizzleLocalization() {
        object_setClass(Bundle.main, CustomBundle.self)
    }
}

private class CustomBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let currentLanguage = UserDefaults.standard.value(forKey: UserDefaultKey.languageType.rawValue) as? String,
            let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}
