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
    @State private var isKeyGenerationSuccess = false
    
    @State private var isErrorPopupVisible = false
    @State private var errorMessage = ""
    
    @State private var pin1 = ""
    
    let availableKeystores = ["Methics demo", "Yubikey", "iOS keychain"]
    var keystoreIndex: KeyValuePairs = [0: "Methics demo", 1: "Yubikey", 2: "iOS keychain"]

    
    var body: some View {
        
        Form {
            Section("Key details") {
                HStack {
                    Text("Key name")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("Enter key name", text: $keyName)
                        .foregroundColor(.blue)
                        .autocorrectionDisabled()
                        
                        
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
            
            //TODO: Display only if required
            if (selectedKeystoreIndex == 0 || selectedKeystoreIndex == 1) {
                Section("PIN code") {
                    HStack {
                        Text("Enter PIN")
                            .font(.system(size: 16, weight: .semibold))
                        SecureField("Enter PIN", text: $pin1)
                            .keyboardType(.numberPad)
                    }

                }
            }

            
            Section {
                Button("Generate the key", action: self.generatedButtonTapped)
                    .frame(alignment: .center)
                
                Button("Reset form", role: .destructive, action: self.reset)
                    //.foregroundColor(.red)

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
        .alert(isPresented: $isKeyGenerationSuccess) {
            Alert(title: Text("Success!"),
                  message: Text("Successfully created a key"),
                  dismissButton: .default(Text("OK"), action: {
                self.isKeyGenerationSuccess = false
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
        
        self.isKeyGenerationSuccess = true
        
    }
    
    func reset() {
        self.keyName = ""
        self.selectedKeystoreIndex = 0
        self.pin1 = ""
    }
    
    //TODO: Do we have some requirements for this?
    func isKeyNameOk() -> Bool {
        return self.keyName.count >= 3
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

