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
                        Text($sscdName.wrappedValue)
                    }

                    HStack {
                        Text("SSCD Type")
                        Spacer()
                        Text($sscdType.wrappedValue)
                    }
                    
                    HStack {
                        Text("SSCD Provider")
                        Spacer()
                        Text($sscdProvider.wrappedValue)
                        
                    }
                    
                    HStack {
                        Text("Country")
                        Spacer()
                        Text($country.wrappedValue)
                    }
                    
                    HStack {
                        Text("Algorithms")
                        Spacer()
                        Text($algorithms.wrappedValue)
                    }
                }
            }
            .navigationTitle("Keystore Details")

        }
    }
    
}

#Preview {
    KeystoreDetailView()
}
