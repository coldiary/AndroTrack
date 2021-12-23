//
//  TimeRingView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-13.
//

import SwiftUI

struct TimeRingView: View {
    var progress: Double
    @State var ringWidth: CGFloat = 30
    var color: Color = .accentColor
    
    
    private var backgroundColor: Color { color.opacity(0.25) }
    private var foregroundColor: Color { color.lighter(by: 10) ?? color }
    private let startAngle: Double = -90
    
    private static let ShadowColor: Color = Color.black.opacity(0.2)
    private static let ShadowRadius: CGFloat = 5
    private static let ShadowOffsetMultiplier: CGFloat = ShadowRadius + 2
    
    private var absolutePercentageAngle: Double {
        RingShape.percentToAngle(percent: progress, startAngle: 0)
    }
    private var relativePercentageAngle: Double { absolutePercentageAngle + startAngle }
    
    // Returns the (x, y) location of the offset
    private func getEndCircleLocation(frame: CGSize) -> (CGFloat, CGFloat) {
        // Get angle of the end circle with respect to the start angle
        let angleOfEndInRadians: Double = relativePercentageAngle.toRadians()
        let offsetRadius = min(frame.width, frame.height) / 2
        return (offsetRadius * cos(angleOfEndInRadians).toCGFloat(), offsetRadius * sin(angleOfEndInRadians).toCGFloat())
    }
    
    private func getEndCircleShadowOffset() -> (CGFloat, CGFloat) {
        let angleForOffset = absolutePercentageAngle + (self.startAngle + 90)
        let angleForOffsetInRadians = angleForOffset.toRadians()
        let relativeXOffset = cos(angleForOffsetInRadians)
        let relativeYOffset = sin(angleForOffsetInRadians)
        let xOffset = relativeXOffset.toCGFloat() * TimeRingView.ShadowOffsetMultiplier
        let yOffset = relativeYOffset.toCGFloat() * TimeRingView.ShadowOffsetMultiplier
        return (xOffset, yOffset)
    }
    
    // Compute the gradient
    private var ringGradient: AngularGradient {
        let gradientStartAngle = progress >= 100 ? relativePercentageAngle - 360 : startAngle
        return AngularGradient(
            gradient: Gradient(colors: [
                color.darker(by: 10) ?? color,
                color.lighter(by: 10) ?? color
            ]),
            center: .center,
            startAngle: Angle(degrees: gradientStartAngle),
            endAngle: Angle(degrees: relativePercentageAngle)
        )
    }
    
    private func showShadow(frame: CGSize) -> Bool {
        let circleRadius = min(frame.width, frame.height) / 2
        let remainingAngleInRadians = (360 - absolutePercentageAngle).toRadians().toCGFloat()
        return (self.progress >= 100 || circleRadius * remainingAngleInRadians <= ringWidth)
    }
    
    var body: some View {
        // 1. Wrap view in a GeometryReader so that the view has access to its parent size
        GeometryReader { geometry in
            ZStack {
                // 2. Background for the ring
                RingShape()
                    .stroke(style: StrokeStyle(lineWidth: ringWidth))
                    .fill(backgroundColor)
                // 3. Foreground
                RingShape(percent: progress, startAngle: startAngle)
                    .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                    .fill(ringGradient)
                    .animation(.spring(response: 0.6, dampingFraction: 1.0, blendDuration: 1.0), value: progress)
                if showShadow(frame: geometry.size) {
                    Circle()
                        .fill(foregroundColor)
                        .frame(width: ringWidth, height: ringWidth, alignment: .center)
                        .offset(x: getEndCircleLocation(frame: geometry.size).0,
                                y: getEndCircleLocation(frame: geometry.size).1)
                        .shadow(color: TimeRingView.ShadowColor,
                                radius: TimeRingView.ShadowRadius,
                                x: getEndCircleShadowOffset().0,
                                y: getEndCircleShadowOffset().1)
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .onAppear() {
                ringWidth = geometry.size.width < 50 ? 3 : geometry.size.width < 150 ? 10 : 30
            }
        }
        .padding(ringWidth / 2)
    }
}

struct TimeRingView_Previews: PreviewProvider {
    static var previews: some View {
        TimeRingView(progress: 72, color: .accentColor)
            .frame(width: 100, height: 100)
            .preferredColorScheme(.dark)
    }
}
