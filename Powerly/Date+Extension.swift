//
//  Date+Extension.swift
//  PowerShare
//
//  Created by admin on 08/02/22.
//  
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {

        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        let yearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return String(format: CommonUtils.getStringFromXML(name: "sec_ago"), diff)
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return String(format: CommonUtils.getStringFromXML(name: "min_ago"), diff)
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return String(format: CommonUtils.getStringFromXML(name: "hrs_ago"), diff)
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return String(format: CommonUtils.getStringFromXML(name: "days_ago"), diff)
        } else if monthAgo < self {
            let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
            return String(format: CommonUtils.getStringFromXML(name: "weeks_ago"), diff)
        } else if yearAgo < self {
            let diff = Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
            return String(format: CommonUtils.getStringFromXML(name: "months_ago"), diff)
        }
        let diff = Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
        return String(format: CommonUtils.getStringFromXML(name: "years_ago"), diff)
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
}
