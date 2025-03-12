//
//  String.swift
//  PowerShare
//
//  Created by admin on 15/12/21.

//

import Foundation

extension String {
    func convertToNumber() -> String {
        return self.replacingOccurrences(of: "١", with: "1")
            .replacingOccurrences(of: "٢", with: "2")
            .replacingOccurrences(of: "٣", with: "3")
            .replacingOccurrences(of: "٤", with: "4")
            .replacingOccurrences(of: "٥", with: "5")
            .replacingOccurrences(of: "٦", with: "6")
            .replacingOccurrences(of: "٧", with: "7")
            .replacingOccurrences(of: "٨", with: "8")
            .replacingOccurrences(of: "٩", with: "9")
            .replacingOccurrences(of: "٠", with: "0")
    }
    
    func index(from: Int) -> Index {
            return self.index(startIndex, offsetBy: from)
        }

        func substring(from: Int) -> String {
            let fromIndex = index(from: from)
            return String(self[fromIndex...])
        }

        func substring(to: Int) -> String {
            let toIndex = index(from: to)
            return String(self[..<toIndex])
        }

        func substring(with rrr: Range<Int>) -> String {
            let startIndex = index(from: rrr.lowerBound)
            let endIndex = index(from: rrr.upperBound)
            return String(self[startIndex..<endIndex])
        }
}

struct Time {
    let hours: Int
    let minutes: Int
    let seconds: Int
}

extension String {
    func stringToDate(format: String, timeZone: TimeZone? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        if let timeZone = timeZone {
            dateFormatter.timeZone = timeZone
        }
        let isoFormatter = ISO8601DateFormatter()

        
        return dateFormatter.date(from: self)
    }
    
    func timeConversion12(format: String, inTimeZone: TimeZone? = nil, outTimeZone: TimeZone? = nil) -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        if let timeZone = inTimeZone {
            dateFormat.timeZone = timeZone
        }
        guard let date = dateFormat.date(from: self) else {
            return ""
        }
        
        let df2 = DateFormatter()
        df2.locale = Locale(identifier: "en_US_POSIX")
        df2.dateFormat = "hh:mm a"
        if let timeZone = outTimeZone {
            df2.timeZone = timeZone
        }
        let time12 = df2.string(from: date).replacingOccurrences(of: "AM", with: NSLocalizedString("AM", comment: "")).replacingOccurrences(of: "PM", with: NSLocalizedString("PM", comment: ""))
        return time12
    }
    
    func timeConversion24(format: String, inTimeZone: TimeZone? = nil, outTimeZone: TimeZone? = nil) -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        if let timeZone = inTimeZone {
            dateFormat.timeZone = timeZone
        }
        guard let date = dateFormat.date(from: self) else {
            return ""
        }
        
        let df2 = DateFormatter()
        df2.locale = Locale(identifier: "en_US_POSIX")
        df2.dateFormat = "HH:mm:ss"
        if let timeZone = outTimeZone {
            df2.timeZone = timeZone
        }
        let time12 = df2.string(from: date)
        return time12
    }
    
    func getTimeComponents() -> Time? {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = timeFormatter.date(from: self) else {
            return nil // Return nil if the input string is not in the correct format
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        
        guard let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return nil
        }
        
        return Time(hours: hours, minutes: minutes, seconds: seconds)
    }

    func getPriceUnitName() -> String {
        var unitStr = self
        if let unitStruct = PriceUnit(rawValue: self) {
            switch unitStruct {
            case .energy:
                unitStr = NSLocalizedString("kwh", comment: "")
                
            case .minutes:
                unitStr = NSLocalizedString("minute", comment: "")                
            }
        }
        return unitStr
    }
    
    func getPriceUnitNamePlural() -> String {
        var unitStr = self
        if let unitStruct = PriceUnit(rawValue: self) {
            switch unitStruct {
            case .energy:
                unitStr = NSLocalizedString("kwh", comment: "")
                
            case .minutes:
                unitStr = NSLocalizedString("minutes", comment: "")
            }
        }
        return unitStr
    }
}

extension BidirectionalCollection where Element: StringProtocol {
    var sentence: String {
        count <= 2 ?
            joined(separator: " and ") :
            dropLast().joined(separator: ", ") + ", and " + last!
    }
}

extension Int {
    func convertToMinHourFormat() -> String {
        let hours = self / 60
        let remainingMinutes = self % 60
        if hours == 0 {
            return "\(remainingMinutes) \(NSLocalizedString("min", comment: ""))"
        }
        if remainingMinutes == 0 {
            return "\(hours) \(NSLocalizedString("h", comment: ""))"
        }
        return "\(hours)\(NSLocalizedString("h", comment: "")) \(remainingMinutes)\(NSLocalizedString("min", comment: ""))"
    }
}
