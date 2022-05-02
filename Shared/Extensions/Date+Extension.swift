//
//  Date+Extension.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

extension Date {
    func format(dateFormat: DateFormatter.Style = .medium, timeFormat: DateFormatter.Style = .medium, locale: Locale = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateFormat
        dateFormatter.timeStyle = timeFormat
        dateFormatter.locale = locale
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
        return self.format(dateFormat: .short, timeFormat: .none, locale: Locale(identifier: "fr_CA"))
    }
    
    static func fromString(date: String, format: String = "yyyy/MM/dd HH:mm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: date)
    }
    
    func distance(to date: Date, as unit: DurationUnit) -> Double {
        Double(Calendar.current.dateComponents([.second], from: self, to: date).second ?? 0) / unit.rawValue
    }
    
    func minutesInDay() -> Int {
        return Calendar.current.component(.hour, from: self) * 60 + Calendar.current.component(.minute, from: self)
    }
    
    func removeHours(_ hours: Int) -> Date {
        self.addingTimeInterval(TimeInterval(-hours * 3600))
    }
}

extension Date {    
    var startOfMonth: Date? {
        return  Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
    }
    
    var endOfMonth: Date? {
        guard let startOfMonth = startOfMonth else {
            return nil
        }

        return Calendar(identifier: .gregorian).date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)
    }
}
