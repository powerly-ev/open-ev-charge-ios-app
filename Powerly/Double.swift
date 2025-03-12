//
//  Double.swift
//  Powerly
//
//  Created by ADMIN on 16/07/24.
//  
//

import Foundation

extension Double {
    func formatted() -> String {
        if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.3f", self)
        }
    }
}

extension Float {
    func formatted() -> String {
        if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.3f", self)
        }
    }
}
