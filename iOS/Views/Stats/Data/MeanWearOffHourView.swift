//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct MeanWearOffHourView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        DataCell(
            label: "MEAN_WEAR_OFF_HOUR".localized,
            value: recordStore.stats?.meanWearOffHour ?? "-",
            color: settingsStore.themeColor,
            labelSize: 11,
            valueSize: 24
        )
    }
}

struct MeanWearOffHourView_Previews: PreviewProvider {
    static var previews: some View {
        MeanWearOffHourView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
