//
//  CalendarView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-14.
//

import SwiftUI

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let interval: DateInterval
    let content: (Date) -> DateView

    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }

    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        ).reversed()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(months, id: \.self) { month in
                    MonthView(month: month, content: self.content)
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static let calendarViews: [DateInterval] = [
        Calendar.current.dateInterval(of: .month, for: Date())!,
        Calendar.current.dateInterval(of: .month, for: Calendar.current.date(byAdding: .month, value: -1, to: Date())!)!,
        Calendar.current.dateInterval(of: .month, for: Calendar.current.date(byAdding: .month, value: -2, to: Date())!)!,

        Calendar.current.dateInterval(of: .month, for: Calendar.current.date(byAdding: .month, value: -3, to: Date())!)!,
    ]
    static var previews: some View {
        ScrollView {
            LazyVStack {
                ForEach(calendarViews.indices, id: \.self) { index in
                    CalendarView(interval: calendarViews[index]) { date in
                        Text("30")
                            .hidden()
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .padding(.vertical, 4)
                            .overlay(
                                Text(String(Calendar.current.component(.day, from: date)))
                            )
                    }
                }
            }
        }.preferredColorScheme(.dark)
    }
}
