//
//  DeviceModel.swift
//  Created by admin on 19/10/21.
//

import Foundation
import UIKit

public enum Model: String {

    // Simulator
    case simulator = "simulator/sandbox"
    
    // iPod
    case iPod1 = "iPod 1"
    case iPod2 = "iPod 2"
    case iPod3 = "iPod 3"
    case iPod4 = "iPod 4"
    case iPod5 = "iPod 5"
    case iPod6 = "iPod 6"
    case iPod7 = "iPod 7"
    
    // iPad
    case iPad2 = "iPad 2"
    case iPad3 = "iPad 3"
    case iPad4 = "iPad 4"
    case iPadAir = "iPad Air"
    case iPadAir2 = "iPad Air 2"
    case iPadAir3 = "iPad Air 3"
    case iPadAir4 = "iPad Air 4"
    case iPad5 = "iPad 5" // iPad 2017
    case iPad6 = "iPad 6" // iPad 2018
    case iPad7 = "iPad 7" // iPad 2019
    case iPad8 = "iPad 8" // iPad 2020
    case iPad9 = "iPad 9" // iPad 2021
    
    // iPad Mini
    case iPadMini = "iPad Mini"
    case iPadMini2 = "iPad Mini 2"
    case iPadMini3 = "iPad Mini 3"
    case iPadMini4 = "iPad Mini 4"
    case iPadMini5 = "iPad Mini 5"
    case iPadMini6 = "iPad Mini 6"
    
    // iPad Pro
    case iPadPro97 = "iPad Pro 9.7\""
    case iPadPro105 = "iPad Pro 10.5\""
    case iPadPro11 = "iPad Pro 11\""
    case iPadPro2ndGen11 = "iPad Pro 11\" 2nd gen"
    case iPadPro3rdGen11 = "iPad Pro 11\" 3rd gen"
    case iPadPro129 = "iPad Pro 12.9\""
    case iPadPro2ndGen129 = "iPad Pro 2 12.9\""
    case iPadPro3rdGen129 = "iPad Pro 3 12.9\""
    case iPadPro4thGen129 = "iPad Pro 4 12.9\""
    case iPadPro5thGen129 = "iPad Pro 5 12.9\""
    
    // iPhone
    case iPhone4 = "iPhone 4"
    case iPhone4S = "iPhone 4S"
    case iPhone5 = "iPhone 5"
    case iPhone5S = "iPhone 5S"
    case iPhone5C = "iPhone 5C"
    case iPhone6 = "iPhone 6"
    case iPhone6Plus = "iPhone 6 Plus"
    case iPhone6S = "iPhone 6S"
    case iPhone6SPlus = "iPhone 6S Plus"
    case iPhoneSE = "iPhone SE"
    case iPhone7 = "iPhone 7"
    case iPhone7Plus = "iPhone 7 Plus"
    case iPhone8 = "iPhone 8"
    case iPhone8Plus = "iPhone 8 Plus"
    case iPhoneX = "iPhone X"
    case iPhoneXS = "iPhone XS"
    case iPhoneXSMax = "iPhone XS Max"
    case iPhoneXR = "iPhone XR"
    case iPhone11 = "iPhone 11"
    case iPhone11Pro = "iPhone 11 Pro"
    case iPhone11ProMax = "iPhone 11 Pro Max"
    case iPhoneSE2 = "iPhone SE 2nd gen"
    case iPhone12Mini = "iPhone 12 Mini"
    case iPhone12 = "iPhone 12"
    case iPhone12Pro = "iPhone 12 Pro"
    case iPhone12ProMax = "iPhone 12 Pro Max"
    case iPhone13Mini = "iPhone 13 Mini"
    case iPhone13 = "iPhone 13"
    case iPhone13Pro = "iPhone 13 Pro"
    case iPhone13ProMax = "iPhone 13 Pro Max"
    case iPhoneSE3 = "iPhone SE 3rd gen"
    case iPhone14 = "iPhone 14"
    case iPhone14Plus = "iPhone 14 Plus"
    case iPhone14Pro = "iPhone 14 Pro"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case iPhone15 = "iPhone 15"
    case iPhone15Plus = "iPhone 15 Plus"
    case iPhone15Pro = "iPhone 15 Pro"
    case iPhone15ProMax = "iPhone 15 Pro Max"
    
    // Apple Watch
    case appleWatch1 = "Apple Watch 1gen"
    case appleWatchS1 = "Apple Watch Series 1"
    case appleWatchS2 = "Apple Watch Series 2"
    case appleWatchS3 = "Apple Watch Series 3"
    case appleWatchS4 = "Apple Watch Series 4"
    case appleWatchS5 = "Apple Watch Series 5"
    case appleWatchSE = "Apple Watch Special Edition"
    case appleWatchS6 = "Apple Watch Series 6"
    case appleWatchS7 = "Apple Watch Series 7"
    
