//
//  DataCell.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-22.
//

import SwiftUI

struct DataCell: View {
    let label: String
    let value: String
    var color: Color = Color.tealCompat
    var labelSize: CGFloat = 12
    var valueSize: CGFloat = 48
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: labelSize))
            Spacer()
            Text(value)
                .foregroundColor(color)
                .font(.system(size: valueSize))
        }.frame(maxWidth: .infinity)
    }
}

struct DataCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                DataCell(
                    label: "Test",
                    value: "15"
                )
                .frame(width: 200, height: 80)
                .padding()
                .background(Color.white.darker(by: 90))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }
}
