//
//  KeyDiscoveryAPI.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.11.2023.
//

import Foundation

public class KeyDiscoveryAPI {
        
    private var storage: MetadataStorage
    private var enabledSscds: [any MusapSscdProtocol]
    
    public init(storage: MetadataStorage) {
        self.storage = storage
        self.enabledSscds = []
    }
    
    func listEnabledSscds() -> [any MusapSscdProtocol] {
        return self.enabledSscds
    }
    
    //TODO: Match from SscdSearchReq
    func listMatchingSscds(req: SscdSearchReq) -> [any MusapSscdProtocol] {
        return self.enabledSscds
    }
    
    public func listActiveSscds() -> [MusapSscd] {
        return storage.listActiveSscds()
    }
    
    func enableSscd(_ sscd: any MusapSscdProtocol) -> Void {
        self.enabledSscds.append(sscd)
    }
    
    public func findKey(req: KeySearchReq) -> [MusapKey] {
        let keys = self.listKeys()
        
        var matchingKeys = [MusapKey]()
        for key in keys {
            if req.keyMatches(key: key) {
                matchingKeys.append(key)
            }
        }
        
        return matchingKeys
    }
    
    public func listKeys() -> [MusapKey] {
        return self.storage.listKeys()
    }
    
    public func removeKey(key: MusapKey) -> Bool {
        return self.storage.removeKey(key: key)
    }
    
}
