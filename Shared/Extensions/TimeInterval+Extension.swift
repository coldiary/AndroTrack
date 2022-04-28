//
//  TimeInterval+Extension.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation

extension TimeInterval {
    static let second: Self = 1
    static let minute: Self = 60
    static let hour: Self = 3600
    
    static func hours(_ hours: Int) -> Self { hour * Double(hours) }
    static func minutes(_ minutes: Int) -> Self { minute * Double(minutes) }
}
