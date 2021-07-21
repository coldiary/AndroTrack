//
//  Notifications.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-20.
//

import Foundation
import UserNotifications

class Notifications {
    
    static func checkSettings(completion: @escaping (UNNotificationSettings?) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings)
        }
    }
    
    static func requestAuthorization(completion: @escaping (Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    static func scheduleNotification(_ content:UNNotificationContent, at dateComps: DateComponents, repeats: Bool = false, forId id: String = UUID().uuidString) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.alertSetting == .enabled else {
                AppLogger.info(context: "Notifications", "Alert Notification unavailable: \(settings.alertSetting)")
                return
            }
            
            // show this notification five seconds from now
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: repeats)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    static func cancelNotificationWith(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

extension Notifications {
    static func scheduleNotifyEndNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sesssion complete !"
        content.subtitle = "It's time to remove the ring now."
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
        
        Notifications.scheduleNotification(content, at: dateComponents, forId: NotificationType.notifyEnd.rawValue)
    }
    
    static func cancelNotifyEndNotification() {
        Notifications.cancelNotificationWith(id: NotificationType.notifyEnd.rawValue)
    }
}

extension Notifications {
    static func scheduleReminderStartNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Sesssion start"
        content.subtitle = "Don't forget to put your ring on for the day !"
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: SettingsStore.shared.notifications.reminderTime)
        
        Notifications.scheduleNotification(content, at: dateComponents, repeats: true, forId: NotificationType.reminderStart.rawValue)
    }
    
    static func cancelReminderStartNotification() {
        Notifications.cancelNotificationWith(id: NotificationType.reminderStart.rawValue)
    }
}
