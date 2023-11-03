//
//  EnterPinView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct EnterPinView: View {
        
    @Binding var isPopupVisible: Bool

    @State private var pin1: String = ""
    @State private var pin2: String = ""
    @FocusState private var isPin1FieldActive: Bool

    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("PIN")
                    .font(.headline)
                    .padding()
                    .padding(.bottom, -20)

                TextField("Enter PIN", text: $pin1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .keyboardType(.numberPad)
                    .padding()
                    .focused($isPin1FieldActive)
                    .onAppear {
                        isPin1FieldActive = true
                    }
                
                
                Text("PIN confirm")
                    .font(.headline)
                    .padding()
                    .padding(.bottom, -20)

                
                TextField("Enter PIN", text: $pin2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .keyboardType(.numberPad)
                    .padding()
                
                
                
                HStack {
                    Button("OK", action: self.okButtonTapped)
                        .buttonStyle(.bordered)
                    
                    Button("Cancel", action: self.cancelButtonTapped)
                        .buttonStyle(.plain)
                }
                .padding()

                
                Spacer()
                
                
            }
            .navigationTitle("Select PINs")
        }
    }
    
    private func okButtonTapped() {
        //TODO: Confirm PIN values
        //TODO: Any restrictions on PINs?
        
    }
    
    private func cancelButtonTapped() {
        isPopupVisible = false
    }
    
    
}

