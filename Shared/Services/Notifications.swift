//
//  Notifications.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-20.
//

import Foundation
import UserNotifications

class Notifications {
    
    static let UNCenter = UNUserNotificationCenter.current()
    
    static func checkSettings(completion: @escaping (UNNotificationSettings?) -> Void) {
        UNCenter.getNotificationSettings { settings in
            completion(settings)
        }
    }
    
    static func requestAuthorization(completion: @escaping (Error?) -> Void) {
        UNCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    static func scheduleNotification(_ content:UNNotificationContent, at dateComps: DateComponents, repeats: Bool = false, forId id: String = UUID().uuidString) {
        UNCenter.getNotificationSettings { settings in
            guard settings.alertSetting == UNNotificationSetting.enabled else {
                AppLogger.info(context: "Notifications", "Alert Notification unavailable: \(settings.alertSetting)")
                return
            }
            
            // show this notification five seconds from now
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: repeats)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            // add our notification request
            UNCenter.add(request)
        }
    }
    
    static func cancelNotificationWith(id: String) {
        UNCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}

extension Notifications {
    static func scheduleNotifyEndNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("NOTIFY_END_NOTIF.TITLE", comment: "")
        content.subtitle = NSLocalizedString("NOTIFY_END_NOTIF.SUBTITLE", comment: "")
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
        
        Notifications.scheduleNotification(content, at: dateComponents, forId: NotificationType.notifyEnd.rawValue)
    }
    
    static func cancelNotifyEndNotification() {
        Notifications.cancelNotificationWith(id: NotificationType.notifyEnd.rawValue)
    }
    
    static func scheduleNotifyEnd() {
        if SettingsStore.shared.notifications.notifyEnd {
            guard let estimatedEnd = RecordStore.shared.current.estimatedEnd(forDuration: SettingsStore.shared.sessionLength) else {
                AppLogger.error(context: "RecordStore", "Can't determine estimatedEnd")
                return
            }
            
            Notifications.cancelReminderStartNotification()
            Notifications.cancelNotifyEndNotification()
            Notifications.scheduleNotifyEndNotification(at: estimatedEnd)
        }
    }
}

extension Notifications {
    static func scheduleReminderStartNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("REMINDED_START_NOTIF.TITLE", comment: "")
        content.subtitle = NSLocalizedString("REMINDED_START_NOTIF.SUBTITLE", comment: "")
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: SettingsStore.shared.notifications.reminderTime)
        
        Notifications.scheduleNotification(content, at: dateComponents, repeats: true, forId: NotificationType.reminderStart.rawValue)
    }
    
    static func cancelReminderStartNotification() {
        Notifications.cancelNotificationWith(id: NotificationType.reminderStart.rawValue)
    }
    
    static func scheduleReminderStart() {
        if SettingsStore.shared.notifications.reminderStart {
            Notifications.cancelNotifyEndNotification()
            Notifications.cancelReminderStartNotification()
            Notifications.scheduleReminderStartNotification()
        }
    }
}
