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
    
    func durationAsProgress(goal currentGoalSetting: Int) -> Double
    func estimatedEnd(forDuration sessionLength: Int) -> Date?
}

