//
//  ChooseKeyForSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct ChooseKeyForSigningView: View {
    
    @State private var musapKeys: [MusapKey] = [MusapKey]()
    var dataToBeSigned: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            List {
                Section(header: Text("Available Keys").font(.system(size: 18, weight: .bold))) {
                    
                    ForEach(musapKeys) { key in
                        
                        NavigationLink(destination: ConfirmSignView(dataToBeSigned: dataToBeSigned ?? "Sample text to sign", musapKey: key)
                        ) {
                            Text(key.getKeyAlias()!)
                        }
                        
                    }
                }
            }

        }
        .onAppear(){
            musapKeys = [MusapKey]()
            getKeyNames()

            
            guard dataToBeSigned != nil else {
                print("data to be signed is nil")
                return
            }
            
            print("dataToBeSigned: \(String(describing: dataToBeSigned))")
        }

    }
    
    private func getKeyNames() {
        let availableMusapKeys = MusapClient.listKeys()
        for key in availableMusapKeys {
            
            let keyName = key.getKeyAlias()
            musapKeys.append(key)
            
            guard let publicKey = key.getPublicKey() else {
                print("Public key was nil, continue loop")
                continue
            }
            print("publicKey: " + (publicKey.getPEM()))
            
            guard let keyUri = key.getKeyUri() else {
                return
            }
            print("keyUri: \(keyUri.getUri())")
        }
        
        
        print("Get everything from metadatastorage:")
        MetadataStorage().printAllData()
        
    }
    
    
}

/*
 #Preview {
 ChooseKeyForSigningView()
 }
 */
