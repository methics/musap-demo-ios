//
//  KeyGenerationView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct KeyGenerationView: View {
    
    @State private var keyName: String = ""
    @State private var selectedKeystores: Set<String> = []
    @State private var selectedKeystoreIndex = 0
    @State private var isPopupVisible = false

    
    let availableKeystores = ["Methics demo", "Yubikey", "iOS keychain"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter key name")
                .font(.system(size: 18, weight: .medium))
                .padding()
                .frame(alignment: .centerFirstTextBaseline)

            TextField("Enter key name", text: $keyName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .padding()
                        
            Text("Choose target keystore")
                .padding(.top, 15)
                .padding()
                .font(.system(size: 18, weight: .medium))

            Picker("Select Keystore", selection: $selectedKeystoreIndex) {
                ForEach(0..<availableKeystores.count) { index in
                    Text(availableKeystores[index]).tag(index)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .padding(.horizontal, 35)
            
            
            Button("GENERATE     ", action: self.generatedButtonTapped)
                .buttonStyle(.borderedProminent)
                .padding(.top, 25)
                .frame(alignment: .center)
            
            
            Spacer()

        }
        .padding(.top, 50)
        .sheet(isPresented: $isPopupVisible, content: {
            EnterPinView(isPopupVisible: $isPopupVisible)
        })
        
        
        


        
    }
    
    func generatedButtonTapped() {
        print("Button was tapped")
        print("selected keystore index: \($selectedKeystoreIndex.wrappedValue)")
        self.isPopupVisible = true
        
        
    }
    
}

#Preview {
    KeyGenerationView()
}
