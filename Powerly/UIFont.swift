//
//  UIFont.swift
//  PowerShare
//
//  Created by admin on 08/02/22.
//  
//

import Foundation
import Swift
import SwiftUI

extension UIFont {
    private static func customFont(name: String, size: CGFloat) -> UIFont {
        let font = UIFont(name: name, size: size)
        assert(font != nil, "Can't load font: \(name)")
        return font ?? UIFont.systemFont(ofSize: size)
    }
    
    static func robotoRegular(ofSize size: CGFloat) -> UIFont {
        return customFont(name: isLanguageArabic ? kfontNotoArabicRegular:kfontExo2Regular, size: size)
    }
    
    static func robotoMedium(ofSize size: CGFloat) -> UIFont {
        return customFont(name: isLanguageArabic ? kfontNotoArabicMedium:kfontExo2Medium, size: size)
    }
    
    static func robotoBold(ofSize size: CGFloat) -> UIFont {
        return customFont(name: isLanguageArabic ? kfontNotoArabicBold:kfontExo2Bold, size: size)
    }
    
    static func robotoBlack(ofSize size: CGFloat) -> UIFont {
        return customFont(name: isLanguageArabic ? kfontNotoArabicBold:kfontExo2Bold, size: size)
    }
    
    static func robotoItalic(ofSize size: CGFloat) -> UIFont {
        return customFont(name: isLanguageArabic ? kfontNotoArabicLight:kfontExo2Light, size: size)
    }
    
    static func robotoLight(ofSize size: CGFloat) -> UIFont {
        return customFont(name: isLanguageArabic ? kfontNotoArabicLight:kfontExo2Light, size: size)
    }
}

extension Font {
    // this all fonts for swiftui
    static func robotoRegular(size: CGFloat) -> Font {
        return Font.custom(isLanguageArabic ? kfontNotoArabicRegular:kfontExo2Regular, size: size)
    }

    static func robotoMedium(size: CGFloat) -> Font {
        return Font.custom(isLanguageArabic ? kfontNotoArabicMedium:kfontExo2Medium, size: size)
    }

    static func robotoBold(size: CGFloat) -> Font {
        return Font.custom(isLanguageArabic ? kfontNotoArabicBold:kfontExo2Bold, size: size)
    }
    
    static func robotoBlack(size: CGFloat) -> Font {
        return Font.custom(isLanguageArabic ? kfontNotoArabicBold:kfontExo2Bold, size: size)
    }

    static func robotoItalic(size: CGFloat) -> Font {
        return Font.custom(isLanguageArabic ? kfontNotoArabicLight:kfontExo2Light, size: size)
    }

    static func robotoLight(size: CGFloat) -> Font {
        return Font.custom(isLanguageArabic ? kfontNotoArabicLight:kfontExo2Light, size: size)
    }
}
