//
//  LinkAccountPayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class LinkAccountPayload: Codable {
    
    public let couplingCode: String
    public let musapId:      String
    
    init(couplingCode: String, musapId: String) {
        self.couplingCode = couplingCode
        self.musapId = musapId
    }
    
    public func getBase64Encoded() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return jsonData.base64EncodedString()
    }
    
    
}
