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
        
        guard req.keyAlgorithm != nil else {
            throw MusapException(MusapError.invalidAlgorithm)
        }
        
        let algo      = req.keyAlgorithm.primitive
        let bits      = req.keyAlgorithm.bits
        let curve     = req.keyAlgorithm.curve
        
        var keyParams: [String: Any] = [
            kSecAttrKeyType        as String: algorithm,
            kSecAttrKeySizeInBits  as String: bits,
            kSecAttrIsPermanent    as String: true,
            kSecAttrApplicationTag as String: req.keyAlias.data(using: .utf8)!,
            kSecAttrKeyClass       as String: kSecAttrKeyClassPrivate,
        ]
        
        if let curve = curve {
            keyParams[kSecAttrKeyTypeECSECPrimeRandom as String] = curve
        }
        
        if let algSpec = algSpec {
            keyParams[kSecAttrKeyType as String] = algSpec
        }
        
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
        let generatedKey = MusapKey(keyname:     req.keyAlias,
                                    sscdId:      sscd.sscdId,
                                    sscdType:    MusapConstants.IOS_KS_TYPE,
                                    publicKey:   publicKeyObj,
                                    certificate: MusapCertificate(),
                                    attributes:  req.attributes,
                                    loa:         [MusapLoa.EIDAS_SUBSTANTIAL, MusapLoa.ISO_LOA3],
                                    keyUri:      KeyURI(name: req.keyAlias, sscd: sscd.sscdType, loa: "loa3")
        )
        
        return generatedKey
        
    }
    
    func sign(req: SignatureReq) throws -> MusapSignature {
        guard let alias = req.key.keyName else {
            throw MusapException.init(MusapError.unknownKey)
        }
        
        guard let keyAlias = req.key.keyName else {
            throw MusapError.internalError
        }
        
        let query: [String: Any] = [
            kSecClass              as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyAlias.data(using: .utf8)!,
            kSecAttrKeyClass       as String: kSecAttrKeyClassPrivate,
            kSecReturnRef          as String: true
        ]
        

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw MusapError.internalError
        }
        
        let privateKey = item as! SecKey
        let dataToSign = req.data
        let signAlgo: SecKeyAlgorithm =  req.algorithm.getAlgorithm() ?? SignatureAlgorithm.SHA256withECDSA

        var error: Unmanaged<CFError>?
        
        guard let signature = SecKeyCreateSignature(privateKey, signAlgo, dataToSign as CFData, &error) else {
            // Signing failed
            throw MusapError.internalError
        }
        
        let signatureData = signature as Data
        
        return MusapSignature(rawSignature: signatureData)
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
        let algorithm = req.keyAlgorithm
        if algorithm.isRsa() {
            return SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256
        } else {
            return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
        }
    }
    
    private func resolveAlgorithm(req: KeyGenReq) -> String {
        let algorithm = req.keyAlgorithm
        if algorithm.isRsa() { return KeyAlgorithm.PRIMITIVE_RSA }
        if algorithm.isEc()  { return KeyAlgorithm.PRIMITIVE_EC  }
        return KeyAlgorithm.PRIMITIVE_EC
    }
    
}
