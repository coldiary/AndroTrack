//
//  Graph.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-17.
//

import SwiftUI

struct GraphView: View {
    
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    func dayAbbreviationBack(to: Int) -> String {
        guard let date = Calendar.current.getDateBack(to: to) else { return "" }
        return Calendar.current.veryShortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
    
    func getDayFromDate(date: Date) -> Day {
        return recordStore.getDay(forDate: date)
    }
    
    func computeGraphValueBack(to dayBack: Int) -> GraphValue {
        let emptyValue = GraphValue(
            value: 0,
            label: "",
            axisLabel: dayAbbreviationBack(to: 13 - dayBack)
        )
        if let dateBack = Calendar.current.getDateBack(to: 13 - dayBack) {
           let day = getDayFromDate(date: dateBack)
            return GraphValue(
                value: day.duration,
                label: "\(Int(day.duration))h",
                axisLabel: dayAbbreviationBack(to: 13 - dayBack)
            )
        } else {
            return emptyValue
        }
    }
    
    var items: [GraphValue] {
        return (0..<14).map(computeGraphValueBack)
    }
    
    var dateRangeText: String {
        let startText = Calendar.current.getDateBack(to: 14)?.shortDate() ?? ""
        let endText = Date().shortDate()
        return "\(startText) - \(endText)"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("WEARING_TIME")
                .font(.headline)
            HStack {
                Spacer()
                Text(dateRangeText)
                    .font(.footnote)
            }
            HStack(alignment: .center, spacing: 0) {
                Graph(items: items, maxValue: 24, color: settingsStore.themeColor)
            }.frame(height: 200)
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
