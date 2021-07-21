//
//  NotificationsSettings.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-19.
//

import Foundation

struct NotificationsSettings: Codable {
    var reminderStart: Bool = false
    var notifyEnd: Bool = false
    var reminderTime: Date = Calendar.current.startOfDay(for: Date())
}

extension NotificationsSettings: CustomStringConvertible {
    var description: String {
        """
        {
                reminderStart: \(reminderStart),
                notifyEnd: \(notifyEnd),
                reminderTime: \(reminderTime)
            }
        """
    }
}
