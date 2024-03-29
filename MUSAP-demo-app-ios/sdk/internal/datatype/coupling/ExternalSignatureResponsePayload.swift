//
//  ExternalSignatureResponsePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class ExternalSignatureResponsePayload: ResponsePayload {
    let signature: String?
    let publicKey: String?
    let certificate: String?
    
    let transid: String
    let attributes: [String: String]?
    
    init(signature: String?, publicKey: String, certificate: String, transid: String, attributes: [String : String], status: String, errorCode: String?) {
        self.signature = signature
        self.publicKey = publicKey
        self.certificate = certificate
        self.transid = transid
        self.attributes = attributes
        super.init(status: status, errorCode: errorCode)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode each property
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
        publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey)
        certificate = try container.decodeIfPresent(String.self, forKey: .certificate)
        transid = try container.decode(String.self, forKey: .transid)
        attributes = try container.decodeIfPresent([String: String].self, forKey: .attributes)
        
        // Call the superclass initializer
        let status = try container.decode(String.self, forKey: .status)
        let errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode)
        super.init(status: status, errorCode: errorCode)    }
    
    public func isSuccess() -> Bool {
        return self.status.lowercased() == "success"
    }
    
    public func getRawSignature() -> Data? {
        if (self.signature == nil) { return nil }
        return signature?.data(using: .utf8)
    }
    
    public func getPublicKey() -> String? {
        return self.publicKey
    }
    
    private enum CodingKeys: String, CodingKey {
        case signature, publicKey = "publickey", certificate, transid = "transid", attributes, status, errorCode = "errorcode"
    }
}
