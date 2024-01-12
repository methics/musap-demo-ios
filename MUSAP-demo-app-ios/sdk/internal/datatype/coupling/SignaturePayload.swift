//
//  SignaturePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class SignaturePayload: Decodable {
    
    public var data: String
    public let display = "Sign with MUSAP"
    public let format: String
    public let scheme: String?
    public let hashAlgo = "SHA-256" //TODO: Swiftify?
    public let linkId: String
    public let key: KeyIdentifier
    public let attributes: [SignatureAttribute]
    public let genKey: Bool
    
    init(data: String, format: String, scheme: String?, linkId: String, key: KeyIdentifier, attributes: [SignatureAttribute], genKey: Bool) {
        self.data = data
        self.format = format
        self.scheme = scheme
        self.linkId = linkId
        self.key = key
        self.attributes = attributes
        self.genKey = genKey
    }
    
    
    public func toSignatureReq(key: MusapKey) -> SignatureReq? {
        let format = SignatureFormat.init(self.format)
        let keyAlgo = key.getAlgorithm()
        
        //TODO: This needs work probably
        var signAlgo: SignatureAlgorithm?
        if (self.scheme == nil) {
            signAlgo = keyAlgo?.toSignatureAlgorithm()
        } else {
            if let keyAlgorithm = key.getAlgorithm() {
                if keyAlgorithm.isEc() {
                    signAlgo = SignatureAlgorithm(algorithm: .ecdsaSignatureMessageX962SHA384)
                } else {
                    signAlgo = SignatureAlgorithm(algorithm: .rsaSignatureMessagePKCS1v15SHA256)
                }
            }
        }
        
        guard let dataBase64 = data.data(using: .utf8)?.base64EncodedData() else {
            return nil
        }
        
        let sigReq = SignatureReq(key: key,
                                  data: dataBase64,
                                  algorithm: signAlgo ?? SignatureAlgorithm(algorithm: SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256),
                                  format: format,
                                  displayText: self.display,
                                  attributes: self.attributes
        )
        
        return sigReq
    }
    
    public class KeyIdentifier: Decodable {
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
