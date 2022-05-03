//
//  Frame.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2022-04-20.
//

import Foundation

struct Last24: SessionGroup {
    var records: [Record] = []
    
    var duration: Double {
        let frameStart = Date().removeHours(24)
        return records.reduce(0) { acc, record in
            if record.start >= frameStart {
                return acc + record.durationInHours
            } else if record.end > frameStart {
                return acc + frameStart.distance(to: record.end, as: DurationUnit.hour)
            } else {
                return acc
            }
        }
    }
    
    var goal: Int? {
        records[safe: records.endIndex - 1]?.goal
    }
    
    func durationAsProgress(goal currentGoalSetting: Int) -> Double {
        let goal = Double(self.goal ?? currentGoalSetting)
        return (duration / goal) * 100
    }
    
    func estimatedEnd(forDuration sessionLength: Int) -> Date? {
        let frameStart = Date().removeHours(24)
        let drifting = records.first { rec in rec.start < frameStart && rec.end > frameStart }
        var driftingHours: Double = 0
        if let drifting = drifting {
            driftingHours = frameStart.distance(to: drifting.end, as: DurationUnit.hour)
        }
        return Calendar.current.date(byAdding: .second, value: Int((Double(sessionLength) - duration + driftingHours) * 3600), to: Date())
    }
}

extension Last24: CustomStringConvertible {
    var description: String {
        """
        {
          records: \(records.count),
          duration: \(self.duration),
          goal: \(self.goal?.description ?? "-"),
          date: \(records.count != 0 ? records.first!.start.compactDateTime() : "unknown")
        }
        """
    }
}
