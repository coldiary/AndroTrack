//
//  ContentView.swift
//  Shared
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @StateObject private var recordStore = RecordStore.shared
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            if settingsStore.currentView == .Today {
                TodayView()
                    .tabItem {
                        Image(systemName: "circle.circle")
                        Text("TODAY")
                    }
            } else {
                CurrentView()
                    .tabItem {
                        Image(systemName: "circle.circle")
                        Text("RECENT")
                    }
            }
            
            
            HistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("HISTORY")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("STATS")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("SETTINGS")
                }
        }
        .accentColor(settingsStore.themeColor)
        .environmentObject(recordStore)
        .onReceive(timer) { _ in
            recordStore.objectWillChange.send()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}
