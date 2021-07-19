//
//  SettingsStore.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-07-16.
//

import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    public static let shared = SettingsStore()
    
    @Published var themeColor: Color {
        didSet {
            UserDefaults.standard.set(themeColor, forKey: "themeColor")
        }
    }
    
    @Published var sessionLength: Int {
        didSet {
            UserDefaults.standard.set(themeColor, forKey: "themeColor")
        }
    }
    
    private init() {
        if (UserDefaults.standard.color(forKey: "themeColor") == nil) {
            UserDefaults.standard.set(Color.teal, forKey: "themeColor")
        }
        
        if (UserDefaults.standard.integer(forKey: "sessionLength") == 0) {
            UserDefaults.standard.set(15, forKey: "sessionLength")
        }
        
        themeColor = UserDefaults.standard.color(forKey: "themeColor")!
        sessionLength = UserDefaults.standard.integer(forKey: "sessionLength")
        print(sessionLength)
    }
}
