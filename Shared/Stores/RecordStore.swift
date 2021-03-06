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

            Notifications.scheduleNotifyEnd()
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
            
            Notifications.scheduleReminderStart()
        }
    }
    
    public func deleteRecord(at start: Date) {
        let editingCurrent = RecordStore.shared.current.records.contains { start == $0.start }
        
        HealthKitService.shared.removeRecord(at: start) { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            } else if editingCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Notifications.scheduleNotifyEnd()
                }
            }
        }
    }
    
    public func editRecord(at start: Date, newValues: Record) {
        let editingCurrent = RecordStore.shared.current.records.contains { start == $0.start }
        
        HealthKitService.shared.editRecord(at: start, newValues) { error in
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
        let editingCurrent = newValues.start.map { Calendar.current.isDateInToday($0) } ?? false
        
        HealthKitService.shared.storeRecord(record: newValues) { error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            } else if editingCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Notifications.scheduleNotifyEnd()
                }
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
