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
                HealthKitService.shared.addRecord(record: records[records.endIndex - 1]) { id, error in
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
    
    public func getDay(forDate date: Date) -> Day {
        return Day(records: records.filter({ Calendar.current.isDate($0.start, inSameDayAs: date) }))
    }
    
    public func getLast24() -> Last24 {
        let start = Date().removeHours(24)
        return Last24(records: records.filter({ $0.end > start }))
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
                    self.state = self.records[self.records.endIndex - 1].end != Date.distantFuture ? RingState.off : RingState.worn
                }
            }
        }
    }
}
