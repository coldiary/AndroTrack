//
//  NotificationPermission.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-20.
//

import SwiftUI
//import SwiftSVG


struct NotificationPermission: View {
    let requestPermissionAction: () -> Void
    @EnvironmentObject var settingsStore: SettingsStore
    
    var body: some View {
        VStack {
            Text("Enable Notifications")
                .font(.largeTitle)
            
            Spacer()
            
            Image("NotificationPermission")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(50)
                .padding(.bottom)
            
            Text("In order for the app to send you reminders, you need to grant permission to send notifications.")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                requestPermissionAction()
            }) {
                Text("Grant permission")
            }
            .padding()
            .foregroundColor(.white)
            .background(settingsStore.themeColor)
            .cornerRadius(50)
            .padding(.bottom)
        }.padding(.horizontal)
    }
}

struct NotificationPermission_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermission() {
            
        }
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
