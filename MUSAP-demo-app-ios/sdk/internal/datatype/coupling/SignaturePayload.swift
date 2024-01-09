//
//  SignaturePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class SignaturePayload {
    
    public var data: String
    public let display = "Sign with MUSAP"
    public let format: String
    public let scheme: String?
    public let hashAlgo = "SHA-256" //TODO: Swiftify?
    public let linkId: String
    public let key: KeyIdentifier
    public let attributes: [String: String]
    public let genKey: Bool
    
    init(data: String, format: String, scheme: String?, linkId: String, key: KeyIdentifier, attributes: [String : String], genKey: Bool) {
        self.data = data
        self.format = format
        self.scheme = scheme
        self.linkId = linkId
        self.key = key
        self.attributes = attributes
        self.genKey = genKey
    }
    
    public func toSignatureReq(key: MusapKey) -> SignatureReq {
        let format = SignatureFormat.init(self.format)
        let keyAlgo = key.getAlgorithm()
        var signAlgo: SignatureAlgorithm
        if (self.scheme == nil) {
            signAlgo = keyAlgo.toSignatureAlgorithm(self.hashAlgo) //TODO: DO THIS FUNC
        } else {
            signAlgo = SignatureAlgorithm(algorithm: .ecdsaSignatureMessageX962SHA384)
        }
        
    }
    
    public class KeyIdentifier {
        public let keyId: String
        public let keyAlias: String
        public let publicKeyHash: String
        
        init(keyId: String, keyAlias: String, publicKeyHash: String) {
            self.keyId = keyId
            self.keyAlias = keyAlias
            self.publicKeyHash = publicKeyHash
        }
    }
    
    
    
}
