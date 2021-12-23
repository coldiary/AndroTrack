//
//  TodayView.swift
//  WatchAndroTrack Extension
//
//  Created by Benoit Sida on 2021-07-18.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        return recordStore.current.durationAsProgress(goal: settingsStore.sessionLength)
    }
    
    var durationAsText: String {
        return "\(Int(recordStore.current.duration)) h"
    }
    
    var body: some View {
        VStack(alignment: .center) {
                Text("TODAY")
                .font(.largeTitle)
                .foregroundColor(settingsStore.themeColor)
                .padding(.bottom)
            
                Button(action: {
                    if recordStore.state == .off {
                        recordStore.markAsWorn()
                    } else {
                        recordStore.markAsRemoved()
                    }
                }) {
                    ZStack() {
                        TimeRingView(
                            progress: progress,
                            ringWidth: 15,
                            color: settingsStore.themeColor
                        ).scaledToFit()
                        VStack {
                            Text(durationAsText)
                                .font(.title3)
                                .padding(.bottom)
                            Text(recordStore.state == .off ? "WEAR" : "REMOVE")
                                .bold()
                        }
                    }.onAppear {
                        print(settingsStore.themeColor.toHexString())
                    }
                }.buttonStyle(PlainButtonStyle())
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .previewDevice("Apple Watch Series 5 - 44mm")
        
        TodayView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}
