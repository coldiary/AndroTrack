//
//  HistoryListView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-11-15.
//

import SwiftUI

@available(iOS 15.0, *)
struct HistoryListView: View {
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
                List(records.sorted { $0 > $1 }) { record in
                        RecordView(record: record,
                                   ringColor: settingsStore.themeColor,
                                   sessionLength: settingsStore.sessionLength,
                                   showDate: false
                        ).padding(.vertical)
                        .swipeActions(content: {
                            Button(role: .destructive, action: {
                                editedRecord = record
                                showConfirmModal = true
                            }) {
                                Image(systemName: "trash")
                            }

                            Button(action: {
                                editedRecord = record
                                showEditModal = true
                            }) {
                                Image(systemName: "square.and.pencil")
                            }
                        })
                        .confirmationDialog(
                            "CONFIRM_DELETE",
                             isPresented: $showConfirmModal,
                            titleVisibility: .visible
                        ) {
                            Button("YES", role: .destructive) {
                                withAnimation {
                                    recordStore.deleteRecord(with: editedRecord!.id)
                                }
                            }

                            Button("CANCEL", role: .cancel) {
                                editedRecord = nil
                            }
                        }
                }
                .padding(.top)
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

@available(iOS 15.0, *)
struct HistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListView(date: Date())
            .environmentObject(RecordStore.shared)
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
