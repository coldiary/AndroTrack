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
    @State private var showConfirmModal = false
    @State private var editedRecord: Record?
    
    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                List(recordStore.records.sorted { $0 > $1}) { record in
                    
                        RecordView(record: record,
                                   ringColor: settingsStore.themeColor,
                                   sessionLength: settingsStore.sessionLength
                        ).padding()
                        .swipeActions(content: {
                            Button(role: .destructive, action: {
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
                                    recordStore.deleteRecord(at: record.start!)
                                }
                            }
                            
                            Button("CANCEL", role: .cancel) {}
                        }
                }
                .padding(.top)
                .navigationTitle("HISTORY")
            } else {
                ScrollView {
                    VStack {
                        ForEach(recordStore.records.sorted { $0 > $1}) { record in
                            RecordView(record: record,
                                       ringColor: settingsStore.themeColor,
                                       sessionLength: settingsStore.sessionLength
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isEditing = !isEditing
                        }) {
                            Text(isEditing ? "END" : "MODIFY")
                        }
                    }
                }
                .navigationTitle("HISTORY")
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showEditModal) { [editedRecord] in
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
