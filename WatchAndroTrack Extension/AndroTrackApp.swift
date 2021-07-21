//
//  AndroTrackApp.swift
//  WatchAndroTrack Extension
//
//  Created by Benoit Sida on 2021-07-18.
//

import SwiftUI
import ClockKit

@main
struct AndroTrackApp: App {
    @StateObject private var recordStore = RecordStore.shared
    @StateObject private var settingsStore = SettingsStore.shared
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .accentColor(settingsStore.themeColor)
                    .environmentObject(recordStore)
                    .environmentObject(settingsStore)
                    .onAppear() {
                        let complicationServer = CLKComplicationServer.sharedInstance()
                        for complication in complicationServer.activeComplications ?? [] {
                            complicationServer.reloadTimeline(for: complication)
                        }
                    }
                    .onReceive(timer) { _ in
                        self.recordStore.objectWillChange.send()
                    }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
