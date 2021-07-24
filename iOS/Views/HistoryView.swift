//
//  HistoryView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(recordStore.records.sorted { $0 > $1}) { record in
                        RecordView(record: record,
                                   ringColor: settingsStore.themeColor,
                                   sessionLength: settingsStore.sessionLength
                        )
                    }
                }.padding()
            }
            .navigationTitle("History")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
