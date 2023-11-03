//
//  ContentView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        //Spacer(minLength: 100)
        VStack {
            Text(LocalizedStringKey("WELCOME_TEXT"))
                .font(.system(size: 24, weight: .heavy))
            Spacer()
            Text("Version: \(self.getAppVersion())")
                .font(.system(size: 12, weight: .heavy))
        }
        .padding(.top, 50)
        .padding()
    }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App Version: \(appVersion)")
            return appVersion
        }
        
        return "1.0.0"
        
    }
}

#Preview {
    HomeView()
}
