//
//  AndroTrackAppDelegate.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-07-18.
//

import Foundation
import UIKit
import HealthKit

class AndroTrackAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        let healthStore = HKHealthStore()
        healthStore.handleAuthorizationForExtension { (success, error) -> Void in
          
        }
      }
}
