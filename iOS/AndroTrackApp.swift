//
//  AndroTrackApp.swift
//  Shared
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

@main
struct AndroTrackApp: App {
    @StateObject private var settingsStore = SettingsStore.shared
    @UIApplicationDelegateAdaptor(AndroTrackAppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RequirementView()
                .environmentObject(settingsStore)
                .preferredColorScheme(.dark)
        }
    }
}
