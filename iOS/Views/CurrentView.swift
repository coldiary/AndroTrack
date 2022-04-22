//
//  CurrentView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2022-04-21.
//

import SwiftUI

struct CurrentView: View {
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
                                    .padding()
                                    .background(settingsStore.themeColor)
                                    .foregroundColor(settingsStore.themeColor == Color.white ? Color.black : Color.white)
                                    .cornerRadius(50)
                            }
                        }
                    }.padding(.top, 50)
                    Spacer()
                    VStack {
                        ForEach(recordStore.current.records.sorted { $0 > $1}) { record in
                            RecordView(record: record,
                                       ringColor: settingsStore.themeColor,
                                       sessionLength: settingsStore.sessionLength,
                                       showDate: false,
                                       estimatedEnd: recordStore.current.estimatedEnd(forDuration: settingsStore.sessionLength),
                                       progressFrom: Date().removeHours(24) < record.start ? nil : Date().removeHours(24)
                            ).padding()
                            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .cornerRadius(12)
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
            .navigationTitle("RECENT")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CurrentView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
