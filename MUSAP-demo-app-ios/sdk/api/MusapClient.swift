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
            try await generateKeyTask.generateKeyAsync(sscd: sscd, req: req, completion: completion)
        } catch {
            // Handle errors if needed
            completion(.failure(MusapError.internalError))
        }
    }
    
    //TODO: MusapSscdInterface sscd, KeyBindReq req, MusapCallback callback
    static func bindKey(sscd: any MusapSscdProtocol, req: KeyGenReq) {
        
    }
    
    //TODO: SignatureReq, MusapCallback
    public static func sign() {
        
    }
    
    
    // Return from keydiscovery
    public static func listEnabledSscds() {
        
    }
    
    //TODO: req: String -> SScdSearchReq req
    public static func listEnabledSscds(req: String) {
        
    }
    
    //TODO: Return from storage
    public static func listActiveSscds() {
        
    }
    
    //TODO: SscdSearchReq replace String
    public static func listActiveSscds(req: String) {
        
    }
    
    //TODO: List all avaialbkle keys from storage
    public static func listKeys() {
        
    }
    
    //TODO: Replace string
    public static func listKeys(keySearchReq: String) {
        
    }
    
    //TODO: MusapSscdInterface
    public static func enableSscd() {
        
    }
    
    
    public static func getKeyByUri(keyUri: String) {
        // get from metadatastorage
    }
    
    //TODO: Create KeyURI object
    public static func getKeyByUri(keyUriObject: String) {
        
    }
    
    //TODO: MusapImportData()
    public static func importData(data: String) {
        
    }
    
    //TODO: Export JSON data
    public static func exportData() {
        
    }
    
    //TODO: Implement MusapKey
    public static func removeKey(musapKey: String) {
        
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

