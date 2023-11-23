//
//  UpdateKeyReq.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 23.11.2023.
//

import Foundation

public class UpdateKeyReq {
    
    /// Target MusapKey to update
    private let key:        MusapKey
    
    /// NewAlias of MusapKey
    private let keyAlias:   String?
    
    /// New key DID
    private let did:        String?
    
    /// New key-specific attributes
    private let attributes: [KeyAttribute]?
    
    /// New role for the key
    private let role:       String?
    
    /// New key state
    private let state:      String?
    
    init(key:        MusapKey,
         keyAlias:   String?,
         did:        String?,
         attributes: [KeyAttribute]?,
         role:       String?,
         state:      String?
    ) {
        self.key = key
        self.keyAlias = keyAlias
        self.did = did
        self.attributes = attributes
        self.role = role
        self.state = state
    }
    
    public func getKey() -> MusapKey {
        return self.key
    }
    
    public func getAlias() -> String? {
        return self.keyAlias
    }
    
    public func getDid() -> String? {
        return self.did
    }
    
    public func getAttributes() -> [KeyAttribute]? {
        return self.attributes
    }
    
    public func getRole() -> String? {
        return self.role
    }
    
    public func getState() -> String? {
        return self.state
    }
    
}
