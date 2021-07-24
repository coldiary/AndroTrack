//
//  RequirementView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-07-22.
//

import SwiftUI
import HealthKit

struct RequirementView: View {
    @State var hasSeenHealthKitAuthorization = false
    @State var hasHealthKitAuthorization = {
        HealthKitService.shared.healthKitAuthorizationStatus == .sharingAuthorized
    }()
    
    var body: some View {
        if hasHealthKitAuthorization {
            ContentView()
        } else {
            if hasSeenHealthKitAuthorization {
                RequestPermission(
                    title: "HEALTHKIT_ACCESS.TITLE",
                    description: "HEALTHKIT_ACCESS.DESCRIPTION_2",
                    illustrationName: "HealthKitPermission",
                    actionLabel: "HEALTHKIT_ACCESS.CTA"
                ) { completion in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        completion()
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl) { _ in
                            completion()
                        }
                    }
                }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    hasHealthKitAuthorization = HealthKitService.shared.healthKitAuthorizationStatus == .sharingAuthorized
                }
            } else {
                RequestPermission(
                    title: "HEALTHKIT_ACCESS.TITLE",
                    description: "HEALTHKIT_ACCESS.DESCRIPTION_2",
                    illustrationName: "HealthKitPermission"
                ) { completion in
                    HealthKitService.shared.requestAccess { success, error in
                        if let error = error {
                            AppLogger.error(context: "ContentView", error.errorDescription!)
                        } else {
                            HealthKitService.shared.checkAuthorizationRequestStatus() { status, error in
                                if let error = error {
                                    AppLogger.error(context: "ContentView", error.errorDescription!)
                                } else {
                                    if status == .unnecessary {
                                        hasSeenHealthKitAuthorization = true
                                    }
                                }
                            }
                        }
                        completion()
                    }
                }.onAppear() {
                    HealthKitService.shared.checkAuthorizationRequestStatus() { status, error in
                        if let error = error {
                            AppLogger.error(context: "ContentView", error.errorDescription!)
                        } else {
                            if status == .unnecessary {
                                 hasSeenHealthKitAuthorization = true
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        RequirementView()
            .preferredColorScheme(.dark)
            .environmentObject(SettingsStore.shared)
    }
}
