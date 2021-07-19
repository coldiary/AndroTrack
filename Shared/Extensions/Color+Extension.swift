//
//  Color.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import Foundation
import SwiftUI

import DynamicColor

extension Color {
    static let teal: Color = Color(hexString: "#008080")
}

extension Color {
    public func darker(by amount: CGFloat = 0.25) -> Color {
        return Color(DynamicColor(self).darkened(amount: amount))
    }
    
    public func lighter(by amount: CGFloat = 0.25) -> Color {
        return Color(DynamicColor(self).lighter(amount: amount))
    }
}

extension Color {
    public static func gradient(colors: [Color], from start: UnitPoint = .top, to end: UnitPoint = .bottom) -> LinearGradient {
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
    }
}


extension Color {
    public func toHexString() -> String {
        return DynamicColor(self).toHexString()
    }
}
