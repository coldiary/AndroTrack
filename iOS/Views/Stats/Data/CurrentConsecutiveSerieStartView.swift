//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct CurrentConsecutiveSerieStartView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        DataCell(
            label: "CURRENT_CONSECUTIVE_SERIE_START".localized,
            value: recordStore.consecutiveSerieStart(goal: settingsStore.sessionLength),
            color: settingsStore.themeColor,
            labelSize: 11,
            valueSize: 24
        )
    }
}

struct CurrentConsecutiveSerieStartView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentConsecutiveSerieStartView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
