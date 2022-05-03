//
//  Record.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

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
        return Double(Calendar.current.secondsBetween(start: start, end: endVal)) / unit.rawValue
    }
    
    func durationFrom(_ date: Date, in unit: DurationUnit) -> Double {
        let endVal = end == Date.distantFuture ? Date() : end
        return Double(Calendar.current.secondsBetween(start: start, end: endVal)) / unit.rawValue
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
            start: Date().addingTimeInterval(.hours(-5)),
            end: Date().addingTimeInterval(.hours(-4))
        )
    }
    
    static var yesterday: Record {
        return Record(
            start: Date().addingTimeInterval(.hours(-34)),
            end: Date().addingTimeInterval(.hours(-19))
        )
    }
    
    static var dayBefore: Record {
        return Record(
            start: Date().addingTimeInterval(.hours(-48)),
            end: Date().addingTimeInterval(.hours(-43))
        )
    }
}

extension Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end && lhs.goal == rhs.goal
    }
    
    
}

extension Record: Comparable {
    static func < (lhs: Record, rhs: Record) -> Bool { lhs.start < rhs.start }
}

extension Record: CustomStringConvertible {
    var description: String {
        """
        {
            start: \(start.compactDateTime()),
            end: \(end != Date.distantFuture ? end.compactDateTime() : "-"),
            goal: \(goal?.description ?? "nil")
        }
        """
    }
}
