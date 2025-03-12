//
//  NSObject.swift
//  PowerShare
//
//  Created by admin on 23/10/21.

//
import CommonCrypto
import Foundation
import UIKit

extension NSObject {
    class var className: String {
        if let className = String(describing: self).components(separatedBy: ".").last {
            return className
        } else {
            fatalError("There's something wrong with your code, please check it before trying again!")
        }
    }
}

extension UIImage {
    func templateImage() -> UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
}

extension Date {
    func getFormattedDate(format: String, timeZone: TimeZone? = nil, language: String? = nil) -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.dateFormat = format
        if let language = language {
            dateformat.locale = Locale(identifier: language)
        }
        if let timeZone = timeZone {
            dateformat.timeZone = timeZone
        }
        return dateformat.string(from: self)
    }
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Dictionary {
    /// Merges the current dictionary with another dictionary.
    /// If both dictionaries have a value for the same key, the value from the other dictionary is used.
    ///
    /// - Parameter other: The dictionary to merge with.
    /// - Returns: A new dictionary with the merged values.
    func merge(dict: [Key: Value]) -> [Key: Value] {
        var mutableCopy = self
        for (key, value) in dict {
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}

extension Data {
    public func sha256() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }
        
        return hexString
    }
}

public extension String {
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}

extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version: String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return ""
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension Array {
    func value(at index: Int) -> Element? {
        guard index >= 0, index < count else {
            return nil
        }
        return self[index]
    }
}
