//
//  MUSAP_demo_app_iosApp.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI
import musap_ios

@main
struct MUSAP_demo_app_ios: App {
    
    init() {
        // Enable SSCDs. For example YubikeySscd
        MusapClient.enableSscd(sscd: YubikeySscd())
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationTabView()
        }
    }
}
