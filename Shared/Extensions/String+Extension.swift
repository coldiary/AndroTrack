//
//  String+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-19.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localizedWith(comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
    
    func hexToUInt64() -> UInt64? {
        let hexTrimmed: String = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let hexSanitized: String = hexTrimmed.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        return rgb
    }

}
