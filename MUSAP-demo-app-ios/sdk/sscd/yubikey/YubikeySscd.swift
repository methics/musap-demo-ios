//
//  YubikeySscd.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 22.11.2023.
//

import Foundation
import YubiKit
import SwiftUI

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
        let sscd = self.getSscdInfo()
        
        var thePin: String? = nil
        let semaphore = DispatchSemaphore(value: 0)
        
        YubikeySscd.displayEnterPin { pin in
            print("Received PIN: \(pin)")
            semaphore.signal()
            thePin = pin
        }

        semaphore.wait()
        guard let pin = thePin else {
            throw MusapError.internalError
        }
        
        var musapKey: MusapKey?
        var generationError: Error?
        
        let group = DispatchGroup()
        group.enter()
        
        print("trying to generate key with yubikey...")
        self.yubiKeyGen(pin: pin, req: req) { result in
            switch result {
            case .success(let publicKey):
                
                var pubKeyError: Unmanaged<CFError>?
                
                guard let publicKeyData  = SecKeyCopyExternalRepresentation(publicKey, &pubKeyError) as Data?,
                      let publicKeyBytes = publicKeyData.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in ptr.baseAddress })
                else {
                    print("Could not form public key data")
                    generationError = MusapError.internalError
                    return
                }
                
                let publicKeyObj = PublicKey(publicKey: Data(bytes: publicKeyBytes, count: publicKeyData.count))
                
                guard let keyAlgorithm = req.keyAlgorithm else {
                    print("Key algorithm was not set in KeyGenReq, cant construct MusapKey")
                    generationError = MusapError.invalidAlgorithm
                    return
                }
                
                musapKey = MusapKey(keyAlias:  req.keyAlias,
                                    sscdType:  YubikeySscd.SSCD_TYPE,
                                    publicKey: publicKeyObj,
                                    algorithm: keyAlgorithm,
                                    keyUri:    KeyURI(name: req.keyAlias, sscd: sscd.sscdType, loa: "loa2")
                )
                
                break
                
            case .failure(let error):
                print(error)
                generationError = error
            }
            
            group.leave()
        }
        
        group.wait()
        
        if let error = generationError {
            throw error
        }
        
        guard let generatedKey = musapKey else {
            throw MusapError.internalError
        }
        
        return generatedKey
    }
    
    func sign(req: SignatureReq) throws -> MusapSignature {
        print("Trying to sign with YubiKey")
        var thePin: String? = nil
        let semaphore = DispatchSemaphore(value: 0)
        
        YubikeySscd.displayEnterPin { pin in
            thePin = pin
            print("Got PIN: \(pin)")
            semaphore.signal()
        }
        
        semaphore.wait()
        
        guard let pin = thePin else {
            print("PIN error")
            throw MusapError.internalError
        }
        
        
        let group = DispatchGroup()
        group.enter()
        
        var musapSignature: MusapSignature?
        var signError: Error?
        
        print("Running yubiSign()")
        self.yubiSign(pin: pin, req: req) { result in
            
            switch result {
            case .success(let data):
                
                print("Got some data from self.yubiSign()")
                musapSignature = MusapSignature(rawSignature: data, key: req.getKey(), algorithm: req.algorithm, format: req.format)
    
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                signError = error
            }
            
            group.leave()
        
            
        }
        
        group.wait()
        
        if let error = signError {
            throw error
        }
        
        guard let signature = musapSignature else {
            throw MusapError.internalError
        }
        
        return signature
    }
    
    func getSscdInfo() -> MusapSscd {
        let musapSscd = MusapSscd(sscdName:        "Yubikey",
                                  sscdType:        YubikeySscd.SSCD_TYPE,
                                  sscdId:          "Yubikey",
                                  country:         "FI",
                                  provider:        "Yubico",
                                  keyGenSupported: true,
                                  algorithms:      [KeyAlgorithm.ECC_P256_K1, KeyAlgorithm.ECC_P384_K1],
                                  formats:         [SignatureFormat.RAW]
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
    
    private func yubiKeyGen(pin: String, req: KeyGenReq, completion: @escaping (Result<SecKey, Error>) -> Void ) {
        let yubiKeyconnection = YubiKeyConnection()
        
        yubiKeyconnection.connection { connection in
            
            if let nfcConnection = yubiKeyconnection.nfcConnection {
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
                            
                            session.verifyPin(pin, completion: { resp, error in
                                
                                guard error == nil else {
                                    print("Yubikey: Could not verify PIN")
                                    YubiKitManager.shared.stopNFCConnection(withErrorMessage: "Wrong PIN")
                                    completion(.failure(error!))
                                    return
                                }
                                
                                YubiKitManager.shared.stopNFCConnection(withMessage: "KeyPair generated")
                                                                
                                if let error = error {
                                    completion(.failure(error))
                                } else if let pubKey = publicKey {
                                    completion(.success(pubKey))
                                } else {
                                    completion(.failure(MusapError.keygenUnsupported))
                                }
                                
                                
                            })
                        
                            guard error == nil else {
                                print("Key generation failed")
                                completion(.failure(MusapError.internalError))
                                return
                            }
                            
  
                        }
                    }
                }
            }
            
        }
   
        print("end of func")
        
    }
    
    private func yubiSign(pin: String, req: SignatureReq, completion: @escaping (Result<Data, Error>) -> Void) {
        let yubiKeyConnection = YubiKeyConnection()
        print("Trying to get piv Session and NFC connection")
        
        yubiKeyConnection.connection { connection in
            
            if let nfcConnection = yubiKeyConnection.nfcConnection {
                connection.pivSession { session, error in
                    
                    print("got piv session")
                    if let error = error {
                        print("Failure: \(error)")
                        completion(.failure(error))
                    }
                    
                    guard let session = session else {
                        print("Could not get piv session")
                        YubiKitManager.shared.stopNFCConnection(withErrorMessage: "Could not get PIV session")
                        return
                    }
                    
                    session.authenticate(withManagementKey: YubikeySscd.MANAGEMENT_KEY, type: .tripleDES()) { error in
                        session.verifyPin(pin) { resp, error in
                        
                            if let error = error {
                                print("VerifyPin failed: \(String(describing: error))")
                                completion(.failure(error))
                                YubiKitManager.shared.stopNFCConnection(withErrorMessage: "Verify PIN failed")
                                return
                            } else {
                                print("PIN verified successfully")
                            }
                            
                            
                        }
                        
                        if let error = error {
                            print("yubikey authentication error: \(String(describing: error.localizedDescription))")
                            completion(.failure(error))
                            return
                        }
                        
                        guard let algorithm = req.algorithm.getAlgorithm() else {
                            // no algorithm, do we default to something?
                            print("No algorithm in request")
                            return
                        }
                        
                        print("start session.signWithKey")
                        
                        let keyType = self.selectKeyType(req: req)
                        
                        print("keyType: \(keyType)")
                        
                        session.signWithKey(in: .signature, type: keyType, algorithm: algorithm, message: req.data) {
                            signature, error in
                            
                            guard let signature = signature else {
                                if let error = error  {
                                    print("Signing failed: \(error.localizedDescription)")
                                }
                                return
                            }
                            
                            print("Got signature!")
                        
                            //TODO: COmpletion here
                            
                            guard let publicKey = req.getKey().getPublicKey()?.toSecKey(keyType: keyType) else {
                                print("Could not get public key")
                                return
                            }
                            
                            var secKeyVerifySignatureError: Unmanaged<CFError>?
                            let result = SecKeyVerifySignature(publicKey,
                                                               algorithm,
                                                               req.data as CFData,
                                                               signature as CFData,
                                                               &secKeyVerifySignatureError)
                            
                            print("Is signature valid: \(result)")
                            YubiKitManager.shared.stopNFCConnection()
                            completion(.success(signature))
                        }
                        
                    }
                }
            }
        }
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
    
    private func selectKeyType(req: SignatureReq) -> YKFPIVKeyType {
        
        if let keyAlgorithm = req.getKey().getAlgorithm() {
            if keyAlgorithm.isEc() {
                print("key algorithm is EC")
                if keyAlgorithm.bits == 256 { return YKFPIVKeyType.ECCP256 }
                if keyAlgorithm.bits == 384 { return YKFPIVKeyType.ECCP384 }
            }
            
            if keyAlgorithm.isRsa() {
                print("keyalgo is RSA")
                if keyAlgorithm.bits == 1024 { return YKFPIVKeyType.RSA1024 }
                if keyAlgorithm.bits == 2048 { return YKFPIVKeyType.RSA2048 }
            }
        } else {
            print("select key type: key algorithm was nil")
        }
        print("Couldnt detect key algorithm")
        return YKFPIVKeyType.unknown
    }
    
    
    /**
     Usage:
     YubiKeySscd.displayEnterPin { pin in
         print("Received PIN: \(pin)")
         // Handle the received PIN
     }
     */
    private static func displayEnterPin(completion: @escaping (String) -> Void) {
        
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene

            if let rootViewController = windowScene?.windows.first?.rootViewController {
                let pinInputView = PINInputView { pin in
                    completion(pin)
                    rootViewController.dismiss(animated: true, completion: nil)
                }
                
                let hostingController = UIHostingController(rootView: pinInputView)

                hostingController.modalPresentationStyle = .fullScreen // or as per your requirement
                rootViewController.present(hostingController, animated: true, completion: nil)
            }
        }
        

    }
    
    

    
    
}


