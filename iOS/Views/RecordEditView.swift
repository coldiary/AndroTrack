//
//  RecordEditView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-19.
//

import SwiftUI

struct RecordEditView: View {
    private let at: Date?
    @State private var start: Date
    @State private var end: Date
    
    var record: Record {
        return Record(id: UUID(), start: start, end: end)
    }
    
    let unfinished: Bool
    
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var recordStore: RecordStore
    @Environment(\.presentationMode) var presentationMode
    
    init(record: Record?) {
        unfinished = record != nil && record?.end == nil
        at = record?.start ?? nil
        if let start = record?.start {
            _start = State(initialValue: start)
            if let end = record?.end {
                _end = State(initialValue: end)
            } else {
                _end = State(initialValue: start)
            }
        } else {
            _start = State(initialValue: Date())
            _end = State(initialValue: Date())
        }
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
                    .onChange(of: start, perform: { newValue in
                        if (unfinished) {
                            end = newValue
                        }
                    })
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
                TimeRingView(progress: record.durationAsProgress(goal: Double(settingsStore.sessionLength)), ringWidth: 10, color: settingsStore.themeColor)
                    .frame(width: 150, height: 150, alignment: .center)
                Text((record.durationInHours != nil ? "\(Int(record.durationInHours!)) h" : "-"))
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
            }
            Spacer()
            Button(action: {
                if let at = at {
                    recordStore.editRecord(at: at, newValues: record)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("SAVE")
            }
            .disabled(at == nil)
            .padding()
            .frame(maxWidth: .infinity)
            .background(settingsStore.themeColor)
            .foregroundColor(settingsStore.themeColor == Color.white ? Color.black : Color.white)
            .cornerRadius(50)
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
