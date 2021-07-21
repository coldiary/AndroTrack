//
//  Bundle+Extension.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-19.
//

import Foundation

extension Bundle {
    var displayName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
