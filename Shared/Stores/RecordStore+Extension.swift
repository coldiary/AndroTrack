//
//  RecordStore+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-29.
//

import Foundation

// Compute stats
extension RecordStore {
    private func getDateBack(to: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: to * -1, to: Date())
    }
    
    private func getDayFromDate(date: Date) -> Day {
        return self.getDay(forDate: date)
    }
    
    public func firstRecordDate() -> String {
        guard let firstRecord = self.records.first else {
            return "-"
        }
        
        return firstRecord.start.shortDate()
    }
    
    public func meanWearingTime(days: Int) -> Int {
        let days: [Day] = (0..<days).map { deltaDays in
            if let date = getDateBack(to: deltaDays) {
                return getDayFromDate(date: date)
            } else {
                return Day()
            }
        }
        
        let durations: [Int] = days.map { Int($0.duration) }
        let mean = durations.reduce(0, +) / durations.count
        return mean
    }
    
    public func meanNonWearingTime(days: Int) -> Int {
        let days: [Day] = (0..<days).map { deltaDays in
            if let date = getDateBack(to: deltaDays) {
                return getDayFromDate(date: date)
            } else {
                return Day()
            }
        }
        
        let durations: [Int] = days.map { Int(24 - $0.duration) }
        let mean = durations.reduce(0, +) / durations.count
        return mean
    }
    
    public func consecutiveSerie(goal: Int) -> Int {
        var consecutive = 0
        
        var date = Date()
        var day = getDayFromDate(date: Date())
        
        while day.duration >= Double(goal) {
            consecutive += 1
            guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDate
            day = getDayFromDate(date: date)
        }
        
        return consecutive
    }
    
    public func consecutiveSerieStart(goal: Int) -> String {
        var date = Date()
        
        repeat {
            guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            let previousDay = getDayFromDate(date: previousDate)
            if previousDay.duration <= Double(goal) {
                break
            } else {
                date = previousDate
            }
        } while true
        
        if Calendar.current.isDateInToday(date) {
            return "-"
        }
        
        return date.shortDate()
    }
    
    public func meanWearOffHour() -> String {
        let endingHours = self.records
            .filter({ $0.end != Date.distantFuture })
            .map {
                Calendar.current.component(.hour, from: $0.end) * 60 +
                Calendar.current.component(.minute, from: $0.end)
            }
        let countedSet = NSCountedSet(array: endingHours)
        let mostFrequent = countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) }
        
        guard let mostFrequent = mostFrequent as? Int else {
            return "-"
        }
        
        let date = Calendar.current.startOfDay(for: Date())
        guard let mostFrequentTime = Calendar.current.date(byAdding: .minute, value: mostFrequent, to: date) else {
            return "-"
        }

        return "\(mostFrequentTime.format(dateFormat: .none, timeFormat: .short))"
    }
    
    public func meanWearOnHour() -> String {
        let startingHours = self.records
            .map {
                Calendar.current.component(.hour, from: $0.start) * 60 +
                Calendar.current.component(.minute, from: $0.start)
            }
        let countedSet = NSCountedSet(array: startingHours)
        let mostFrequent = countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) }
        
        guard let mostFrequent = mostFrequent as? Int else {
            return "-"
        }
        
        let date = Calendar.current.startOfDay(for: Date())
        guard let mostFrequentTime = Calendar.current.date(byAdding: .minute, value: mostFrequent, to: date) else {
            return "-"
        }

        return "\(mostFrequentTime.format(dateFormat: .none, timeFormat: .short))"
    }
}


// Export as CSVFile
extension RecordStore {
    public func exportAsCSVFile() -> CSVFile {
        let headers: [String] = ["start,end"]
        let data: [String] = records.map { record in
            "\(record.start.toISOString()), \(record.end != Date.distantFuture ? "\(record.end.toISOString())" : "")"
        }
        let content = (headers + data).joined(separator: "\n")
        return CSVFile(initialText: content)
    }
}
