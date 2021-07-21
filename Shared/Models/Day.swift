//
//  Day.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-14.
//

import Foundation

struct Day {
    var records: [Record] = []
    var duration: Double { records.reduce(0, { $0 + ($1.duration ?? 0) }) }
    
    func durationAsProgress(goal: Int) -> Double {
        return (duration / Double(goal)) * 100
    }
    
    func estimatedEnd(forDuration sessionLength: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: Int((Double(sessionLength) - duration) * 3600), to: Date())
    }
}
