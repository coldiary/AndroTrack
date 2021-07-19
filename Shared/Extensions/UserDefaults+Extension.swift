//
//  UserDefaults+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-07-16.
//

import Foundation
import SwiftUI

extension UserDefaults {
    func set(_ color: Color, forKey key: String) {
        set(color.toHexString(), forKey: key)
    }
    
    func color(forKey key: String) -> Color? {
        guard let hex = string(forKey: key) else { return nil }
        return Color(hexString: hex)
    }
    
}
