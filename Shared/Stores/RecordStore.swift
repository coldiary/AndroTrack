//
//  RecordStore.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation
import UserNotifications
import Combine

class RecordStore: ObservableObject {
    public static var shared = RecordStore()
    
    @Published var state = RingState.off
    @Published var records: [Record] = []
    @Published var pagedQuaterlyRecords: [Int:[Record]] = [:]
    @Published var all: [Record]?
    @Published var stats: Stats?
    
    private var syncSub: AnyCancellable?
    private var disposableBag = Set<AnyCancellable>()
    
    private init() {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
        
        if HealthKitService.shared.healthKitAuthorizationStatus == .sharingAuthorized {
            syncSub = HealthKitService.shared.registerForSync()
                .receive(on: DispatchQueue.main)
                .map { HKCompletion in self.loadAllHealthData().map { records in (HKCompletion, records) } }
                .switchToLatest()
                .sink { completion in
                    if case .failure(let error) = completion {
                        AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                    }
                } receiveValue: { (HKCompletion, records) in
                    self.setHealthData(records)
                    HKCompletion()
                }
        }
    }
    
    var current: SessionGroup {
        return SettingsStore.shared.currentView == .Today ? getDay(forDate: Date()) : getLast24()
    }
    
    public func markAsWorn() {
        if state == RingState.off {
            state = RingState.worn
            records.append(Record(start: Date()))
            
            HealthKitService.shared.addRecord(record: records[records.endIndex - 1]) {  result in
                if case .failure(let error) = result {
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
                HealthKitService.shared.editRecord(id: records[records.endIndex - 1].id, records[records.endIndex - 1]) { result in
                    switch result {
                        case .failure(let error):
                            AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                        case .success(let id):
                            self.records[self.records.endIndex - 1].updateId(id)
                    }
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
        
        HealthKitService.shared.editRecord(id: id, newValues) { result in
            switch result {
                case .failure(let error):
                    AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                case .success(_):
                    if editingCurrent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            Notifications.scheduleNotifyEnd()
                        }
                    }
            }
        }
    }
    
    public func addRecord(newValues: Record) {
        let editingCurrent = Calendar.current.isDateInToday(newValues.start)
        
        HealthKitService.shared.addRecord(record: newValues) { result in
            if case .failure(let error) = result {
                return AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
            }
            
            if editingCurrent {
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
    
    private func loadAllHealthData() -> Future<[Record], HealthKitServiceError> {
        Future { promise in
            HealthKitService.shared.fetchRecords { result in
                switch result {
                    case .failure(let error):
                        return promise(.failure(error))
                    case .success(let records):
                        return promise(.success(records))
                }
            }
        }
    }
    
    public func refreshHealthData() {
        loadAllHealthData()
            .sink { completion in
                if case .failure(let error) = completion {
                    AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                }
            } receiveValue: { self.setHealthData($0) }
            .store(in: &disposableBag)

    }
    
    public func setHealthData(_ records: [Record]) {
        self.all = records
        self.pagedQuaterlyRecords = [:]
        self.records = []
        
        for record in records {
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
        
        AppLogger.info(context: "RecordStore", "Data refreshed")
    }
}
