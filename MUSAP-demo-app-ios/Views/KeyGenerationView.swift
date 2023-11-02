//
//  KeyGenerationView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct KeyGenerationView: View {
    
    @State private var keyName: String = ""
    @State private var selectedKeystoreIndex = 0
    @State private var isPopupVisible = false
    
    @State private var isErrorPopupVisible = false
    @State private var errorMessage = ""
    
    @State private var pin1 = ""
    @State private var pin2 = ""
    
    
    let availableKeystores = ["Methics demo", "Yubikey", "iOS keychain"]
    
    var body: some View {
        
        Form {
            Section("Key details") {
                HStack {
                    Text("Key name")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("Enter key name", text: $keyName)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        
                }
                
                HStack {
                    Picker("Select Keystore", selection: $selectedKeystoreIndex) {
                        ForEach(0..<availableKeystores.count) { index in
                            Text(availableKeystores[index]).tag(index)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            
            Section("PIN codes") {
                HStack {
                    Text("Enter PIN")
                        .font(.system(size: 16, weight: .semibold))
                    SecureField("Enter PIN", text: $pin1)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Confirm PIN")
                        .font(.system(size: 16, weight: .semibold))
                    SecureField("Confirm PIN", text: $pin2)
                        .keyboardType(.numberPad)
                }
            }
            
            Section {
                Button("Generate the key", action: self.generatedButtonTapped)
                    .frame(alignment: .center)
                
                Button("Reset form", action: self.reset)
                    .foregroundColor(.red)

            }
             
        }
        .alert(isPresented: $isErrorPopupVisible) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"), action: {
                    self.isErrorPopupVisible = false
                    self.errorMessage = ""
                })
            )
        }
        
    }
    
    //TODO: This skips to last check. Fix?
    func generatedButtonTapped() {
        //self.isPopupVisible = true
        
        print("Selected keystore: \(availableKeystores[selectedKeystoreIndex])")
        
        if !self.isKeyNameOk() {
            self.errorMessage = "Keyname must have at least 3 characters"
            self.isErrorPopupVisible = true
        }
        
        if !self.isPinLengthOk() {
            self.errorMessage = "PIN needs to be at least 4 digits"
            self.isErrorPopupVisible = true
        }
        
        if !self.arePinsEqual() {
            self.errorMessage = "PINs need to be equal"
            self.isErrorPopupVisible = true
        }
        
    }
    
    func reset() {
        self.keyName = ""
        self.selectedKeystoreIndex = 0
        self.pin1 = ""
        self.pin2 = ""
    }
    
    //TODO: Do we have some requirements for this?
    func isKeyNameOk() -> Bool {
        return self.keyName.count >= 3
    }
    
    func arePinsEqual() -> Bool {
        return self.pin1 == self.pin2
    }
    
    func isPinLengthOk() -> Bool {
        return self.pin1.count >= 4
    }
    
    func displayErrorPopup() {
        self.isErrorPopupVisible = true
    }
    
}

#Preview {
    KeyGenerationView()
}
