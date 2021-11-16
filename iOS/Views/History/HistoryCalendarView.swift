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
        LazyVStack {
            if let interval = interval {
                HStack {
                    CalendarView(interval: interval) { date in
                        if let day = recordStore.getDay(forDate: date) {
                            NavigationLink(destination: HistoryDayView(date: date)) {
                                VStack {
                                    Text(String(Calendar.current.component(.day, from: date)))
                                    ZStack {
                                            if Calendar.current.isDateInToday(date) {
                                                Circle()
                                                    .fill(settingsStore.themeColor)
                                                    .opacity(0.33)
                                                    .clipShape(Circle())
                                            }
                                            TimeRingView(progress: day.durationAsProgress(goal: settingsStore.sessionLength), color: settingsStore.themeColor)
                                            Text(day.duration > 0 ? "\(Int(day.duration))h" : "-")
                                                .opacity(0.8)
                                                .padding(12)
                                                .minimumScaleFactor(0.01)
                                                .lineLimit(1)
                                    }
                                }
                            }.buttonStyle(PlainButtonStyle())
                            
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
