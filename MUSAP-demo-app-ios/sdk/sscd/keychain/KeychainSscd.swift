//
//  KeychainSscd.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 6.11.2023.
//

import Foundation
import Security

public class KeychainSscd: MusapSscdProtocol {
    
    typealias CustomSscdSettings = KeychainSettings
    
    static let SSCD_TYPE = "keychain"
    
    private let settings = KeychainSettings()
    
    
    func bindKey(req: KeyBindReq) throws -> MusapKey {
        // Old keys cannot be bound to musap?
        // Use generateKey instead
        fatalError("Unsupported operation")
    }
    
    func generateKey(req: KeyGenReq) throws -> MusapKey {
        let sscd      = self.getSscdInfo()
        let algorithm = self.resolveAlgorithm(req: req)
        let algSpec   = self.resolveAlgorithmParameterSpec(req: req)
        
        
        var keyParams: [String: Any] = [
            kSecAttrKeyType        as String: algorithm,
            kSecAttrKeySizeInBits  as String: 2048,
            kSecAttrIsPermanent    as String: true,
            kSecAttrApplicationTag as String: req.keyAlias.data(using: .utf8)!,
            kSecAttrKeyClass       as String: kSecAttrKeyClassPrivate
        ]
        
        if let algSpec = algSpec {
            keyParams[kSecAttrKeyType as String] = algSpec
        }
        
        // Create the key pair
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(keyParams as CFDictionary, &error) else {
            throw MusapError.internalError
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw MusapError.internalError
        }

        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?,
              let publicKeyBytes = publicKeyData.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in ptr.baseAddress }) 
        else {
            throw MusapError.internalError
        }
        
        let publicKeyObj = PublicKey(publicKey: Data(bytes: publicKeyBytes, count: publicKeyData.count))
        
        let generatedKey = MusapKey(keyname:    req.keyAlias,
                                    sscdId:     sscd.sscdId,
                                    sscdType:   "type",
                                    publicKey:   publicKeyObj,
                                    certificate: MusapCertificate(),
                                    attributes:  req.attributes,
                                    loa:         [MusapLoa.EIDAS_SUBSTANTIAL, MusapLoa.ISO_LOA3],
                                    keyUri:      KeyURI(name: req.keyAlias, sscd: sscd.sscdType, loa: "loa3")
        )
        
        return generatedKey
        
    }
    
    func sign(req: SignatureReq) throws -> MusapSignature {
        return MusapSignature()
    }
    
    func getSscdInfo() -> MusapSscd {
        
        let musapSscd = MusapSscd(
            sscdName:        "iOS Keychain",
            sscdType:        KeychainSscd.SSCD_TYPE,
            sscdId:          "123",//TODO: How is this done?
            country:         "FI",
            provider:        "Apple",
            keyGenSupported: true,
            algorithms:      [KeyAlgorithm.RSA_2K,
                             KeyAlgorithm.ECC_P256_K1,
                             KeyAlgorithm.ECC_P256_R1,
                             KeyAlgorithm.ECC_P384_K1],
            formats:         [SignatureFormat.RAW])
        return musapSscd
    }
    
    func generateSscdId(key: MusapKey) -> String {
        return "keychain"
    }
    
    func isKeygenSupported() -> Bool {
        return self.getSscdInfo().keyGenSupported
    }
    
    func getSettings() -> KeychainSettings {
        return self.settings
    }
    
    func getSettings() -> [String : String]? {
        return self.settings.getSettings()
    }
    
    func resolveAlgorithmParameterSpec(req: KeyGenReq) -> SecKeyAlgorithm? {
        guard let algorithm = req.keyAlgorithm else {
            return nil
        }

        if algorithm.isRsa() {
            return SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256
        } else {
            return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
        }
    }
    
    private func resolveAlgorithm(req: KeyGenReq) -> String {
        if let algorithm = req.keyAlgorithm {
            if algorithm.isRsa() { return KeyAlgorithm.PRIMITIVE_RSA }
            if algorithm.isEc()  { return KeyAlgorithm.PRIMITIVE_EC  }
        }
        return KeyAlgorithm.PRIMITIVE_EC
    }
    
    
}
