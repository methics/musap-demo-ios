//
//  ExternalSignatureResponsePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class ExternalSignatureResponsePayload: ResponsePayload {
    let signature: String?
    let publicKey: String
    let certifiacte: String
    
    let transId: String
    let attributes: [String: String]
    
    init(signature: String?, publicKey: String, certifiacte: String, transId: String, attributes: [String : String]) {
        self.signature = signature
        self.publicKey = publicKey
        self.certifiacte = certifiacte
        self.transId = transId
        self.attributes = attributes
    }
    
    required init(from decoder: Decoder) throws {
        
    }
    
    
    public func isSuccess() -> Bool {
        return self.status.lowercased() == "success"
    }
    
    public func getRawSignature() -> Data? {
        if (self.signature == nil) { return nil }
        return signature?.data(using: .utf8)
    }
    
}
