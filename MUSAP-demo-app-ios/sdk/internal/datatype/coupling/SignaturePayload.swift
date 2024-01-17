//
//  SignaturePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class SignaturePayload: Decodable {
    
    public var data: String
    public var display = "Sign with MUSAP"
    public var format: String? = "RAW"
    public var scheme: String?
    public var hashAlgo: String? = "SHA-256" //TODO: Swiftify?
    public let linkid: String
    public var key: KeyIdentifier? = nil
    public var attributes: [SignatureAttribute]?
    public var genKey: Bool? = false
    
    init(data:  String,
         format: String? = "RAW",
         scheme: String?,
         linkid: String,
         key: KeyIdentifier?,
         attributes: [SignatureAttribute]?,
         genKey: Bool? = false,
         hashAlgo: String? = "SHA-256"
    )
    {
        self.data = data
        self.format = format
        self.scheme = scheme
        self.linkid = linkid
        self.key = key
        self.attributes = attributes
        self.genKey = genKey
        self.hashAlgo = hashAlgo ?? "SHA-256"
    }
    
    public func toSignatureReq(key: MusapKey) -> SignatureReq? {
        guard let format = self.format else {
            return nil
        }
        let signatureFormat = SignatureFormat.fromString(format: format)
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
                                  format: signatureFormat,
                                  displayText: self.display,
                                  attributes: self.attributes ?? [SignatureAttribute]()
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
