//
//  Calendar+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import Foundation

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

extension Calendar {
    func getDateBack(to: Int) -> Date? {
        return self.date(byAdding: .day, value: to * -1, to: Date())
    }
    
    func dayBefore() -> Date? {
        self.date(byAdding: DateComponents(hour: -24), to: Date())
    }
    
    func secondsBetween(start: Date, end: Date) -> Int {
        self.dateComponents([.second], from: start, to: end).second ?? 0
    }
}
