//
//  Wiggling.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-19.
//

import Foundation
import SwiftUI

extension View {
    func wiggling() -> some View {
        modifier(WiggleModifier())
    }
}

struct WiggleModifier: ViewModifier {
    @State private var isWiggling = false
    
    private static func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
    
    private let rotateAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.14,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)
    
    private let bounceAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.18,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? 1.0 : -1.0), anchor: .center)
            .animation(rotateAnimation)
            .offset(x: 0, y: isWiggling ? 2.0 : 0)
            .animation(bounceAnimation)
            .onAppear() { isWiggling.toggle() }
    }
}
