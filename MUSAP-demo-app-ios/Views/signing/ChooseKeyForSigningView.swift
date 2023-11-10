//
//  ChooseKeyForSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct ChooseKeyForSigningView: View {
    
    @State private var musapKeyNames = [String]()
    @State private var musapKeys: [MusapKey] = [MusapKey]()
    var dataToBeSigned: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            List {
                Section(header: Text("Available Keys").font(.system(size: 18, weight: .bold))) {
                    
                    ForEach(musapKeys) { key in
                        
                        NavigationLink(destination: ConfirmSignView(dataToBeSigned: dataToBeSigned!, musapKey: key)
                        ) {
                            Text(key.keyName!)
                        }
                        
                    }
                }
            }

        }
        .onAppear(){
            if self.musapKeyNames.isEmpty {
                getKeyNames()
            }
            
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
            
            let keyName = key.keyName
            
            self.musapKeyNames.append(keyName!)
            musapKeys.append(key)
            
            print("publicKey: " + (key.publicKey?.getPEM())!)
            
            guard let keyUri = key.keyUri else {
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
