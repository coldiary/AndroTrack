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
    var progressFrom: Date?
    
    @State private var estimatedEndOpacity = 1.0
    
    var progress: Double {
        if let progressFrom = progressFrom {
            return record.durationAsProgressFrom(progressFrom, goal: sessionLength)
        } else {
            return record.durationAsProgress(goal: sessionLength)
        }
    }
    
    var title: String {
        if (!Calendar.current.isDateInToday(record.start)) {
            return record.start.format(timeFormat: .none)
        }
        return "TODAY".localized
    }
    
    var recordDurationAsText: String {
        if let progressFrom = progressFrom {
            return "\(Int(record.durationFrom(progressFrom, in: .hour))) h"
        } else {
            return "\(Int(record.durationInHours)) h"
        }
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
                        if record.end != Date.distantFuture {
                            Text(record.end, style: .time)
                        } else if estimatedEnd != nil {
                            Text(estimatedEnd!, style: .time)
                                .opacity(estimatedEndOpacity)
                                .onAppear() {
                                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                        estimatedEndOpacity = 0.25
                                    }
                                }
                        } else {
                            Text("-")
                                .padding(.horizontal)
                        }
                    }
                }
                Spacer()
                ZStack {
                    TimeRingView(progress: progress, ringWidth: 10, color: ringColor)
                        .frame(width: 80, height: 80, alignment: .center)
                    Text(recordDurationAsText)
                        .bold()
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static let day = Day(records: [Record(start: Date())])
    static var previews: some View {
        RecordView(record: day.records.last!, estimatedEnd: day.estimatedEnd(forDuration: 2)).preferredColorScheme(.dark)
    }
}
