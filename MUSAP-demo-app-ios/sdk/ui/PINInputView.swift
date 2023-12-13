//
//  PINInputView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 12.12.2023.
//

import SwiftUI

struct PINInputView: View {
    @State private var pin: String = ""
    var onPinSubmit: ((String) -> Void)?

    var body: some View {
        VStack {
            SecureField("Enter PIN", text: $pin)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Submit") {
                
                onPinSubmit!(pin)
            }
            .padding()
        }
    }

    private func validatePIN() {
        print("Entered PIN: \(pin)")
    }
}
