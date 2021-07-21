//
//  GenericModal.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-20.
//

import SwiftUI

struct GenericModal<Content: View>: View {
    let content: () -> Content
    let showDismissButton = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack() {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                }.buttonStyle(PlainButtonStyle())
            }
            .padding()
            VStack {
               content()
            }
            Spacer()
        }
    }
}

struct NotificationPermissionModal_Previews: PreviewProvider {
    static var previews: some View {
        GenericModal() {
            Text("ok")
        }
            .preferredColorScheme(.dark)
            .sheet(isPresented: .constant(true)) {
                GenericModal() {
                    Text("ok")
                }
                    .preferredColorScheme(.dark)
            }
    }
}
