//
//  Date+Extension.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

extension Date {
    func format(dateFormat: DateFormatter.Style = .medium, timeFormat: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateFormat
        dateFormatter.timeStyle = timeFormat
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
    func toISOString() -> String {
        return ISO8601DateFormatter().string(from: self)
    }
    
    // Ex: 29 Dec. 2021
    func shortDate() -> String {
        self.format(dateFormat: .medium, timeFormat: .none)
    }
    
    // Ex: 2021-12-29
    func compactDate() -> String {
        self.format(dateFormat: .short, timeFormat: .none)
    }
    
    static func fromString(date: String, format: String = "yyyy/MM/dd HH:mm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: date)
    }
}
