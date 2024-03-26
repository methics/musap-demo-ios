//
//  KeystoreListView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI
import musap_ios

struct KeystoreListView: View {
    @State private var isPopupVisible = false
    @State private var selectedSscd: String? = ""
    
    var enabledSSCDs = ["Yubikey", "Methics Demo"]
    var activatedSSCDs = ["Yubikey"]
    
    @State private var enabledSscdList: [MusapSscd] = [MusapSscd]()
    @State private var activatedSscdList: [MusapSscd] = [MusapSscd]()
    
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("ENABLED SSCDS")).font(.system(size: 12, weight: .bold))) {
                ForEach(enabledSscdList) { sscd in
                     NavigationLink(
                         destination: KeystoreDetailView(targetSscd: sscd),
                         tag: sscd.getSscdInfo()?.getSscdType() ?? "No sscd type",
                         selection: $selectedSscd,
                         label: {
                             Text(sscd.getSscdInfo()?.getSscdName() ?? "No name")
                         }
                     )
                 }
            }
            
            Section(header: Text(LocalizedStringKey("ACTIVE_SSCD_LIST")).font(.system(size: 12, weight: .bold)).padding(.top, 25)) {
                if activatedSscdList.isEmpty  {
                    Text("No SSCD's activated.")
                } else {
                    ForEach(activatedSscdList) { sscd in
                        NavigationLink(
                            destination: KeystoreDetailView(targetSscd: sscd),
                            tag: sscd.getSscdInfo()?.getSscdName() ?? "no name",
                            selection: $selectedSscd,
                            label: {
                                Text(sscd.getSscdInfo()?.getSscdName() ?? "no name")
                            }
                        )
                    }
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
            print("Keys for enabled SSCD: \(sscd.listKeys())")
            guard let sscdName = sscd.getSscdInfo()?.getSscdName() else {
                print("No name for sscd ")
                continue
            }
            print("SSCD name: \(sscdName)")
            print("SSCD ID FROM SSCD: \(sscd.getSscdId() ?? "NO SSCD ID" ) ")
            
            enabledSscdList.append(sscd)
            
            
        }
        
        
    }
    
    private func getKeys() {
        
    }
    
    private func getActivatedSscds() {
        let activatedSscds = MusapClient.listActiveSscds()
        for sscd in activatedSscds {
            print("SSCD things: \(sscd.getSscdId() ?? "No SSCD ID")")
            print("Keys amount: \(sscd.listKeys().count)")
            guard let sscdName = sscd.getSscdInfo()?.getSscdName() else {
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
