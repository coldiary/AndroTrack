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

}
