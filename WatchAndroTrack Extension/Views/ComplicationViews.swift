//
//  ComplicationViews.swift
//  WatchAndroTrack Extension
//
//  Created by Benoit Sida on 2021-07-18.
//

import SwiftUI
import ClockKit

struct ComplicationViewCircular: View {
    var duration: Double
    var progress: Double
    var color: Color = Color.teal
    
    var body: some View {
        ZStack {
            if progress < 100 {
                ProgressView("\(Int(duration)) h", value: progress, total: 100)
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .complicationForeground()
            } else {
                ProgressView(value: progress, total: 100) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                        .complicationForeground()
                }
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .complicationForeground()
            }
        }
    }
}

struct ComplicationViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CLKComplicationTemplateGraphicCircularView(
                ComplicationViewCircular(duration: 8, progress: 53, color: Color.teal)
                    .environmentObject(RecordStore.shared)
                    .environmentObject(SettingsStore.shared)
            ).previewContext()
            
            CLKComplicationTemplateGraphicCircularView(
                ComplicationViewCircular(duration: 15, progress: 100, color: Color.teal)
                    .environmentObject(RecordStore.shared)
                    .environmentObject(SettingsStore.shared)
            ).previewContext()
        }
    }
}
