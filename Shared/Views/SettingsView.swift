//
//  SettingsView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-14.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 1, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack() {
                    Text("Session length")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Picker("Session Length", selection: $settingsStore.sessionLength) {
                        ForEach(Range(1...24)) { length in
                            Text("\(length - 1)").tag(length)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 80, height: 100)
                    .clipped()
                }
                .padding()
                VStack(alignment: .leading) {
                    Text("Theme color")
                        .font(.title2)
                        .bold()
                    ThemeSelectorView(selected: $settingsStore.themeColor)
                }.padding()
            }.navigationTitle("Settings")
        }

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
