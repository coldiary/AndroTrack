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
    
    private func openSettings(completion: (@escaping () -> Void)) -> Void {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            completion()
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { _ in
                completion()
            }
        }
    }
    
    private func requestAuthorization(completion: (@escaping () -> Void)) -> Void {
        HealthKitService.shared.requestAccess { result in
            switch result {
                case .failure(let error):
                    AppLogger.error(context: "ContentView", error.errorDescription!)
                case .success(_):
                    HealthKitService.shared.checkAuthorizationRequestStatus { result in
                        switch result {
                            case .failure(let error):
                                AppLogger.error(context: "ContentView", error.errorDescription!)
                            case .success(let status):
                                if status == .unnecessary {
                                    hasSeenHealthKitAuthorization = true
                                }
                        }
                    }
            }
            completion()
        }
    }
    
    private func updateHKRequestStatus() {
        HealthKitService.shared.checkAuthorizationRequestStatus() { result in
            switch result {
                case .failure(let error):
                    AppLogger.error(context: "ContentView", error.errorDescription!)
                case .success(let status):
                    if status == .unnecessary {
                         hasSeenHealthKitAuthorization = true
                    }
            }
        }
    }
    
    private func updateHKAuthorization() {
        hasHealthKitAuthorization = HealthKitService.shared.healthKitAuthorizationStatus == .sharingAuthorized
    }
    
    var body: some View {
        if hasHealthKitAuthorization {
            ContentView()
        } else {
            if hasSeenHealthKitAuthorization {
                RequestPermission(
                    title: "HEALTHKIT_ACCESS.TITLE".localized,
                    description: "HEALTHKIT_ACCESS.DESCRIPTION_2".localized,
                    illustrationName: "HealthKitPermission",
                    actionLabel: "HEALTHKIT_ACCESS.CTA".localized,
                    requestPermissionAction: openSettings
                )
                .onAppear(perform: updateHKAuthorization)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in updateHKAuthorization() }
            } else {
                RequestPermission(
                    title: "HEALTHKIT_ACCESS.TITLE".localized,
                    description: "HEALTHKIT_ACCESS.DESCRIPTION_2".localized,
                    illustrationName: "HealthKitPermission",
                    requestPermissionAction: requestAuthorization
                ).onAppear(perform: updateHKRequestStatus)
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
