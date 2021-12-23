//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct MeanWearingTimeView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        DataCell(
            label: "MEAN_WEARING_TIME".localized,
            value: "\(recordStore.meanWearingTime(days: 30))",
            color: settingsStore.themeColor
        )
    }
}

struct MeanWearingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        MeanWearingTimeView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
