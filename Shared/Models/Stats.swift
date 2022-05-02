//
//  Stats.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2022-05-02.
//

import Foundation

struct Stats {
    private let store: RecordStore
    private let goal = SettingsStore.shared.sessionLength
    private let period = 30
    
    public let firstRecordDate: String
    public let meanWearingTime: String
    public let meanNonWearingTime: String
    public let consecutiveSerie: String
    public let consecutiveSerieStart: String
    public let meanWearOffHour: String
    public let meanWearOnHour: String
    
    init(store: RecordStore) {
        self.store = store
        
        self.firstRecordDate = Self.computeFirstRecordDate(from: store)
        
        let (wearing, nonWearing) = Self.computeMeanTimes(from: store, period: period)
        self.meanWearingTime = wearing
        self.meanNonWearingTime = nonWearing
        
        let (count, start) = Self.computeConsecutiveSerie(from: store, goal: goal)
        self.consecutiveSerie = count
        self.consecutiveSerieStart = start
        
        let (wearOn, wearOff) = Self.computeFrequentHours(from: store)
        self.meanWearOffHour = wearOn
        self.meanWearOnHour = wearOff
    }
    
    private static func computeFirstRecordDate(from store: RecordStore) -> String {
        guard let firstRecord = (store.all ?? []).first else { return "-" }
        return firstRecord.start.shortDate()
    }
    
    private static func computeMeanTimes(from store: RecordStore, period: Int) -> (wearing: String, nonWearing: String) {
        let days: [Day] = (0..<period).map { deltaDays in
            if let date = Calendar.current.getDateBack(to: deltaDays) {
                return store.getDayFromDate(date: date)
            } else {
                return Day()
            }
        }
        
        let (wearing, nonWearing) = days.reduce((0, 0)) { ($0.0 + Int($1.duration), $0.1 + Int(24 - $1.duration)) }
        return ("\(wearing / days.count)h", "\(nonWearing / days.count)h")
    }
    
    private static func computeConsecutiveSerie(from store: RecordStore, goal: Int) -> (count: String, start: String) {
        var consecutive = store.current.duration >= Double(goal) ? 1 : 0
        
        var date = Date()
        var day = store.getDayFromDate(date: Date().removeHours(24))
        
        while day.duration >= Double(goal) {
            consecutive += 1
            guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDate
            day = store.getDayFromDate(date: date)
        }
        
        let start = Calendar.current.isDateInToday(date) ? "-" : date.shortDate()
        
        return (count: "\(consecutive) \("DAYS".localized)", start: start)
    }
    
    private static func computeFrequentHours(from store: RecordStore) -> (wearOn: String, wearOff: String) {
        let startCountedSet = NSCountedSet()
        let endCountedSet = NSCountedSet()
        
        for record in (store.all ?? []).filter({ $0.end != Date.distantFuture }) {
            startCountedSet.add(record.start.minutesInDay())
            endCountedSet.add(record.end.minutesInDay())
        }
        
        let mostFrequentStart = startCountedSet.max { startCountedSet.count(for: $0) < startCountedSet.count(for: $1) }
        let mostFrequentEnd = endCountedSet.max { endCountedSet.count(for: $0) < endCountedSet.count(for: $1) }
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        
        if let mostFrequentStartMinutes = mostFrequentStart as? Int,
           let mostFrequentStartDate = Calendar.current.date(byAdding: .minute, value: mostFrequentStartMinutes, to: startOfToday),
           let mostFrequestEndMinutes = mostFrequentEnd as? Int,
           let mostFrequentEndDate = Calendar.current.date(byAdding: .minute, value: mostFrequestEndMinutes, to: startOfToday) {
            return (
                wearOn: "\(mostFrequentStartDate.format(dateFormat: .none, timeFormat: .short))",
                wearOff: "\(mostFrequentEndDate.format(dateFormat: .none, timeFormat: .short))"
            )
        } else {
            return (wearOn: "-", wearOff: "-")
        }
    }
}
