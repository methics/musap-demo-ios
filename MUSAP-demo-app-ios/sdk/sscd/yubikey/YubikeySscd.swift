//
//  YubikeySscd.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 22.11.2023.
//

import Foundation
import YubiKit

public class YubikeySscd: MusapSscdProtocol {
    
    typealias CustomSscdSettings = YubikeySscdSettings
    private let settings = YubikeySscdSettings()
    
    private static let ATTRIBUTE_SERIAL = "serial"
    private static let MANAGEMENT_KEY_TYPE: YKFPIVManagementKeyType = YKFPIVManagementKeyType.tripleDES()
    private static let MANAGEMENT_KEY = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
    static let         SSCD_TYPE = "Yubikey"
    private static let yubiKeyConnection = YubiKeyConnection()
    
    private let type: YKFPIVManagementKeyType
    private let yubiKitManager: YubiKitManager
    
    var onRequirePinEntry: ((_ completion: @escaping (String) -> Void) -> Void)?
    
    init() {
        self.yubiKitManager = YubiKitManager.shared
        self.type = YubikeySscd.MANAGEMENT_KEY_TYPE
    }
    
    func bindKey(req: KeyBindReq) throws -> MusapKey {
        throw MusapError.bindUnsupported
    }
    
    func generateKey(req: KeyGenReq) throws -> MusapKey {
        let keygenreq = req
        // ...rest of the code
        // showInsertPinDialog()
        //... rest of the code
        
        onRequirePinEntry? { [weak self] pin in
            guard pin != nil else {
                return
            }
        }
        
        throw MusapError.internalError
    }
    
    func sign(req: SignatureReq) throws -> MusapSignature {
        throw MusapError.illegalArgument
    }
    
    func getSscdInfo() -> MusapSscd {
        let musapSscd = MusapSscd(sscdName: "Yubikey",
                                  sscdType: YubikeySscd.SSCD_TYPE,
                                  sscdId: "yubikey_id",
                                  country: "FI",
                                  provider: "Yubico",
                                  keyGenSupported: true,
                                  algorithms: [KeyAlgorithm.ECC_P256_K1, KeyAlgorithm.ECC_P384_K1], formats: [SignatureFormat.RAW]
        )
        return musapSscd
    }
    
    func generateSscdId(key: MusapKey) -> String {
        guard let attributeValue = key.getAttributeValue(attrName: YubikeySscd.ATTRIBUTE_SERIAL) else {
            return YubikeySscd.SSCD_TYPE
        }
        
        return YubikeySscd.SSCD_TYPE + "/\(attributeValue)"
    }
    
    func isKeygenSupported() -> Bool {
        true
    }
    
    func getSettings() -> [String : String]? {
        return settings.getSettings()
    }
    
    func getSettings() -> YubikeySscdSettings {
        return self.settings
    }
    
    private func yubiKeyGen(pin: String, req: KeyGenReq) {
        if let nfcConnection = YubikeySscd.yubiKeyConnection.nfcConnection {
            // We have NFC connection
            
            nfcConnection.pivSession { session, error in
                guard let session = session else {
                    print("Could not get pivSession")
                    return
                }
                
                // We have PIV session
                
                session.authenticate(withManagementKey: YubikeySscd.MANAGEMENT_KEY, type: .tripleDES()) { error in
                    guard error == nil else {
                        print("error in yubikey authentication: \(String(describing: error))")
                        return
                    }
                    
                    // Authentication OK with management key
                    let slot        = YKFPIVSlot.signature
                    let pinPolicy   = YKFPIVPinPolicy.default
                    let touchPolicy = YKFPIVTouchPolicy.default
                    let keyType     = self.selectKeyType(req: req)
                    
                    session.generateKey(in: slot, type: keyType, pinPolicy: pinPolicy, touchPolicy: touchPolicy) { publicKey, error in
                        
                        guard error == nil else {
                            print("Key generation failed")
                            return
                        }
                        
                        // Key generation was was successful
                        
                        
                    }
                    
                }
                
            }
            
        } else {
            // cant connect, display failed dialog
        }
        
        
        
        
        
    }
    
    private func yubiSign(pin: String, req: SignatureReq) {
        
    }
    

    /**
         Turn (MUSAP) KeyAlgorithm to YubiKey YKFPIVKeyType
     */
    private func selectKeyType(req: KeyGenReq) -> YKFPIVKeyType {
        if let keyAlgorithm = req.keyAlgorithm {
          
            if keyAlgorithm.isEc() {
                if keyAlgorithm.bits == 256 { return YKFPIVKeyType.ECCP256 }
                if keyAlgorithm.bits == 384 { return YKFPIVKeyType.ECCP384 }
            }
            
            if keyAlgorithm.isRsa() {
                if keyAlgorithm.bits == 1024 { return YKFPIVKeyType.RSA1024 }
                if keyAlgorithm.bits == 2048 { return YKFPIVKeyType.RSA2048 }
            }
            
        }
        
        return YKFPIVKeyType.unknown
        
    }
    
    

    
    
}


