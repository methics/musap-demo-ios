//
//  KeyURI.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 6.11.2023.
//

import Foundation

public class KeyURI {
    
    public static let NAME    = "name"
    public static let LOA     = "loa"
    public static let COUNTRY = "country"
    public static let SSCD    = "sscd"
    
    private var keyUriMap: [String: String] = [:]
    
    
    init(name: String?, sscd: String?, loa: String?) {
        if name != nil { self.keyUriMap["name"] = name }
        if sscd != nil { self.keyUriMap["sscd"] = sscd }
        if loa  != nil { self.keyUriMap["loa"]  = loa  }
    }
    
    init(keyUri: String) {
        self.keyUriMap = self.parseUri(keyUri)
    }
    
    private func parseUri(_ keyUri: String) -> [String: String] {
        var keyUriMap = [String: String]()
        print("Parsing KeyURI: \(keyUri)")

        guard let commaIndex = keyUri.firstIndex(of: ",") else {
            return keyUriMap
        }

        let parts = keyUri.replacingOccurrences(of: "mss:", with: "").components(separatedBy: ",")

        for attribute in parts {
            if attribute.contains("=") {
                let split = attribute.components(separatedBy: "=")
                guard split.count >= 2 else { continue }

                let key = split[0]
                let value = split[1]
                print("Parsed \(key)=\(value)")
                keyUriMap[key] = value
            } else {
                print("Ignoring invalid attribute \(attribute)")
            }
        }
        print("parsed KeyURI to: \(keyUriMap)")
    
        return keyUriMap
    }
    
}
