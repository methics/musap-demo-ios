//
//  ChooseKeyForSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct ChooseKeyForSigningView: View {
    
    let availableKeys = ["Key 1", "Key 2"]
    @State private var musapKeyNames = [String]()
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            List {
                Section(header: Text("Available Keys").font(.system(size: 18, weight: .bold))) {
                    ForEach(musapKeyNames, id: \.self) { key in
                        
                        NavigationLink(destination: ConfirmSignView()
                        ) {
                            Text(key)
                        }
                        
                    }
                }
            }

        }
        .onAppear(){
            if self.musapKeyNames.isEmpty {
                getKeyNames()
            }
        }

    }
    
    private func getKeyNames() {
        let availableMusapKeys = MusapClient.listKeys()
        for key in availableMusapKeys {
            guard let keyName = key.keyName else {
                continue
            }
            
            self.musapKeyNames.append(keyName)
            
            print("publicKey: " + (key.publicKey?.getPEM())!)
            
        }
        
        
        print("Get everything from metadatastorage:")
        MetadataStorage().printAllData()
        
        let teemuKey = UserDefaults.standard.string(forKey: "Teemukey")
    
        print("teemuKey: \(String(describing: teemuKey))")
        
    }
    
    
}

#Preview {
    ChooseKeyForSigningView()
}
