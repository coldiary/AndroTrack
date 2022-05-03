//
//  Day.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-14.
//

import Foundation

struct Day: SessionGroup {
    var records: [Record] = []
    var duration: Double { records.reduce(0) { $0 + $1.durationInHours } }
    var goal: Int? {
        records[safe: records.endIndex - 1]?.goal
    }
    
    func durationAsProgress(goal currentGoalSetting: Int) -> Double {
        let goal = Double(self.goal ?? currentGoalSetting)
        return (duration / goal) * 100
    }
    
    func estimatedEnd(forDuration sessionLength: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: Int((Double(sessionLength) - duration) * 3600), to: Date())
    }
}

extension Day: CustomStringConvertible {
    var description: String {
        """
        {
          records: \(records.count),
          duration: \(self.duration),
          goal: \(self.goal?.description ?? "-"),
          date: \(records.count != 0 ? records.first!.start.format() : "unknown")
        }
        """
    }
}
