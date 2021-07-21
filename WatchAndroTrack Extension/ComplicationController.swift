//
//  ComplicationController.swift
//  WatchAndroTrack Extension
//
//  Created by Benoit Sida on 2021-07-18.
//

import ClockKit
import SwiftUI

enum ComplicationIdentifier: String {
    case Duration = "complication_duration"
    case EstimatedEnd = "complication_estimatedEnd"
}


class ComplicationController: NSObject, CLKComplicationDataSource {
    let recordStore = RecordStore.shared
    let settingsStore = SettingsStore.shared
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: ComplicationIdentifier.Duration.rawValue, displayName: "Session duration", supportedFamilies: [
                CLKComplicationFamily.circularSmall,
                CLKComplicationFamily.graphicCircular,
                CLKComplicationFamily.graphicCorner,
            ]),
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(recordStore.current.estimatedEnd(forDuration: settingsStore.sessionLength + 1))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        if let template = makeTemplateFor(complication: complication, data: .init(
            duration: recordStore.current.duration,
            sessionLength: settingsStore.sessionLength,
            color: settingsStore.themeColor
        )) {
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var complications: [CLKComplicationTimelineEntry] = []
        var next = date
        while complications.count < limit {
            next = next.advanced(by: TimeInterval.fiveMinutes)
            if let duration = Calendar.current.dateComponents([.minute], from:  date, to: next).minute {
                if let template = makeTemplateFor(complication: complication, data: ComplicationDisplayedData(
                    duration: recordStore.current.duration + Double(duration / 60),
                    sessionLength: settingsStore.sessionLength,
                    color: settingsStore.themeColor
                )) {
                    complications.append(.init(date: next, complicationTemplate: template))
                }
            }
        }
        
        handler(complications)
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if let template = makeTemplateFor(complication: complication, data: .init(duration: 9, sessionLength: 15, color: Color.teal)) {
            handler(template)
        } else {
            handler(nil)
        }
    }
}

extension ComplicationController {
    func makeTemplateFor(complication: CLKComplication, data: ComplicationDisplayedData) -> CLKComplicationTemplate? {
        switch complication.family {
            case .graphicCircular:
                return Complications.makeGraphicCircular(data)
            case .circularSmall:
                return Complications.makeCircularSmall(data)
            case .graphicCorner:
                return Complications.makeGraphicCorner(data)
        default:
            return nil
        }
    }
}
