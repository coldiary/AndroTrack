//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct FirstRecordDateView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        DataCell(
            label: "FIRST_RECORD_DATE".localized,
            value: recordStore.stats?.firstRecordDate ?? "-",
            color: settingsStore.themeColor,
            labelSize: 11,
            valueSize: 24
        )
    }
}

struct FirstRecordDateView_Previews: PreviewProvider {
    static var previews: some View {
        FirstRecordDateView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
