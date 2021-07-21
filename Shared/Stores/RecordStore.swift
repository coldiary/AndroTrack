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
    public static let shared = RecordStore()
    
    @Published var state = RingState.off
    @Published var records: [Record] = [
        Record.yesterday
    ]
    
    @available(iOS 14.3, *)
    private lazy var HKService = { HealthKitService() }()
    
    private init() {
        if #available(iOS 14.3, *) {
            HKService.registerForSync(withCallback: { error in
                if let error = error {
                    print("[RecordStore] Failure", error.errorDescription!)
                }
                self.refreshHealthData()
            }, completion: { error in
                if let error = error {
                    print("[RecordStore] Failure", error.errorDescription!)
                }
            })
        } else {
            print("[RecordStore] HealthKit not supported")
        }
    }
    
    var current: Day {
        return getDay(forDate: Date())
    }
    
    public func markAsWorn() {
        if state == RingState.off {
            state = RingState.worn
            records.append(Record(start: Date()))
            
            if #available(iOS 14.3, *) {
                HKService.storeRecord(record: records[records.endIndex - 1]) { error in
                    if let error = error {
                        print(error.errorDescription!)
                    }
                }
            }
            if SettingsStore.shared.notifications.notifyEnd {
                guard let estimatedEnd = current.estimatedEnd(forDuration: SettingsStore.shared.sessionLength) else {
                    print("[Notifications] Can't determine estimatedEnd")
                    return
                }
                
                Notifications.scheduleNotifyEndNotification(at: estimatedEnd)
            }
        }
    }
    
    public func markAsRemoved() {
        if state == RingState.worn {
            state = RingState.off
            records[records.endIndex - 1].markEnded()
            
            if #available(iOS 14.3, *) {
                HKService.storeRecord(record: records[records.endIndex - 1]) { error in
                    if let error = error {
                        print(error.errorDescription!)
                    }
                }
            }
            
            if SettingsStore.shared.notifications.notifyEnd {
                Notifications.cancelNotifyEndNotification()
            }
        }
    }
    
    private func getDay(forDate date: Date) -> Day {
        return Day(records: records.filter({ $0.start != nil && Calendar.current.isDate($0.start!, inSameDayAs: date) }))
    }
    
    public func refreshHealthData() {
        if #available(iOS 14.3, *) {
            HKService.fetchRecords { results, error in
                guard error == nil else {
                    print(error!.errorDescription!)
                    return
                }
                
                if let results = results {
                    self.records = results
                    
                    if (self.records.count > 0) {
                        self.state = self.records[self.records.endIndex - 1].end != nil ? RingState.off : RingState.worn
                    }
                }
            }
        } else {
            print("[RecordStore] HealthKit not supported")
        }
    }
}
