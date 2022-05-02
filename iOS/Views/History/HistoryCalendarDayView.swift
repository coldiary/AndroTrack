//
//  Calendar.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

struct HistoryCalendarDayView: View {
    let date: Date
    let day: Day
    let sessionLength: Int
    let color: Color
    
    var progress: Double {
        day.durationAsProgress(goal: sessionLength)
    }
    
    var durationAsText: String {
        if day.duration > 0 {
            let durationAsInt = Int(day.duration)
            return "\(durationAsInt)h"
        } else {
            return "-"
        }
    }
    
    var body: some View {
        NavigationLink(destination: HistoryDayView(date: date)) {
            VStack {
                Text(String(Calendar.current.component(.day, from: date)))
                ZStack {
                        if Calendar.current.isDateInToday(date) {
                            Circle()
                                .fill(color)
                                .opacity(0.33)
                                .clipShape(Circle())
                        }
                        TimeRingView(progress: progress, color: color)
                        Text(durationAsText)
                            .opacity(0.8)
                            .padding(12)
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HistoryCalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryCalendarDayView(
            date: Date(),
            day: Day(),
            sessionLength: 15,
            color: Color.tealCompat
        )
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
