//
//  ThemeSelectorView.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-07-16.
//

import SwiftUI

struct ThemeSelectorView: View {
    @Binding var selected: Color
    
    let colors = [
        Color.teal,
        Color.blue,
        Color.purple,
        Color.red,
        Color.pink,
        Color.orange,
        Color.yellow,
        Color.green,
        Color.gray,
        Color.white
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
            ForEach(colors, id: \.self){ color in
                ZStack {
                    Circle()
                        .fill(Color.gradient(colors: [color.darker(by: 0.1), color]))
                        .frame(width: 50, height: 50)
                        .onTapGesture(perform: {
                            selected = color
                        })
                        .padding(10)

                    if selected.toHexString() == color.toHexString() {
                        Circle()
                            .stroke(Color.gradient(colors: [color.darker(by: 0.1), color]), lineWidth: 5)
                            .frame(width: 60, height: 60)
                    }
                }
            }
        }
    }
}

struct ThemeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectorView(selected: .constant(Color.accentColor))
            .preferredColorScheme(.dark)
    }
}
