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
    
    @State private var page = 1
    
    var interval: DateInterval? {
        guard let start = Date().removeMonths(QUARTER_IN_MONTHS * page) else {
            return nil
        }
        return DateInterval(start: start, end: Date())
    }
    
    private var loadingThreshold: Int {
        (page - 1) * QUARTER_IN_MONTHS + (QUARTER_IN_MONTHS - 1)
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
                                if date.diffInMonths(to: Date()) > loadingThreshold {
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
