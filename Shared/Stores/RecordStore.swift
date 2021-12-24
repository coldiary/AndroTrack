//
//  RecordStore.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation
import UserNotifications

enum RingState {
    case worn
    case off
}

class RecordStore: ObservableObject {
    public static var shared = RecordStore()
    
    @Published var state = RingState.off
    @Published var records: [Record] = [
        Record.dayBefore,
        Record.yesterday,
        Record.today,
    ]
    
    private init() {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }
        if HealthKitService.shared.healthKitAuthorizationStatus == .sharingAuthorized {
            HealthKitService.shared.registerForSync(withCallback: { error in
                if let error = error {
                    AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                } else {
                    self.refreshHealthData()
                }
            }, completion: { error in
                if let error = error {
                    AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                }
            })
        }
    }
    
    var current: Day {
        return getDay(forDate: Date())
    }
    
    public func markAsWorn() {
        if state == RingState.off {
            state = RingState.worn
            records.append(Record(start: Date()))
            
            HealthKitService.shared.storeRecord(record: records[records.endIndex - 1]) { error in
                if let error = error {
                    AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                }
            }

            if SettingsStore.shared.notifications.notifyEnd {
                guard let estimatedEnd = current.estimatedEnd(forDuration: SettingsStore.shared.sessionLength) else {
                    AppLogger.error(context: "RecordStore", "Can't determine estimatedEnd")
                    return
                }
                
                Notifications.scheduleNotifyEndNotification(at: estimatedEnd)
                Notifications.cancelReminderStartNotification()
            }
        }
    }
    
    public func markAsRemoved() {
        if state == RingState.worn {
            state = RingState.off
            records[records.endIndex - 1].markEnded()
            
            if records[records.endIndex - 1].durationInMinutes ?? 0 < 3 {
                HealthKitService.shared.removeRecord(at: records[records.endIndex - 1].start!) { error in
                    if let error = error {
                        AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                    }
                }
            } else {
                HealthKitService.shared.storeRecord(record: records[records.endIndex - 1]) { error in
                    if let error = error {
                        AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                    }
                }
            }
            
            if SettingsStore.shared.notifications.notifyEnd {
                Notifications.cancelNotifyEndNotification()
                Notifications.scheduleReminderStartNotification()
            }
        }
    }
    
    public func deleteRecord(at start: Date) {
        HealthKitService.shared.removeRecord(at: start) { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            }
        }
    }
    
    public func editRecord(at start: Date, newValues: Record) {
        HealthKitService.shared.editRecord(at: start, newValues) { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            }
        }
    }
    
    public func addRecord(newValues: Record) {
        HealthKitService.shared.storeRecord(record: newValues) { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            }
        }
    }
    
    public func getDay(forDate date: Date) -> Day {
        return Day(records: records.filter({ $0.start != nil && Calendar.current.isDate($0.start!, inSameDayAs: date) }))
    }
    
    public func refreshHealthData() {
        HealthKitService.shared.fetchRecords { results, error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                return
            }
            
            if let results = results {
                self.records = results
                
                if (self.records.count > 0) {
                    self.state = self.records[self.records.endIndex - 1].end != nil ? RingState.off : RingState.worn
                }
            }
        }
    }
}

// Compute stats
extension RecordStore {
    private func getDateBack(to: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: to * -1, to: Date())
    }
    
    private func getDayFromDate(date: Date) -> Day {
        return self.getDay(forDate: date)
    }
    
    public func firstRecordDate() -> String {
        guard let firstRecord = self.records.first,
              let firstDate = firstRecord.start else {
            return "-"
        }
        
        return firstDate.shortDate()
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
            .filter({ $0.end != nil })
            .map {
                Calendar.current.component(.hour, from: $0.end!) * 60 +
                Calendar.current.component(.minute, from: $0.end!)
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
            .filter({ $0.start != nil })
            .map {
                Calendar.current.component(.hour, from: $0.start!) * 60 +
                Calendar.current.component(.minute, from: $0.start!)
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
