//
//  TodayView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct RecordView: View {
    var record: Record
    var ringColor: Color = Color.accentColor
    var sessionLength = 15
    var showDate = true
    var estimatedEnd: Date?
    
    @State private var estimatedEndOpacity = 1.0
    
    var progress: Double {
        return record.durationAsProgress(goal: 15)
    }
    
    var title: String {
        if let start = record.start {
            if (!Calendar.current.isDateInToday(start)) {
                return start.format(timeFormat: .none)
            }
        }
        return "TODAY".localized
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showDate {
                HStack {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            HStack {
                HStack(alignment: .center, spacing: 50) {
                    VStack(alignment: .leading) {
                        Text("START")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 1)
                        if let start = record.start {
                            Text(start, style: .time)
                        } else {
                            Text("-").padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("END")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 1)
                        if let end = record.end {
                            Text(end, style: .time)
                        } else if record.start != nil && estimatedEnd != nil {
                            Text(estimatedEnd!, style: .time)
                                .opacity(estimatedEndOpacity)
                                .onAppear() {
                                    estimatedEndOpacity = 0.25
                                }
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
                        } else {
                            Text("-").padding(.horizontal)
                        }
                    }
                }
                Spacer()
                ZStack {
                    TimeRingView(progress: progress, ringWidth: 10, color: ringColor)
                        .frame(width: 80, height: 80, alignment: .center)
                    Text((record.durationInHours != nil ? "\(Int(record.durationInHours!)) h" : "-"))
                        .bold()
                        .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .cornerRadius(12)
    }
}

struct RecordView_Previews: PreviewProvider {
    static let day = Day(records: [Record(start: Date())])
    static var previews: some View {
        RecordView(record: day.records.last!, estimatedEnd: day.estimatedEnd(forDuration: 2)).preferredColorScheme(.dark)
    }
}
