//
//  SettingsStore.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-07-16.
//

import Foundation
import SwiftUI
import Combine

#if os(watchOS)
import ClockKit
#endif

class SettingsStore: ObservableObject {
    public static let shared = SettingsStore()
    
    private var watchConnectivity = WatchConnectivity.shared
    private var subscription: AnyCancellable?
    
    @Published var themeColor: Color {
        didSet {
            UserDefaults.standard.set(themeColor, forKey: "themeColor")
            watchConnectivity.sync()
        }
    }
    
    @Published var sessionLength: Int {
        didSet {
            UserDefaults.standard.set(sessionLength, forKey: "sessionLength")
            watchConnectivity.sync()
            Notifications.scheduleNotifyEnd()
        }
    }
    
    @Published var notifications: NotificationsSettings {
        didSet {
            do {
                try UserDefaults.standard.trySet(notifications, forKey: "notifications")
            } catch {
                AppLogger.warning(context: "SettingsStore", "Unable to save notifications settings")
            }
        }
    }
    
    @Published var currentView: CurrentViewSettings {
        didSet {
            do {
                try UserDefaults.standard.trySet(currentView, forKey: "currentView")
            } catch {
                AppLogger.warning(context: "SettingsStore", "Unable to save currentView settings")
            }
        }
    }
    
    public var appContext: [String:Any] {[
        "themeColor": themeColor.toHexString(),
        "sessionLength": sessionLength
    ]}
    
    private init() {
        if let storedThemeColor = UserDefaults.standard.color(forKey: "themeColor") {
            themeColor = storedThemeColor
        } else {
            themeColor = Color.red
        }
        sessionLength = UserDefaults.standard.nonNulInteger(forKey: "sessionLength") ?? 15
        notifications = UserDefaults.standard.typed(forKey: "notifications") ?? NotificationsSettings()
        currentView = UserDefaults.standard.typed(forKey: "currentView") ?? CurrentViewSettings.Today
        
        #if os(watchOS)
        subscription = watchConnectivity.publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: onReceiveContextUpdate)
        #endif
    }
    
    #if os(watchOS)
    private func onReceiveContextUpdate(context: [String:Any]) {
        for (key, progress) in context {
            switch key {
                case "themeColor":
                    if (self.themeColor != Color(hexString: progress as! String)) {
                        self.themeColor = Color(hexString: progress as! String) ?? Color.tealCompat
                    }
                case "sessionLength":
                    if (self.sessionLength != progress as! Int) {
                        self.sessionLength = progress as! Int
                    }
                default: continue
            }
        }
        let complicationServer = CLKComplicationServer.sharedInstance()
        for complication in complicationServer.activeComplications ?? [] {
            complicationServer.reloadTimeline(for: complication)
        }
    }
    #endif
    
    deinit {
        subscription?.cancel()
    }
}
