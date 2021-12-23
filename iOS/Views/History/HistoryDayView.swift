//
//  HistoryDayView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

struct HistoryDayView: View {
    let date: Date
    
    var day: Day {
        return recordStore.getDay(forDate: date)
    }
    
    var durationAsText: String {
        let duration = Int(day.duration)
        return "\(duration) h"
    }
    
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    var body: some View {
        VStack {
            ZStack() {
                TimeRingView(progress: day.durationAsProgress(goal: settingsStore.sessionLength), color: settingsStore.themeColor)
                    .frame(width: 150, height: 150)
                VStack {
                    Text(durationAsText)
                        .font(.largeTitle)
                }
            }.padding(.top, 50)
            Spacer()
            if #available(iOS 15.0, *) {
                HistoryListView(date: date)
            } else {
                HistoryListCompatView(date: date)
            }
        }.navigationTitle(date.format(dateFormat: .long, timeFormat: .none).capitalized)
    }
}

struct HistoryDayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryDayView(date: Date())
                .environmentObject(RecordStore.shared)
                .environmentObject(SettingsStore.shared)
                .preferredColorScheme(.dark)
        }
    }
}
