//
//  WeekView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

struct WeekView<DateView>: View where DateView: View {
    let week: Date
    let content: (Date) -> DateView

    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self.content = content
    }

    private var days: [Date] {
        guard
            let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: week)
            else { return [] }
        return Calendar.current.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        ).reversed()
    }

    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                HStack {
                    if Calendar.current.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.content(date)
                    } else {
                        self.content(date).hidden()
                    }
                }
            }
        }
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(week: Date()) { date in
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
