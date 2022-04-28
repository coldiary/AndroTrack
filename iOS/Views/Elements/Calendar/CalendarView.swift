//
//  CalendarView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-14.
//

import SwiftUI

struct CalendarView<DateView>: View where DateView: View {
    let interval: DateInterval
    let content: (Date) -> DateView

    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }

    private var months: [Date] {
        Calendar.current.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        ).reversed()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(months, id: \.self) { month in
                    MonthView(month: month, content: self.content)
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static let interval: DateInterval = DateInterval(
            start: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            end: Date()
    )
    
    static var previews: some View {
        CalendarView(interval: interval) { date in
            Text("30")
                .hidden()
                .padding(8)
                .background(Color.blue)
                .clipShape(Circle())
                .padding(.vertical, 4)
                .overlay(
                    Text(String(Calendar.current.component(.day, from: date)))
                )
        }.preferredColorScheme(.dark)
    }
}
