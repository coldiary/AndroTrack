//
//  RecordStore.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation
import UserNotifications

class RecordStore: ObservableObject {
    public static var shared = RecordStore()
    
    @Published var state = RingState.off
    @Published var records: [Record] = [
        Record.dayBefore,
        Record.yesterday,
        Record.today,
    ]
    @Published var pagedQuaterlyRecords: [Int:[Record]] = [:]
    @Published var all: [Record]?
    @Published var stats: Stats?
    
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
    
    var current: SessionGroup {
        return SettingsStore.shared.currentView == .Today ? getDay(forDate: Date()) : getLast24()
    }
    
    public func markAsWorn() {
        if state == RingState.off {
            state = RingState.worn
            records.append(Record(start: Date()))
            
            HealthKitService.shared.addRecord(record: records[records.endIndex - 1]) {  _, error  in
                if let error = error {
                    return AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                }
            }

            Notifications.scheduleNotifyEnd()
        }
    }
    
    public func markAsRemoved() {
        if state == RingState.worn {
            state = RingState.off
            records[records.endIndex - 1].markEnded(goal: SettingsStore.shared.sessionLength)
            
            if records[records.endIndex - 1].durationInMinutes < 3 {
                HealthKitService.shared.removeRecord(id: records.popLast()!.id) { error in
                    if let error = error {
                        AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                    }
                }
            } else {
                HealthKitService.shared.editRecord(id: records[records.endIndex - 1].id, records[records.endIndex - 1]) { id, error in
                    if let error = error {
                        AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                    }
                    
                    guard let id = id else {
                        return AppLogger.error(context: "RecordStore", "Failure: No UUID returned.")
                    }
                    
                    self.records[self.records.endIndex - 1].updateId(id)
                }
            }
            
            Notifications.scheduleReminderStart()
        }
    }
    
    public func deleteRecord(with id: UUID) {
        let editingCurrent = RecordStore.shared.current.records.contains { id == $0.id }
        
        HealthKitService.shared.removeRecord(id: id) { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            } else if editingCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Notifications.scheduleNotifyEnd()
                }
            }
        }
    }
    
    public func editRecord(with id: UUID, newValues: Record) {
        let editingCurrent = RecordStore.shared.current.records.contains { id == $0.id }
        
        HealthKitService.shared.editRecord(id: id, newValues) { _, error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            } else if editingCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Notifications.scheduleNotifyEnd()
                }
            }
        }
    }
    
    public func addRecord(newValues: Record) {
        let editingCurrent = Calendar.current.isDateInToday(newValues.start)
        
        HealthKitService.shared.addRecord(record: newValues) { _, error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            } else if editingCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Notifications.scheduleNotifyEnd()
                }
            }
        }
    }
    
    public func getDayFromDate(date: Date) -> Day {
        return getDay(forDate: date)
    }
    
    public func getDay(forDate date: Date) -> Day {
        if Calendar.current.isDateInToday(date) {
            return Day(records: records.filter({ Calendar.current.isDate($0.start, inSameDayAs: date) }))
        }
        
        return Day(records: pagedQuaterlyRecords[date.quartersAgo, default: []].filter({ Calendar.current.isDate($0.start, inSameDayAs: date) }))
    }
    
    public func getLast24() -> Last24 {
        let start = Date().removeHours(24)
        return Last24(records: records.filter({ $0.end > start }))
    }
    
    public func loadHealthData(forQuarterAgo quarter: Int, completion: ((Error?) -> ())? = nil) {
        if let end = Calendar.current.date(byAdding: DateComponents(month: quarter * -3), to: Date())?.endOfMonth,
           let start = Calendar.current.date(byAdding: DateComponents(month: (quarter + 1) * -3), to: Date())?.startOfMonth {
            HealthKitService.shared.fetchRecords(from: start, to: end) { results, error in
                if let error = error {
                    AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                    completion?(error)
                    return
                }
                
                if let results = results {
                    self.pagedQuaterlyRecords[quarter] = results
                    completion?(nil)
                }
            }
        }
    }
    
    public func loadAllHealthData(completion: ((Error?) -> ())? = nil) {
        HealthKitService.shared.fetchRecords { records, error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                completion?(error)
                return
            }
            
            self.all = records
            completion?(nil)
        }
    }
    
    public func refreshHealthData() {
        loadAllHealthData { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.localizedDescription)")
                return
            }
            
            self.pagedQuaterlyRecords = [:]
            self.records = []
            
            guard let all = self.all else {
                AppLogger.error(context: "RecordStore", "Failure: refreshHealthData - all records not loaded")
                return
            }
            
            for record in all {
                let quarterAgo = record.start.quartersAgo
                
                if quarterAgo == 0 && (record.end.isInLast24h || record.start.isInLast24h) {
                    self.records.append(record)
                }
                
                self.pagedQuaterlyRecords[quarterAgo, default: []].append(record)
            }
            
            if (self.records.count > 0) {
                self.state = self.records[self.records.endIndex - 1].end != Date.distantFuture ? RingState.off : RingState.worn
            }
            
            self.stats = Stats(store: self)
        }
    }
}
