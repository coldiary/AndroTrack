//
//  Number+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-21.
//

import Foundation

extension UInt64 {
    struct RGBAComponents {
        var red: Double
        var green: Double
        var blue: Double
        var opacity: Double
    }
    
    func toRGB() -> RGBAComponents {
        let red: Double = Double((self & 0xFF0000) >> 16) / 255.0
        let green: Double = Double((self & 0x00FF00) >> 8) / 255.0
        let blue: Double = Double(self & 0x0000FF) / 255.0
        let opacity: Double = 1.0
        
        return RGBAComponents(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    func toRGBA() -> RGBAComponents {
        let red = Double((self & 0xFF000000) >> 24) / 255.0
        let green = Double((self & 0x00FF0000) >> 16) / 255.0
        let blue = Double((self & 0x0000FF00) >> 8) / 255.0
        let opacity = Double(self & 0x000000FF) / 255.0
        
        return RGBAComponents(red: red, green: green, blue: blue, opacity: opacity)
    }
}
