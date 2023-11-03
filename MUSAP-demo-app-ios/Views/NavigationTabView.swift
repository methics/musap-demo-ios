//
//  NavigationTabView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct NavigationTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .navigationTitle("Home")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationView {
                KeystoreListView()
                    .navigationTitle("Keystore List")
            }
            .tabItem {
                Image(systemName: "list.bullet.clipboard.fill")
                Text("Keystore List")
            }
            
            NavigationView {
                KeyGenerationView()
                    .navigationTitle("Key Generation")
            }
            .tabItem {
                Image(systemName: "key.fill")
                Text("Key Generation")
            }
            
            NavigationView {
                SigningView()
                    .navigationTitle("Signing")
            }
            .tabItem {
                Image(systemName: "signature")
                Text("Sign")
            }
            
        }
    }}

#Preview {
    NavigationTabView()
}
