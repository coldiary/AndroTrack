//
//  HistoryView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var recordStore: RecordStore
    
    var body: some View {
        NavigationView {
            ScrollView() {
                HistoryCalendarView()
            }
            .navigationTitle("HISTORY")
        }.navigationViewStyle(StackNavigationViewStyle())
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
