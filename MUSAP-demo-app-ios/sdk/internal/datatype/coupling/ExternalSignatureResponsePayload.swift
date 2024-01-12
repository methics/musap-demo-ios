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
    let certificate: String
    
    let transId: String
    let attributes: [String: String]
    
    init(signature: String?, publicKey: String, certifiacte: String, transId: String, attributes: [String : String], status: String, errorCode: String?) {
        self.signature = signature
        self.publicKey = publicKey
        self.certificate = certifiacte
        self.transId = transId
        self.attributes = attributes
        super.init(status: status, errorCode: errorCode)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    
    public func isSuccess() -> Bool {
        return self.status.lowercased() == "success"
    }
    
    public func getRawSignature() -> Data? {
        if (self.signature == nil) { return nil }
        return signature?.data(using: .utf8)
    }
    
    public func getPublicKey() -> String {
        return self.publicKey
    }
    
}
