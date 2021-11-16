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
//    @State private var isEditing = false
//    @State private var selectedDay: Day?
//    @State private var showDayView: Bool = false
//    @State private var showEditModal = false
//    @State private var showConfirmModal = false
//    @State private var editedRecord: Record?
    
    var body: some View {
        NavigationView {
            ScrollView() {
                HistoryCalendarView()
            }.navigationTitle("HISTORY")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
//    var body: some View {
//        NavigationView {

//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        
//    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
