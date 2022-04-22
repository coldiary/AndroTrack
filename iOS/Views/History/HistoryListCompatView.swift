//
//  HistoryListView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

struct HistoryListCompatView: View {
    let date: Date
    
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    @State private var isEditing = false
    @State private var showEditModal = false
    @State private var editedRecord: Record?
    @State private var showConfirmModal = false
    
    var records: [Record] {
        recordStore.getDay(forDate: date).records
    }
    
    var body: some View {
        HStack {
            VStack {
                if !records.isEmpty {
                    HStack {
                        Spacer()
                        Button(action: {
                            isEditing = !isEditing
                        }) {
                            Text(isEditing ? "END" : "MODIFY")
                        }
                    }
                }
                ScrollView {
                    VStack {
                        ForEach(records.sorted { $0 > $1}) { record in
                            RecordView(record: record,
                                       ringColor: settingsStore.themeColor,
                                       sessionLength: settingsStore.sessionLength,
                                       showDate: false
                            )
                            .padding()
                            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .cornerRadius(12)
                            .when(isEditing) { view in
                                view.wiggling()
                                    .onTapGesture {
                                        editedRecord = record
                                        showEditModal = true
                                    }
                            }
                        }
                    }
                }.padding()
            }
        }
        .sheet(isPresented: $showEditModal) { [editedRecord] in
            GenericModal() {
                RecordEditView(record: editedRecord!)
                    .environmentObject(self.settingsStore)
                    .padding()
            }
        }
    }
}

struct HistoryListCompatView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListCompatView(date: Date())
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
