//
//  ContentView.swift
//  WatchAndroTrack Extension
//
//  Created by Benoit Sida on 2021-07-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TodayView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("Apple Watch Series 5 - 44mm")
    }
}
