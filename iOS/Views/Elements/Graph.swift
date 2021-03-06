//
//  Graph.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-20.
//

import SwiftUI

struct GraphValue: Hashable {
    let value: Double
    let label: String
    let axisLabel: String
    var color: Color?
}

struct GraphBar: View {
    let item: GraphValue
    let maxValue: Double
    var color = Color.tealCompat
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    if item.value > 0 {
                        Text(item.label)
                          .font(.footnote)
                          .lineLimit(1)
                          .allowsTightening(true)
                          .minimumScaleFactor(0.75)
                          .rotationEffect(.degrees(-90))
                          .offset(y: item.value > 4 ? 35 : 0)
                          .zIndex(1)
                          .when(item.value > 4) { view in
                              view.colorInvert()
                          }

                        Rectangle()
                            .fill(item.color ?? color)
                            .cornerRadius(5)
                            .frame(height: item.value * (geo.size.height / (maxValue + 1)))
                    }
                }
            }
            
            Spacer()

            Text(item.axisLabel)
                .font(.caption)
        }
        .padding(.horizontal, 2)
    }
}

struct Graph: View {
    let items: [GraphValue]
    let maxValue: Double
    var color: Color = Color.tealCompat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                GraphBar(item: item, maxValue: maxValue, color: color)
            }
        }.frame(maxHeight: 200)
    }
}

struct Graph_Previews: PreviewProvider {
    static var previews: some View {
        Graph(items: [
            GraphValue(value: 10, label: "10h", axisLabel: "D"),
            GraphValue(value: 21, label: "21h", axisLabel: "L"),
            GraphValue(value: 4, label: "4h", axisLabel: "M"),
            GraphValue(value: 16, label: "16h", axisLabel: "M"),
            GraphValue(value: 8, label: "8h", axisLabel: "J"),
            GraphValue(value: 12, label: "12h", axisLabel: "V"),
        ], maxValue: 24, color: Color.tealCompat)
    }
}
