//
//  Calendar.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

struct HistoryCalendarView: View {
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    var interval: DateInterval? {
        if let start = recordStore.records.first?.start,
           let end = recordStore.records.last?.start {
            return DateInterval(start: start, end: end)
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            if let interval = interval {
                HStack {
                    CalendarView(interval: interval) { date in
                        HistoryCalendarDayView(
                            date: date,
                            day: recordStore.getDay(forDate: date),
                            sessionLength: settingsStore.sessionLength,
                            color: settingsStore.themeColor
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct HistoryCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryCalendarView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
