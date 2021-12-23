//
//  Record.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

enum DurationUnit: Double {
    case hours = 3600
    case minutes = 60
    case seconds = 1
}

class Record: Identifiable, Codable {
    let id: UUID
    var start: Date?
    var end: Date?
    
    init(id: UUID = UUID(), start: Date? = Date(), end: Date? = nil) {
        self.id = id
        self.start = start
        self.end = end
    }
}

extension Record {
    var durationInHours: Double? { durationIn(.hours) }
    var durationInMinutes: Double? { durationIn(.minutes)}
    var durationInSeconds: Double? { durationIn(.seconds)}
    
    private func durationIn(_ unit: DurationUnit) -> Double? {
        if let startVal = start {
            if let endVal = end {
                return Double(Calendar.current.dateComponents([.second], from: startVal, to: endVal).second ?? 0) / unit.rawValue
            } else {
                return Double(Calendar.current.dateComponents([.second], from: startVal, to: Date()).second ?? 0) / unit.rawValue
            }
        }
        return nil
    }

    func durationAsProgress(goal: Double) -> Double {
        return ((durationInHours ?? 0) / goal) * 100
    }
}

extension Record {
    func markStarted() {
        start = Date()
    }
    
    func markEnded() {
        end = Date()
    }
}

extension Record {
    static var today: Record {
        return Record(
            start: Date().addingTimeInterval(-18000),
            end: Date().addingTimeInterval(-14000)
        )
    }
    
    static var yesterday: Record {
        return Record(
            start: Date().addingTimeInterval(-86400),
            end: Date().addingTimeInterval(-68400)
        )
    }
    
    static var dayBefore: Record {
        return Record(
            start: Date().addingTimeInterval(-172800),
            end: Date().addingTimeInterval(-154800)
        )
    }
}

extension Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        let lhsStart = lhs.start?.timeIntervalSince1970 ?? 0
        let rhsStart = rhs.start?.timeIntervalSince1970 ?? 0
        let lhsEnd = lhs.end?.timeIntervalSince1970 ?? 0
        let rhsEnd = rhs.end?.timeIntervalSince1970 ?? 0
        return (lhsStart == rhsStart && lhsEnd == rhsEnd)
    }
    
    
}

extension Record: Comparable {
    static func < (lhs: Record, rhs: Record) -> Bool {
        return rhs.start == nil || (lhs.start != nil && lhs.start! < rhs.start!)
    }
}

extension Record: CustomStringConvertible {
    var description: String {
        "{ start: \(start?.description ?? "nil"), end: \(end?.description ?? "nil") }"
    }
}
