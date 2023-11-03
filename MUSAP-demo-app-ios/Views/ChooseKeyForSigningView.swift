//
//  ChooseKeyForSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct ChooseKeyForSigningView: View {
    
    let availableKeys = ["Key 1", "Key 2"]
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            List {
                Section(header: Text("Available Keys").font(.system(size: 18, weight: .bold))) {
                    ForEach(availableKeys, id: \.self) { key in
                        
                        NavigationLink(destination: ConfirmSignView()
                        ) {
                            Text(key)
                        }
                        
                    }
                }
            }

        }

    }
}

#Preview {
    ChooseKeyForSigningView()
}
