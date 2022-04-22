//
//  SessionGroup.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2022-04-20.
//

import Foundation

protocol SessionGroup {
    var records: [Record] { get set }
    var duration: Double { get }
    var goal: Int? { get }
}


extension SessionGroup {
    func durationAsProgress(goal currentGoalSetting: Int) -> Double {
        let goal = Double(self.goal ?? currentGoalSetting)
        return (duration / goal) * 100
    }
    
    func estimatedEnd(forDuration sessionLength: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: Int((Double(sessionLength) - duration) * 3600), to: Date())
    }
}
