//
//  Record.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

enum DurationUnit: Double {
    case hour = 3600
    case minute = 60
    case second = 1
}

class Record: Identifiable, Codable {
    var id: UUID
    var start: Date
    var end: Date
    var goal: Int?
    
    init(id: UUID = UUID(), start: Date = Date(), end: Date = Date.distantFuture, goal: Int? = nil) {
        self.id = id
        self.start = start
        self.end = end
        self.goal = goal
    }
}

extension Record {
    var durationInHours: Double { durationIn(.hour) }
    var durationInMinutes: Double { durationIn(.minute) }
    var durationInSeconds: Double { durationIn(.second) }
    
    private func durationIn(_ unit: DurationUnit) -> Double {
        let endVal = end == Date.distantFuture ? Date() : end
        return Double(Calendar.current.dateComponents([.second], from: start, to: endVal).second ?? 0) / unit.rawValue
    }
    
    func durationFrom(_ date: Date, in unit: DurationUnit) -> Double {
        let endVal = end == Date.distantFuture ? Date() : end
        return Double(Calendar.current.dateComponents([.second], from: date, to: endVal).second ?? 0) / DurationUnit.hour.rawValue
    }

    func durationAsProgress(goal currentGoalSetting: Int) -> Double {
        let goal = Double(self.goal ?? currentGoalSetting)
        return (durationInHours / goal) * 100
    }
    
    func durationAsProgressFrom(_ date: Date, goal currentGoalSetting: Int) -> Double {
        let goal = Double(self.goal ?? currentGoalSetting)
        let duration = durationFrom(date, in: .hour)
        return (duration / goal) * 100
    }
}

extension Record {
    func markStarted() {
        start = Date()
    }
    
    func markEnded(goal: Int) {
        self.goal = goal
        end = Date()
    }
    
    func updateId(_ id: UUID) {
        self.id = id
    }
}

extension Record {
    static var today: Record {
        return Record(
            start: Date().addingTimeInterval(-5 * DurationUnit.hour.rawValue),
            end: Date().addingTimeInterval(-4 * DurationUnit.hour.rawValue)
        )
    }
    
    static var yesterday: Record {
        return Record(
            start: Date().addingTimeInterval(-34 * DurationUnit.hour.rawValue),
            end: Date().addingTimeInterval(-19 * DurationUnit.hour.rawValue)
        )
    }
    
    static var dayBefore: Record {
        return Record(
            start: Date().addingTimeInterval(-48 * DurationUnit.hour.rawValue),
            end: Date().addingTimeInterval(-43 * DurationUnit.hour.rawValue)
        )
    }
}

extension Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        let lhsStart = lhs.start.timeIntervalSince1970
        let rhsStart = rhs.start.timeIntervalSince1970
        let lhsEnd = lhs.end.timeIntervalSince1970
        let rhsEnd = rhs.end.timeIntervalSince1970
        return (lhsStart == rhsStart && lhsEnd == rhsEnd && lhs.goal == rhs.goal)
    }
    
    
}

extension Record: Comparable {
    static func < (lhs: Record, rhs: Record) -> Bool { lhs.start < rhs.start }
}

extension Record: CustomStringConvertible {
    var description: String {
        "{ start: \(start.description), end: \(end != Date.distantFuture ? end.description : "-"), goal: \(goal?.description ?? "nil") }"
    }
}
