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
            
            NavigationLink(destination: YubiKeyView()) {
                Text("GO TO YUBIKEY")
                    .background(Color.gray)
            }
            Button("RESET APP", action: self.deleteAllItems)
            Button("EXPORT DATA", action: self.exportData)
            Text("Version: \(self.getAppVersion())")
                .font(.system(size: 12, weight: .heavy))
            }
        .padding(.top, 50)
        .padding()
        .onAppear {
            self.checkKeys()
            self.printAllKeysInfo()
            self.enableSscds()
        }
    }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App Version: \(appVersion)")
            return appVersion
        }
        
        return "1.0.0"
        
    }
    
    func checkKeys() {
        let keyAlias = "Teemukey"
        let tag = keyAlias.data(using: .utf8)!
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        print("The status:")
        print( status == errSecSuccess)
    }
    
    func deleteAllItems() {
        let classes = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for secClass in classes {
            let query: [String: Any] = [kSecClass as String: secClass]
            let status = SecItemDelete(query as CFDictionary)
            
            if status == errSecSuccess || status == errSecItemNotFound {
                // errSecItemNotFound is also a "success" in this context, as the goal is to ensure no items of this class remain.
                print("Items were successfully deleted or not found for class \(secClass).")
            } else {
                print("Error deleting items for class \(secClass): \(status)")
            }
        }
        
        self.resetUserDefaults()
    }
    
    func resetUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            print("deleting items from user defaults")
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        } else {
            print("bad bundleid")
        }
    }
    
    func printAllKeysInfo() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnRef as String: kCFBooleanTrue
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let items = result as? [[String: Any]] {
                for (index, item) in items.enumerated() {
                    print("Key \(index):", item)
                }
            }
        } else if status == errSecItemNotFound {
            print("No keys were found in the keychain.")
        } else {
            print("Error retrieving keys from the keychain: \(status)")
        }
        
        print("Usedefaults:")
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
        }
    }
    
    func enableSscds() {
        MusapClient.enableSscd(sscd: SecureEnclaveSscd())
        MusapClient.enableSscd(sscd: KeychainSscd())
    }
    
    func exportData() {
        
        if let exportData = MusapClient.exportData() {
            print("exported data:" + exportData)
            printAllKeysInfo()
            deleteAllItems()
            printAllKeysInfo()
            
            do {
                try MusapClient.importData(data: exportData)
            } catch {
                print("error importing musap data")
            }
            
        } else {
            print("Could not export data")
        }

 
    }
}

#Preview {
    HomeView()
}
