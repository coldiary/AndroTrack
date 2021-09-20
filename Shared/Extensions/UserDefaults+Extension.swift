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

extension UserDefaults {
    func nonNulInteger(forKey key: String ) -> Int? {
        let intValue = integer(forKey: key)
        return intValue == 0 ? nil : intValue
    }
}

extension UserDefaults {
    func trySet<T>(_ object: T, forKey key: String) throws where T: Encodable {
        let encoded = try JSONEncoder().encode(object)
        set(encoded, forKey: key)
    }
    
    func typed<T>(forKey key: String) -> T? where T: Decodable {
        if let encoded = data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: encoded)
        } else {
            return nil
        }
    }
}
