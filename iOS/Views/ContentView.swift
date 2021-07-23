//
//  ContentView.swift
//  Shared
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var recordStore = RecordStore.shared
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "circle.circle")
                    Text("Today")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("History")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Settings")
                }
        }
        .environmentObject(recordStore)
        .onReceive(timer) { _ in
            recordStore.objectWillChange.send()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RecordStore.shared)
            .preferredColorScheme(.dark)
            .accentColor(.red)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}
