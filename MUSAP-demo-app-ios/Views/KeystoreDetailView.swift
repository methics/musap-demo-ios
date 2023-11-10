//
//  KeystoreDetailView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct KeystoreDetailView: View {
    @State private var sscdName = "Yubikey"
    @State private var sscdType = "Yubikey"
    @State private var sscdProvider = "Yubico"
    @State private var country = "FI"
    @State private var algorithms = ""
    
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
                        Text(targetSscd.sscdName ?? "")
                    }

                    HStack {
                        Text("SSCD Type")
                        Spacer()
                        Text(targetSscd.sscdType ?? "")
                    }
                    
                    HStack {
                        Text("SSCD Provider")
                        Spacer()
                        Text(targetSscd.provider ?? "")
                        
                    }
                    
                    HStack {
                        Text("Country")
                        Spacer()
                        Text(targetSscd.country ?? "")
                    }
                    
                    HStack {
                        Text("Algorithms")
                        Spacer()
                        Text("TODO")
                    }
                }
            }
            .navigationTitle("Keystore Details")

        }
    }
    
}

/*
#Preview {
    KeystoreDetailView()
}

*/
