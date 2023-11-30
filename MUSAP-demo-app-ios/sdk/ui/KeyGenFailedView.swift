//
//  KeyGenFailed.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 27.11.2023.
//

import SwiftUI

struct KeyGenFailedView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Key Generation Failed")
            // Add more UI components as per your layout
            // ...

            Button("Close") {
                isPresented = false
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
