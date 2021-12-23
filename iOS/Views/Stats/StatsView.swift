//
//  StatsView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-17.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var recordStore: RecordStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                DataView()
                    .padding()
                GraphView()
                    .padding()
            }
            .navigationTitle("STATS")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 8")
    }
}
