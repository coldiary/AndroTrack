//
//  WearingMeanTimeView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct ConsecutiveAchievedGoalView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var settingsStore: SettingsStore
    
    private func getDayFromDate(date: Date) -> Day {
        return recordStore.getDay(forDate: date)
    }
    
    var body: some View {
        DataCell(
            label: "CONSECUTIVE_ACHIEVED_GOAL".localized,
            value: recordStore.stats?.consecutiveSerie ?? "-",
            color: settingsStore.themeColor,
            valueSize: 40
        )
    }
}

struct ConsecutiveAchievedGoalView_Previews: PreviewProvider {
    static var previews: some View {
        ConsecutiveAchievedGoalView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
