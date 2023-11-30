//
//  SwiftUIView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 27.11.2023.
//

import SwiftUI

struct PinEntryView: View {
    @Binding var isPresented: Bool
    @State private var pin: String = ""
    var onPinSubmit: ((String) -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Please enter your PIN")
            SecureField("Enter PIN", text: $pin)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()

                Button("OK") {
                    print("PIN = \(pin)")
                    onPinSubmit?(pin)
                    isPresented = false
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct ContentView: View {
    @State private var showingPinEntry = false

    var body: some View {
        Button("Show PIN Entry") {
            showingPinEntry = true
        }
        .sheet(isPresented: $showingPinEntry) {
            PinEntryView(isPresented: $showingPinEntry)
        }
    }
}
