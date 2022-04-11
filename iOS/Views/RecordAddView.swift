//
//  RecordEditView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-19.
//

import SwiftUI

struct RecordAddView: View {
    public let at: Date
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    
    var record: Record {
        return Record(id: UUID(), start: start, end: end)
    }
    
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var recordStore: RecordStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("ADD_RECORD")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 30) {
                Text("START")
                    .font(.title3)
                    .bold()
                DatePicker("", selection: $start, in: ...Date())
                    .onChange(of: start) { newValue in
                        if newValue > end {
                            end = newValue
                        }
                    }
                    .labelsHidden()
                    .datePickerStyle(DefaultDatePickerStyle())
                    .frame(maxWidth: .infinity)
                    .scaleEffect(1.5)
            }.padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 30) {
                Text("END")
                    .font(.title3)
                    .bold()
                DatePicker("", selection: $end, in: start...Date())
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
            }.padding(.top)
            Spacer()
            Button(action: {
                recordStore.addRecord(newValues: record)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("SAVE")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settingsStore.themeColor)
                    .foregroundColor(settingsStore.themeColor == Color.white ? Color.black : Color.white)
                    .cornerRadius(50)
            }
            .disabled(end == start)
        }
        .onAppear {
            start = at
            end = at
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RecordAddView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
        }.sheet(isPresented: .constant(true)) {
            GenericModal {
                RecordAddView(at: Calendar.current.date(byAdding: .day, value: -4, to: Date())!)
                    .padding()
                    .environmentObject(SettingsStore.shared)
                    .environmentObject(RecordStore.shared)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
