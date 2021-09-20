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
    @State private var isEditing = false
    @State private var showEditModal = false
    @State private var editedRecord: Record?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(recordStore.records.sorted { $0 > $1}) { record in
                        RecordView(record: record,
                                   ringColor: settingsStore.themeColor,
                                   sessionLength: settingsStore.sessionLength
                        )
                        .when(isEditing) { view in
                            view.wiggling()
                                .onTapGesture {
                                    editedRecord = record
                                    showEditModal = true
                                }
                        }
                    }
                }.padding()
            }
            .navigationTitle("HISTORY")
            .navigationBarItems(trailing: Button(action: {
                isEditing = !isEditing
            }) {
                Text(isEditing ? "CANCEL" : "MODIFY")
            })
        }.sheet(isPresented: $showEditModal) { [editedRecord] in
            GenericModal() {
                RecordEditView(record: editedRecord)
                    .environmentObject(self.settingsStore)
                    .padding()
            }
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
