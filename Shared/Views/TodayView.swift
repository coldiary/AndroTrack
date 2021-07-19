//
//  TodayView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    var progress: Double {
        return recordStore.current.durationAsProgress(goal: settingsStore.sessionLength)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center) {
                    ZStack() {
                        TimeRingView(progress: progress, color: settingsStore.themeColor)
                            .frame(width: 300, height: 300)
                        VStack {
                            Text("\(Int(recordStore.current.duration)) h")
                                .font(.largeTitle)
                                .padding(.bottom, 50)
                            Button(action: {
                                if recordStore.state == .off {
                                    recordStore.markAsWorn()
                                } else {
                                    recordStore.markAsRemoved()
                                }
                            }) {
                                Text(recordStore.state == .off ? "WEAR" : "REMOVE")
                                    .bold()
                            }
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .cornerRadius(50)
                        }
                    }
                    Spacer()
                    VStack {
                        ForEach(recordStore.current.records.sorted { $0 > $1}) { record in
                            RecordView(record: record,
                                       ringColor: settingsStore.themeColor,
                                       sessionLength: settingsStore.sessionLength,
                                       showDate: false,
                                       estimatedEnd: recordStore.current.estimatedEnd(forDuration: settingsStore.sessionLength)
                            ).onAppear() {
                                print(recordStore.current.estimatedEnd(forDuration: settingsStore.sessionLength)!)
                            }
                        }
                    }.padding()
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
            }
            .padding()
            .onAppear() {
                print(settingsStore.themeColor.toHexString())
            }
            .navigationTitle("Today")
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
            .environmentObject(RecordStore.shared)
            .preferredColorScheme(.dark)
    }
}
