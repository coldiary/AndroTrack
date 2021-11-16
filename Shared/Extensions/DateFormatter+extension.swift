//
//  DateFormatter+extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import Foundation

extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
