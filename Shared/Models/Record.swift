//
//  Record.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

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
    // Duration in hours
    var duration: Double? {
        if let startVal = start {
            if let endVal = end {
                return Double(Calendar.current.dateComponents([.second], from: startVal, to: endVal).second ?? 0) / 3600
            } else {
                return Double(Calendar.current.dateComponents([.second], from: startVal, to: Date()).second ?? 0) / 3600
            }
        }
        return nil
    }

    func durationAsProgress(goal: Double) -> Double {
        return ((duration ?? 0) / goal) * 100
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
    static var yesterday: Record {
        return Record(
            start: Date.fromString(date: "2021/07/12 08:30"),
            end: Date.fromString(date: "2021/07/12 17:40")
        )
    }
}

extension Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        return (
            (lhs.start?.timeIntervalSince1970 ?? 0) == (rhs.start?.timeIntervalSince1970 ?? 0) &&
            (lhs.end?.timeIntervalSince1970 ?? 0) == (rhs.end?.timeIntervalSince1970 ?? 0)
        )
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
