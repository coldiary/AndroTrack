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
    
    @State var page = 1
    
    var interval: DateInterval? {
        if let start = Calendar.current.date(byAdding: DateComponents(month: -3 * page), to: Date()) {
            return DateInterval(start: start, end: Date())
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            if let interval = interval {
                HStack {
                    CalendarView(interval: interval) { date in
                        if let day = recordStore.getDay(forDate: date) {
                            HistoryCalendarDayView(
                                date: date,
                                day: day,
                                sessionLength: settingsStore.sessionLength,
                                color: settingsStore.themeColor
                            )
                            .onAppear {
                                let monthDiff = Calendar.current.dateComponents([.month], from: date, to: Date()).month ?? 0
                                let threshold = (page - 1) * 3 + 2
                                if monthDiff > threshold {
                                    recordStore.loadHealthData(forQuarterAgo: page)
                                    page += 1
                                }
                            }
                        }
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
