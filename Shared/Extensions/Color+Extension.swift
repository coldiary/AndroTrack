//
//  Color.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation
import SwiftUI

extension Color {
    static let tealCompat: Color = Color(red: 49 / 255, green: 163 / 255, blue: 159 / 255)
}

extension Color {
    public func lighter(by percentage: CGFloat = 25) -> Color? {
        let absolutePercentage: CGFloat = abs(percentage)
        return self.adjust(by: absolutePercentage )
    }
    
    public func darker(by percentage: CGFloat = 25) -> Color? {
        let absolutePercentage: CGFloat = abs(percentage)
        let negativePercentage: CGFloat = -1 * absolutePercentage
        return self.adjust(by: negativePercentage)
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> Color? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha))
        } else {
            return nil
        }
    }
}

extension Color {
    public static func gradient(colors: [Color], from start: UnitPoint = .top, to end: UnitPoint = .bottom) -> LinearGradient {
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
    }
}


extension Color {
    init?(hexString: String) {
        let hexTrimmed: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let hexSanitized: String = hexTrimmed.replacingOccurrences(of: "#", with: "")
        
        guard hexSanitized.count == 6 || hexSanitized.count == 8 else {
            return nil
        }
        
        guard let rgb: UInt64 = hexSanitized.hexToUInt64() else {
            return nil
        }
        
        var components: UInt64.RGBAComponents
        
        if hexSanitized.count == 8 {
            components = rgb.toRGBA()
        } else {
            components = rgb.toRGB()
        }
        
        self.init(red: components.red, green: components.green, blue: components.blue, opacity: components.opacity)
    }
    
    public func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
                
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
                
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
                
        return String(NSString(format:"#%06x", rgb))
    }
}
