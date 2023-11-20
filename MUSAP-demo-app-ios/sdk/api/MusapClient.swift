//
//  MusapClient.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class MusapClient {
        
    static func generateKey(sscd: any MusapSscdProtocol, req: KeyGenReq, completion: @escaping (Result<MusapKey, MusapError>) -> Void) async {
        do {
            let generateKeyTask = GenerateKeyTask()
            let key = try await generateKeyTask.generateKeyAsync(sscd: sscd, req: req, completion: completion)
            completion(.success(key))
        } catch {
            completion(.failure(MusapError.internalError))
        }
    }
    
    static func bindKey(sscd: any MusapSscdProtocol, req: KeyBindReq, completion: @escaping (Result<MusapKey, MusapError>) -> Void) async {
        let bindKeyTask = BindKeyTask()
        do {
            let musapKey = try await bindKeyTask.bindKey(req: req, sscd: sscd)
            completion(.success(musapKey))
        } catch {
            completion(.failure(MusapError.bindUnsupported))
        }
    }
    
    static func sign(req: SignatureReq, completion: @escaping (Result<MusapSignature, MusapError>) -> Void) async {
        do {
            let signTask = SignTask()
            let signature = try await signTask.sign(req: req)
            completion(.success(signature))
        } catch let musapError as MusapError {
            completion(.failure(musapError))
        } catch {
            completion(.failure(MusapError.internalError))
        }
    }
    
    
    // Return from keydiscovery
    static func listEnabledSscds() -> [any MusapSscdProtocol]? {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        
        let enabledSscds = keyDiscovery.listEnabledSscds()
        
        print("enabledSscds in MusapClient: \(enabledSscds.count)")
        
        return enabledSscds
    }
    
    
    static func listEnabledSscds(req: SscdSearchReq) -> any MusapSscdProtocol {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        
        //TODO: Will this work? What is the issue?
        return keyDiscovery.listMatchingSscds(req: req) as! (any MusapSscdProtocol)
        
    }
    
    static func listActiveSscds() -> [any MusapSscdProtocol] {
        return KeyDiscoveryAPI(storage: MetadataStorage()).listEnabledSscds()

    }
    
    public static func listActiveSscds(req: SscdSearchReq) -> [MusapSscd] {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        return keyDiscovery.listActiveSscds()
    }
    
    public static func listKeys() -> [MusapKey] {
        let keys = MetadataStorage().listKeys()
        print("Found: \(keys.count) keys from storage")
        return keys
    }
    
    public static func listKeys(req: KeySearchReq) -> [MusapKey] {
        let keys = MetadataStorage().listKeys(req: req)
        print("Found: \(keys.count) keys from storage")
        return keys
    }
    
    static func enableSscd(sscd: any MusapSscdProtocol) {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        keyDiscovery.enableSscd(sscd)
    }
    
    
    public static func getKeyByUri(keyUri: String) -> MusapKey? {
        let keyList = MetadataStorage().listKeys()
        let keyUri = KeyURI(keyUri: keyUri)
        
        for key in keyList {
            if let loopKeyUri = key.keyUri {
                if loopKeyUri.keyUriMatches(keyUri: keyUri) {
                    return key
                }
            }
        }
        
        return nil
    }
    
    //TODO: Create KeyURI object
    public static func getKeyByUri(keyUriObject: KeyURI) -> MusapKey? {
        let keyList = MetadataStorage().listKeys()
        
        for key in keyList {
            if let loopKeyUri = key.keyUri {
                if loopKeyUri.keyUriMatches(keyUri: keyUriObject) {
                    return key
                }
            }
        }
        
        return nil
    }
    
    public static func importData(data: String) throws {
        let storage = MetadataStorage()
        guard let importData = MusapImportData.fromJson(jsonString: data) else {
            throw MusapError.internalError
        }
        
        try storage.addImportData(data: importData)
        
    }
    
    public static func exportData() -> String? {
        let storage = MetadataStorage()
        
        guard let exportData = storage.getImportData().toJson() else {
            print("Could not export data")
            return nil
        }
        
        return exportData
    }
    
    public static func removeKey(musapKey: MusapKey) -> Bool {
        return KeyDiscoveryAPI(storage: MetadataStorage()).removeKey(key: musapKey)
    }
    
    //TODO: Implement MusapSscd
    public static func removeSscd(musapSscd: String) {
        
    }
    
    //TODO: return new MusapLink
    public static func enableLink() {
        
    }
    
    public static func disableLink() {
        
    }
    
    //TODO: returns signatureReq
    public static func pollLink() {
        
    }
    
}

