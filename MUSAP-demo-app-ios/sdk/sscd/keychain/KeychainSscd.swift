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
        
        //TODO: How to do this in swift
        
        /*
         KeyGenParameterSpec.Builder builder = new KeyGenParameterSpec.Builder(req.getKeyAlias(),
                 KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY)
                 .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512);

         if (algSspec != null) builder.setAlgorithmParameterSpec(algSspec);
         KeyGenParameterSpec spec = builder.build();

         KeyPairGenerator kpg = KeyPairGenerator.getInstance(algorithm, "AndroidKeyStore");
         kpg.initialize(spec);

         KeyPair keyPair = kpg.generateKeyPair();
         */
        
        
        let generatedKey = MusapKey(keyname: req.keyAlias,
                                    keyType: "type",
                                    keyId: "keyid",
                                    sscdId: "",
                                    sscdType: "type",
                                    createdDate: Date(),
                                    publicKey: PublicKey(publicKey: Data()),
                                    certificate: MusapCertificate(),
                                    certificateChain: <#T##[MusapCertificate]#>,
                                    attributes: <#T##[KeyAttribute]#>,
                                    keyUsages: <#T##[String]#>,
                                    loa: <#T##[MusapLoa]#>,
                                    algorithm: <#T##KeyAlgorithm#>,
                                    keyUri: <#T##String#>,
                                    attestation: <#T##KeyAttestation#>)
        
    }
    
    //TODO: -> MusapSignature
    func sign(req: SignatureReq) throws -> MusapKey {
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
