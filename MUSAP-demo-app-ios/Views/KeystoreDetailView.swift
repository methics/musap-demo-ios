//
//  KeystoreDetailView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI
import musap_ios

struct KeystoreDetailView: View {
    @State private var keys: [MusapKey] = [MusapKey]()
    
    let targetSscd: MusapSscd

    var body: some View {
        NavigationView {
            Form {
                Section(
                    header:
                        Text("SSCD Details")
                        .font(.system(size: 12 , weight: .bold))
                )
                {
                    HStack {
                        Text("SSCD Name")
                        Spacer()
                        Text(targetSscd.getSscdInfo()?.getSscdName() ?? "")
                    }

                    HStack {
                        Text("SSCD Type")
                        Spacer()
                        Text(targetSscd.getSscdInfo()?.getSscdType() ?? "")
                    }
                    
                    HStack {
                        Text("SSCD Provider")
                        Spacer()
                        Text(targetSscd.getSscdInfo()?.getSscdType() ?? "")
                        
                    }
                    
                    HStack {
                        Text("Country")
                        Spacer()
                        Text(targetSscd.getSscdInfo()?.getCountry() ?? "")
                    }
                    
                    /*
                    Button("View SSCD Keys") {
                        
                    }
                     */
                    
                    /*
                    HStack {
                        Text("Algorithms")
                        Spacer()
                        
                    }
                     */
                }
            }
            .navigationTitle("Keystore Details")
            .onAppear {
                self.getKeys()
            }
            
            

        }
    }
    
    private func getKeys() {
        let req = KeySearchReq(sscdType: targetSscd.getSscdInfo()?.getSscdType())
        let keys = MusapClient.listKeys(req: req)
        self.keys = keys
        
        print("Key amount: \(keys.count)")
        
    }
    
}
