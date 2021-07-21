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
        }
    }
    
    @Published var notifications: NotificationsSettings {
        didSet {
            do {
                try UserDefaults.standard.trySet(notifications, forKey: "notifications")
            } catch {
                print("[SettingsStore] Unable to save notifications settings")
            }
        }
    }
    
    public var appContext: [String:Any] {[
        "themeColor": themeColor.toHexString(),
        "sessionLength": sessionLength
    ]}
    
    private init() {
        themeColor = UserDefaults.standard.color(forKey: "themeColor") ?? Color.teal
        sessionLength = UserDefaults.standard.nonNulInteger(forKey: "sessionLength") ?? 15
        notifications = UserDefaults.standard.typed(forKey: "notifications") ?? NotificationsSettings()
        
        #if os(watchOS)
        subscription = watchConnectivity.publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: onReceiveContextUpdate)
        #endif
    }
    
    #if os(watchOS)
    private func onReceiveContextUpdate(context: [String:Any]) {
        for (key, value) in context {
            switch key {
                case "themeColor":
                    if (self.themeColor != Color(hexString: value as! String)) {
                        self.themeColor = Color(hexString: value as! String)
                    }
                case "sessionLength":
                    if (self.sessionLength != value as! Int) {
                        self.sessionLength = value as! Int
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
