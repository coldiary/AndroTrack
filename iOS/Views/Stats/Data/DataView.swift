//
//  DataView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-21.
//

import SwiftUI

struct DataView: View {
    var items: [GridItem] = [
        GridItem(.flexible(minimum: 120), spacing: 10, alignment: .topLeading),
        GridItem(.flexible(minimum: 120), alignment: .topLeading)
    ]
    
    var body: some View {
        LazyVGrid(columns: items, alignment: .leading, spacing: 10) {
            MeanWearingTimeView()
            MeanNonWearingTimeView()
            ConsecutiveAchievedGoalView()

            HStack(alignment: .top) {
                MeanWearOnHourView()
                MeanWearOffHourView()
            }

            CurrentConsecutiveSerieStartView()

            FirstRecordDateView()
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
