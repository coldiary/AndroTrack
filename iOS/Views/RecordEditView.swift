//
//  RecordEditView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-19.
//

import SwiftUI

struct RecordEditView: View {
    private let id: UUID

    @State private var start: Date
    @State private var end: Date
    
    var record: Record {
        return Record(id: UUID(), start: start, end: end)
    }
    
    let unfinished: Bool
    
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var recordStore: RecordStore
    @Environment(\.presentationMode) var presentationMode
    
    init(record: Record) {
        id = record.id
        unfinished = record.end == Date.distantFuture
        _start = State(initialValue: record.start)
        _end = State(initialValue: unfinished ? record.start : record.end)
    }
    
    var body: some View {
        VStack {
            Text("EDIT_RECORD")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 30) {
                Text("START")
                    .font(.title3)
                    .bold()
                DatePicker("", selection: $start, in: ...Date())
                    .labelsHidden()
                    .datePickerStyle(DefaultDatePickerStyle())
                    .frame(maxWidth: .infinity)
                    .scaleEffect(1.5)
                    .onChange(of: start) { newValue in
                        if (unfinished) {
                            end = newValue
                        }
                    }
            }.padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 30) {
                Text("END")
                    .font(.title3)
                    .bold()
                DatePicker("", selection: $end, in: start...Date())
                    .disabled(unfinished)
                    .labelsHidden()
                    .datePickerStyle(DefaultDatePickerStyle())
                    .frame(maxWidth: .infinity)
                    .scaleEffect(1.5)
            }.padding(.bottom, 20)
            ZStack {
                TimeRingView(progress: record.durationAsProgress(goal: settingsStore.sessionLength), ringWidth: 10, color: settingsStore.themeColor)
                    .frame(width: 150, height: 150, alignment: .center)
                Text("\(Int(record.durationInHours)) h")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
            }.padding(.top)
            Spacer()
            Button(action: {
                recordStore.editRecord(with: id, newValues: record)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("SAVE")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settingsStore.themeColor)
                    .foregroundColor(settingsStore.themeColor == Color.white ? Color.black : Color.white)
                    .cornerRadius(50)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RecordEditView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
        }.sheet(isPresented: .constant(true)) {
            GenericModal {
                RecordEditView(record: Record.today)
                    .padding()
                    .environmentObject(SettingsStore.shared)
                    .environmentObject(RecordStore.shared)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
