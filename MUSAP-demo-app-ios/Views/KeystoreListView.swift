//
//  KeystoreListView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct KeystoreListView: View {
    @State private var isPopupVisible = false
    @State private var selectedSscd: String? = ""
    
    let enabledSSCDs = ["Yubikey", "Methics Demo"]
    let activatedSSCDs = ["Yubikey"]
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("ENABLED_SSCDS")).font(.system(size: 12, weight: .bold))) {
                ForEach(enabledSSCDs, id: \.self) { sscd in
                     NavigationLink(
                         destination: KeystoreDetailView(),
                         tag: sscd,
                         selection: $selectedSscd,
                         label: {
                             Text(sscd)
                         }
                     )
                 }
            }
            
            Section(header: Text(LocalizedStringKey("ACTIVE_SSCD_LIST")).font(.system(size: 12, weight: .bold)).padding(.top, 25)) {
                ForEach(activatedSSCDs, id: \.self) { sscd in
                    Text(sscd)
                }
            }
        }
        .sheet(isPresented: $isPopupVisible, content: {
            KeystoreDetailView()
        })
        
        
    }
    
    


    
}

#Preview {
    KeystoreListView()
}
