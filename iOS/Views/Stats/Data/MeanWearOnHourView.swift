//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct MeanWearOnHourView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        DataCell(
            label: "MEAN_WEAR_ON_HOUR".localized,
            value: recordStore.stats?.meanWearOnHour ?? "-",
            color: settingsStore.themeColor,
            labelSize: 11,
            valueSize: 24
        )
    }
}

struct MeanWearOnHourView_Previews: PreviewProvider {
    static var previews: some View {
        MeanWearOnHourView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
