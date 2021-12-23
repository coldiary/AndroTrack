//
//  GraphicCircular.swift
//  WatchAndroTrack Extension
//
//  Created by Benoit Sida on 2021-07-21.
//

import SwiftUI
import ClockKit

struct ComplicationDisplayedData {
    var duration: Double
    var sessionLength: Int
    var color: Color
}

struct CircularOpenGaugeCenterImageView: View {
    let progress: Float
    let imageName: String
    var color: Color = Color.white
    var leadingText: String = ""
    var trailingText: String = ""
    
    var body: some View {
        ZStack {
            Gauge(value: progress, in: 0...1) {
            } currentValueLabel: {
                Image(systemName: imageName)
                    .foregroundColor(color)
                    .complicationForeground()
            } minimumValueLabel: {
                Text(leadingText)
            } maximumValueLabel: {
                Text(trailingText)
            }
            .gaugeStyle(CircularGaugeStyle(tint: color))
            .complicationForeground()
            
        }
    }
}

struct Complications {
    static func makeGraphicCircular(_ data: ComplicationDisplayedData) -> CLKComplicationTemplate {
        let progress = Float(data.duration / Double(data.sessionLength))
        if progress >= 1 {
            return CLKComplicationTemplateGraphicCircularView(
                CircularOpenGaugeCenterImageView(
                    progress: 1,
                    imageName: "checkmark.circle.fill",
                    color: data.color,
                    trailingText: "\(data.sessionLength)"
                )
            )
        } else {
            return CLKComplicationTemplateGraphicCircularOpenGaugeRangeText(
                gaugeProvider: CLKSimpleGaugeProvider(
                    style: .fill,
                    gaugeColor: UIColor(data.color),
                    fillFraction: progress
                ),
                leadingTextProvider: CLKSimpleTextProvider(text: ""),
                trailingTextProvider: CLKSimpleTextProvider(text: "\(data.sessionLength)"),
                centerTextProvider: CLKSimpleTextProvider(text: "\(Int(data.duration))")
            )
        }
    }
    
    static func makeCircularSmall(_ data: ComplicationDisplayedData) -> CLKComplicationTemplate {
        let progress = Float(data.duration / Double(data.sessionLength))
        return CLKComplicationTemplateCircularSmallRingText(
            textProvider: CLKSimpleTextProvider(text: progress >= 1 ? "✓" : "\(Int(data.duration))h"),
            fillFraction: progress,
            ringStyle: .open
        )
    }
    
    static func makeGraphicCorner(_ data: ComplicationDisplayedData) -> CLKComplicationTemplate {
        let progress = Float(data.duration / Double(data.sessionLength))
        if progress <= 1 {
            return CLKComplicationTemplateGraphicCornerGaugeText(
                gaugeProvider: CLKSimpleGaugeProvider(
                    style: .fill,
                    gaugeColor: UIColor(data.color),
                    fillFraction: progress
                ),
                leadingTextProvider: CLKSimpleTextProvider(text: ""),
                trailingTextProvider: CLKSimpleTextProvider(text: "\(data.sessionLength)"),
                outerTextProvider: CLKSimpleTextProvider(text: progress >= 1 ? "✓" : "\(Int(data.duration))h")
            )
        } else {
            return CLKComplicationTemplateGraphicCornerGaugeImage(
                gaugeProvider: CLKSimpleGaugeProvider(
                    style: .fill,
                    gaugeColor: UIColor(data.color),
                    fillFraction: 1
                ),
                imageProvider: CLKFullColorImageProvider(
                    fullColorImage: UIImage(systemName: "checkmark.circle.fill")!
                        .withTintColor(UIColor(data.color), renderingMode: .alwaysOriginal)
                )
            )
        }
    }
}

struct GraphicCircular_Previews: PreviewProvider {
    static let data = ComplicationDisplayedData(duration: 16, sessionLength: 15, color: Color.tealCompat)
    static var previews: some View {
        Group {
            Complications.makeGraphicCircular(data)
                .previewContext(faceColor: .multicolor)
            
            Complications.makeCircularSmall(data)
                .previewContext(faceColor: .multicolor)
            
            Complications.makeGraphicCorner(data)
                .previewContext(faceColor: .multicolor)
        }
        .accentColor(data.color)
        .previewDevice("Apple Watch Series 5 - 44mm")
    }
}
