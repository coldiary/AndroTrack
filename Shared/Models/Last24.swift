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
}

extension Last24: CustomStringConvertible {
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
