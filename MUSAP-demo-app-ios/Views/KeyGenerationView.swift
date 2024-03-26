//
//  KeyGenerationView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI
import musap_ios

struct KeyGenerationView: View {
    
    @State private var keyAlias: String = ""
    @State private var selectedKeystoreIndex = 0
    @State private var isPopupVisible = false
    @State private var isKeyGenerationSuccess = false
    
    @State private var isErrorPopupVisible = false
    @State private var errorMessage = ""
    
    @State private var pin1 = ""
    @State private var isTextFieldActive = true
    
    @State private var keystoreMappings: [String: MusapSscd] = [:]
    @State private var enabledKeystoresNames: [String] = []
    
    
    var body: some View {
        
        Form {
            Section("Key details") {
                HStack {
                    Text("Key name")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("Enter key name", text: $keyAlias)
                        .foregroundColor(.blue)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Picker("Select Keystore", selection: $selectedKeystoreIndex) {
                        ForEach(0..<enabledKeystoresNames.count, id: \.self) { index in
                            Text(enabledKeystoresNames[index]).tag(index)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .font(.system(size: 16, weight: .semibold))
                    .onAppear {
                        self.loadEnabledKeystores()
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
    
        
        if !self.isKeyNameOk() {
            self.errorMessage = "Keyname must have at least 3 characters"
            self.isErrorPopupVisible = true
            print("ERROR! BAD Key name")
        }            
        
        self.generateKeyWithMusap()

        
    }
    
    private func loadEnabledKeystores() {
        let enabledKeystores = MusapClient.listEnabledSscds() ?? []
        self.enabledKeystoresNames = enabledKeystores.compactMap { $0.getSscdInfo()?.getSscdName() }
        self.keystoreMappings = enabledKeystores.reduce(into: [:]) { dict, sscd in
            if let name = sscd.getSscdInfo()?.getSscdName() {
                dict[name] = sscd
            }
        }
    }

    
    func generateKeyWithMusap() {
        print("GENERATING KEY WITH MUSAP (keygenerationview)")
        let selectedKeystore = enabledKeystoresNames[selectedKeystoreIndex]
        
        
        
        //let secureEnclaveSettings = SecureEnclaveSettings()
        //secureEnclaveSettings.setSscdName(name: "SecureEnclave")

        let selectedKeystoreName = enabledKeystoresNames[selectedKeystoreIndex]
        guard let musapSscd = keystoreMappings[selectedKeystoreName] else {
            print("Selected keystore is not available")
            return
        }
        
        //let keyAlgo            = KeyAlgorithm(primitive: KeyAlgorithm.PRIMITIVE_EC, bits: 256)
        let keyAlgo            = KeyAlgorithm(primitive: KeyAlgorithm.PRIMITIVE_EC, bits: 384)
        
        let keyGenReq          = KeyGenReq(keyAlias: self.keyAlias, role: "personal", keyAlgorithm: keyAlgo)
        
        print("KeyGenerationView: Keyalgo: \(keyAlgo.primitive) \(keyAlgo.bits)")
        print("Keygrenreq: Alias \(keyGenReq.keyAlias)")
        
        Task { [musapSscd] in
            await MusapClient.generateKey(sscd: musapSscd, req: keyGenReq) { result in
                
                switch result {
                case .success(let musapKey):
                    print("Success! Keyname: \(String(describing: musapKey.getKeyAlias()))")
                    print("Musap Key:        \(String(describing: musapKey.getPublicKey()?.getPEM()))")
                    
                    print("isEC? \(String(describing: musapKey.getAlgorithm()?.isEc()))")
                    print("isRSA? \(String(describing: musapKey.getAlgorithm()?.isRsa()))")
                    print("Bits: \(String(describing: musapKey.getAlgorithm()?.bits))")
                    
                    self.isKeyGenerationSuccess = true
                    print("sscd type: \(String(describing: musapKey.getSscdType()))")
                case .failure(let error):
                    print("ERROR: \(error.errorCode)")
                    print(error.localizedDescription)
                    self.errorMessage = "Error creating musap key"
                    self.isErrorPopupVisible = true
                }
            }
            
        }
        
    }
    
    
    func reset() {
        self.keyAlias = ""
        self.selectedKeystoreIndex = 0
        self.pin1 = ""
    }
    
    func isKeyNameOk() -> Bool {
        return self.keyAlias.count >= 3
    }
    
}

#Preview {
    KeyGenerationView()
}

