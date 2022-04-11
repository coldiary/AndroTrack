//
//  RequestPermission.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-20.
//

import SwiftUI

struct RequestPermission: View {
    let title: String
    let description: String
    let illustrationName: String
    var actionLabel = "REQUEST_PERMISSION.DEFAULT_CTA".localized
    let requestPermissionAction: (@escaping () -> Void) -> Void
    
    @EnvironmentObject private var settingsStore: SettingsStore
    
    @State private var showLoader = false
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
            
            Spacer()
            
            Image(illustrationName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(50)
                .padding(.bottom)
            
            Text(description)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if showLoader {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(24)
            } else {
                Button(action: {
                    showLoader = true
                    requestPermissionAction() {
                        showLoader = false
                    }
                }) {
                    Text(actionLabel)
                        .padding()
                        .frame(minWidth: 200)
                        .foregroundColor(.white)
                        .background(settingsStore.themeColor)
                        .cornerRadius(50)
                }
                .padding(.bottom)
            }
        }.padding(.horizontal)
    }
}

struct RequestPermission_Previews: PreviewProvider {
    static var previews: some View {
        RequestPermission(
            title: "Some permission",
            description: "Some long description to explain why the permission is needed",
            illustrationName: "HealthKitPermission"
        ) { _ in }
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
