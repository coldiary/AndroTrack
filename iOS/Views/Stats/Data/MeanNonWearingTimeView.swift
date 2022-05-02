//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct MeanNonWearingTimeView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        DataCell(
            label: "MEAN_NON_WEARING_TIME".localized,
            value: recordStore.stats?.meanNonWearingTime ?? "-",
            color: settingsStore.themeColor
        )
    }
}

struct MeanNonWearingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        MeanNonWearingTimeView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
