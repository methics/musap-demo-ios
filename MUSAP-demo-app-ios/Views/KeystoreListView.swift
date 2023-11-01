//
//  KeystoreListView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct KeystoreListView: View {
    @State private var isPopupVisible = false
    @State private var selectedSscd = ""
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("ENABLED_SSCDS")).font(.system(size: 18, weight: .bold))) {
                ForEach(enabledSSCDs, id: \.self) { sscd in
                    Text(sscd)
                        .onTapGesture {
                            //TODO: How do we decide the SSCD? Probably not with just by name
                            self.selectedSscd = sscd
                            self.isPopupVisible.toggle()
                        }
                }
            }
            
            Section(header: Text(LocalizedStringKey("ACTIVE_SSCD_LIST")).font(.system(size: 18, weight: .bold)).padding(.top, 25)) {
                ForEach(activatedSSCDs, id: \.self) { sscd in
                    Text(sscd)
                }
            }
        }
        .sheet(isPresented: $isPopupVisible, content: {
            KeystoreDetailView()
        })
        
    }
    
    
    let enabledSSCDs = ["Yubikey", "Methics Demo"]
    let activatedSSCDs = ["Yubikey"]

    
}

#Preview {
    KeystoreListView()
}
