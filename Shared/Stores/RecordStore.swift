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
