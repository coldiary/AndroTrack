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
    
    @State private var showExporter = false
    @State private var showConfirmModal = false
    @State private var lastExportResult: Result<URL, Error>? = nil
    @State private var document: CSVFile = CSVFile()
    
    var body: some View {
        NavigationView {
            ScrollView() {
                HistoryCalendarView()
            }
            .alert(isPresented: $showConfirmModal) {
                if lastExportResult == nil {
                    return Alert(
                        title: Text(""),
                        message: Text("CONFIRM_EXPORT"),
                        primaryButton: .cancel(Text("CANCEL"), action: {}),
                        secondaryButton: .default(Text("YES"), action: {
                            document = recordStore.exportAsCSVFile()
                            showExporter = true
                        })
                    )
                } else {
                    switch lastExportResult {
                    case .success(_):
                        return Alert(
                            title: Text(""),
                            message: Text("EXPORT_SUCCESS"),
                            dismissButton: .default(Text("OK"), action: {
                                lastExportResult = nil
                            })
                        )
                    case .failure(let error):
                        return Alert(
                            title: Text(""),
                            message: Text("\("EXPORT_FAILURE".localized)\n\(error.localizedDescription)"),
                            dismissButton: .default(Text("OK"), action: {
                                lastExportResult = nil
                            })
                        )
                    case .none:
                        return Alert(
                            title: Text(""),
                            message: Text("EXPORT_FAILURE"),
                            dismissButton: .default(Text("OK"), action: {
                                lastExportResult = nil
                            })
                        )
                    }
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: document,
                contentType: .plainText,
                defaultFilename: "AndroTrack_export_\(Date().compactDate()).csv"
            ) { result in
                lastExportResult = result
                showConfirmModal = true
                switch result {
                    case .success(_):
                        break
                    case .failure(let err):
                        print(err.localizedDescription)
                }
                
            }
            .navigationTitle("HISTORY")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showConfirmModal = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(settingsStore.themeColor)
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
