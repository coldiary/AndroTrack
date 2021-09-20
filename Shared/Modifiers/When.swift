//
//  when.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-19.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func when<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
