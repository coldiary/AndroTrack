//
//  MonthView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

struct MonthView<DateView>: View where DateView: View {
    let month: Date
    let showHeader: Bool
    let content: (Date) -> DateView

    init(
        month: Date,
        showHeader: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
        self.showHeader = showHeader
    }

    private var weeks: [Date] {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: month)
            else { return [] }
        return Calendar.current.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: Calendar.current.firstWeekday)
        ).reversed()
    }

    private var header: some View {
        let component = Calendar.current.component(.month, from: month)
        let formatter = component == 12 ? DateFormatter.monthAndYear : .month
        return Text(formatter.string(from: month).capitalized)
            .font(.title)
            .padding()
    }

    var body: some View {
        VStack(alignment: .leading) {
            if showHeader {
                header
            }

            ForEach(weeks, id: \.self) { week in
                WeekView(week: week, content: self.content)
            }
        }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(month: Date()) { date in 
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
