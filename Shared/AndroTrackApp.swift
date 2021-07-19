//
//  AndroTrackApp.swift
//  Shared
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

@main
struct AndroTrackApp: App {
    @StateObject private var recordStore = RecordStore.shared
    @StateObject private var settingsStore = SettingsStore.shared
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @UIApplicationDelegateAdaptor(AndroTrackAppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(settingsStore.themeColor)
                .preferredColorScheme(.dark)
                .environmentObject(recordStore)
                .environmentObject(settingsStore)
                .onReceive(timer) { _ in
                    recordStore.objectWillChange.send()
                }
        }
    }
}