    // Apple TV
    case appleTV1 = "Apple TV 1gen"
    case appleTV2 = "Apple TV 2gen"
    case appleTV3 = "Apple TV 3gen"
    case appleTV4 = "Apple TV 4gen"
    case appleTV4K = "Apple TV 4K"
    case appleTV2ndGen4K = "Apple TV 4K 2nd gen"
    
    case unrecognized = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#
// MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String(validatingUTF8: ptr)
            }
        }
    
        let modelMap: [String: Model] = [
            // Simulator
            "i386": .simulator,
            "x86_64": .simulator,
    
            // iPod
            "iPod1,1": .iPod1,
            "iPod2,1": .iPod2,
            "iPod3,1": .iPod3,
            "iPod4,1": .iPod4,
            "iPod5,1": .iPod5,
            "iPod7,1": .iPod6,
            "iPod9,1": .iPod7,
    
            // iPad
            "iPad2,1": .iPad2,
            "iPad2,2": .iPad2,
            "iPad2,3": .iPad2,
            "iPad2,4": .iPad2,
            "iPad3,1": .iPad3,
            "iPad3,2": .iPad3,
            "iPad3,3": .iPad3,
            "iPad3,4": .iPad4,
            "iPad3,5": .iPad4,
            "iPad3,6": .iPad4,
            "iPad6,11": .iPad5, // iPad 2017
            "iPad6,12": .iPad5,
            "iPad7,5": .iPad6, // iPad 2018
            "iPad7,6": .iPad6,
            "iPad7,11": .iPad7, // iPad 2019
            "iPad7,12": .iPad7,
            "iPad11,6": .iPad8, // iPad 2020
            "iPad11,7": .iPad8,
            "iPad12,1": .iPad9, // iPad 2021
            "iPad12,2": .iPad9,
    
            // iPad Mini
            "iPad2,5": .iPadMini,
            "iPad2,6": .iPadMini,
            "iPad2,7": .iPadMini,
            "iPad4,4": .iPadMini2,
            "iPad4,5": .iPadMini2,
            "iPad4,6": .iPadMini2,
            "iPad4,7": .iPadMini3,
            "iPad4,8": .iPadMini3,
            "iPad4,9": .iPadMini3,
            "iPad5,1": .iPadMini4,
            "iPad5,2": .iPadMini4,
            "iPad11,1": .iPadMini5,
            "iPad11,2": .iPadMini5,
            "iPad14,1": .iPadMini6,
            "iPad14,2": .iPadMini6,
    
            // iPad Pro
            "iPad6,3": .iPadPro97,
            "iPad6,4": .iPadPro97,
            "iPad7,3": .iPadPro105,
            "iPad7,4": .iPadPro105,
            "iPad6,7": .iPadPro129,
            "iPad6,8": .iPadPro129,
            "iPad7,1": .iPadPro2ndGen129,
            "iPad7,2": .iPadPro2ndGen129,
            "iPad8,1": .iPadPro11,
            "iPad8,2": .iPadPro11,
            "iPad8,3": .iPadPro11,
            "iPad8,4": .iPadPro11,
            "iPad8,9": .iPadPro2ndGen11,
            "iPad8,10": .iPadPro2ndGen11,
            "iPad13,4": .iPadPro3rdGen11,
            "iPad13,5": .iPadPro3rdGen11,
            "iPad13,6": .iPadPro3rdGen11,
            "iPad13,7": .iPadPro3rdGen11,
            "iPad8,5": .iPadPro3rdGen129,
            "iPad8,6": .iPadPro3rdGen129,
            "iPad8,7": .iPadPro3rdGen129,
            "iPad8,8": .iPadPro3rdGen129,
            "iPad8,11": .iPadPro4thGen129,
            "iPad8,12": .iPadPro4thGen129,
            "iPad13,8": .iPadPro5thGen129,
            "iPad13,9": .iPadPro5thGen129,
            "iPad13,10": .iPadPro5thGen129,
            "iPad13,11": .iPadPro5thGen129,
    
            // iPad Air
            "iPad4,1": .iPadAir,
            "iPad4,2": .iPadAir,
            "iPad4,3": .iPadAir,
            "iPad5,3": .iPadAir2,
            "iPad5,4": .iPadAir2,
            "iPad11,3": .iPadAir3,
            "iPad11,4": .iPadAir3,
            "iPad13,1": .iPadAir4,
            "iPad13,2": .iPadAir4,
    
            // iPhone
            "iPhone3,1": .iPhone4,
            "iPhone3,2": .iPhone4,
            "iPhone3,3": .iPhone4,
            "iPhone4,1": .iPhone4S,
            "iPhone5,1": .iPhone5,
            "iPhone5,2": .iPhone5,
            "iPhone5,3": .iPhone5C,
            "iPhone5,4": .iPhone5C,
            "iPhone6,1": .iPhone5S,
            "iPhone6,2": .iPhone5S,
            "iPhone7,1": .iPhone6Plus,
            "iPhone7,2": .iPhone6,
            "iPhone8,1": .iPhone6S,
            "iPhone8,2": .iPhone6SPlus,
            "iPhone8,4": .iPhoneSE,
            "iPhone9,1": .iPhone7,
            "iPhone9,3": .iPhone7,
            "iPhone9,2": .iPhone7Plus,
            "iPhone9,4": .iPhone7Plus,
            "iPhone10,1": .iPhone8,
            "iPhone10,4": .iPhone8,
            "iPhone10,2": .iPhone8Plus,
            "iPhone10,5": .iPhone8Plus,
            "iPhone10,3": .iPhoneX,
            "iPhone10,6": .iPhoneX,
            "iPhone11,2": .iPhoneXS,
            "iPhone11,4": .iPhoneXSMax,
            "iPhone11,6": .iPhoneXSMax,
            "iPhone11,8": .iPhoneXR,
            "iPhone12,1": .iPhone11,
            "iPhone12,3": .iPhone11Pro,
            "iPhone12,5": .iPhone11ProMax,
            "iPhone12,8": .iPhoneSE2,
            "iPhone13,1": .iPhone12Mini,
            "iPhone13,2": .iPhone12,
            "iPhone13,3": .iPhone12Pro,
            "iPhone13,4": .iPhone12ProMax,
            "iPhone14,4": .iPhone13Mini,
            "iPhone14,5": .iPhone13,
            "iPhone14,2": .iPhone13Pro,
            "iPhone14,3": .iPhone13ProMax,
            "iPhone14,6": .iPhoneSE3,
            "iPhone14,7": .iPhone14,
            "iPhone14,8": .iPhone14Plus,
            "iPhone15,2": .iPhone14Pro,
            "iPhone15,3": .iPhone14ProMax,
            "iPhone15,4": .iPhone15,
            "iPhone15,5": .iPhone15Plus,
            "iPhone15,6": .iPhone15Pro,
            "iPhone15,7": .iPhone15ProMax,
    
            // Apple Watch
            "Watch1,1": .appleWatch1,
            "Watch1,2": .appleWatch1,
            "Watch2,6": .appleWatchS1,
            "Watch2,7": .appleWatchS1,
            "Watch2,3": .appleWatchS2,
            "Watch2,4": .appleWatchS2,
            "Watch3,1": .appleWatchS3,
            "Watch3,2": .appleWatchS3,
            "Watch3,3": .appleWatchS3,
            "Watch3,4": .appleWatchS3,
            "Watch4,1": .appleWatchS4,
            "Watch4,2": .appleWatchS4,
            "Watch4,3": .appleWatchS4,
            "Watch4,4": .appleWatchS4,
            "Watch5,1": .appleWatchS5,
            "Watch5,2": .appleWatchS5,
            "Watch5,3": .appleWatchS5,
            "Watch5,4": .appleWatchS5,
            "Watch5,9": .appleWatchSE,
            "Watch5,10": .appleWatchSE,
            "Watch5,11": .appleWatchSE,
            "Watch5,12": .appleWatchSE,
            "Watch6,1": .appleWatchS6,
            "Watch6,2": .appleWatchS6,
            "Watch6,3": .appleWatchS6,
            "Watch6,4": .appleWatchS6,
            "Watch6,6": .appleWatchS7,
            "Watch6,7": .appleWatchS7,
            "Watch6,8": .appleWatchS7,
            "Watch6,9": .appleWatchS7,
    
            // Apple TV
            "AppleTV1,1": .appleTV1,
            "AppleTV2,1": .appleTV2,
            "AppleTV3,1": .appleTV3,
            "AppleTV3,2": .appleTV3,
            "AppleTV5,3": .appleTV4,
            "AppleTV6,2": .appleTV4K,
            "AppleTV11,1": .appleTV2ndGen4K
        ]
    
        guard let mcode = modelCode, let model = modelMap[mcode] else {
            return Model.unrecognized
        }
        if model == .simulator {
            if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"], let simModel = modelMap[simModelCode] {
                return simModel
            }
        }
        return model
    }
}
