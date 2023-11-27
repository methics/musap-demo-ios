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
    
    var enabledSSCDs = ["Yubikey", "Methics Demo"]
    var activatedSSCDs = ["Yubikey"]
    
    @State private var enabledSscdList: [MusapSscd] = [MusapSscd]()
    @State private var activatedSscdList: [MusapSscd] = [MusapSscd]()
    
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("ENABLED_SSCDS")).font(.system(size: 12, weight: .bold))) {
                ForEach(enabledSscdList) { sscd in
                     NavigationLink(
                         destination: KeystoreDetailView(targetSscd: sscd),
                         tag: sscd.sscdName!,
                         selection: $selectedSscd,
                         label: {
                             Text(sscd.sscdName!)
                         }
                     )
                 }
            }
            
            Section(header: Text(LocalizedStringKey("ACTIVE_SSCD_LIST")).font(.system(size: 12, weight: .bold)).padding(.top, 25)) {
                ForEach(activatedSscdList) { sscd in
                    NavigationLink(
                        destination: KeystoreDetailView(targetSscd: sscd),
                        tag: sscd.sscdName!,
                        selection: $selectedSscd,
                        label: {
                            Text(sscd.sscdName!)
                        }
                    )
                }
            }
        }
        .onAppear {
            enabledSscdList = [MusapSscd]()
            activatedSscdList = [MusapSscd]()
            getEnabledSscds()
            getActivatedSscds()
        }

    
    }

    private func getEnabledSscds() {
        guard let enabledSscds = MusapClient.listEnabledSscds() else {
            print("No enabled SSCDs")
            return
        }

        for sscd in enabledSscds {
            guard let sscdName = sscd.getSscdInfo().sscdName else {
                print("No name for sscd ")
                continue
            }
            print("SSCD: \(sscdName)")
            
            enabledSscdList.append(sscd.getSscdInfo())
            
            
        }
        
        
    }
    
    private func getActivatedSscds() {
        let activatedSscds = MusapClient.listActiveSscds()
        for sscd in activatedSscds {
            guard let sscdName = sscd.sscdName else {
                print("No name for sscd")
                continue
            }
            
            print("SSCD: \(sscdName)")
            activatedSscdList.append(sscd)
        }
    }

}

#Preview {
    KeystoreListView()
}
