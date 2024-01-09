//
//  RelyingParty.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class RelyingParty {
    
    private var name: String
    private var linkId: String
    
    init(payload: LinkAccountResponsePayload) {
        self.linkId = payload.linkId
        self.name   = payload.name
    }
    
    init(name: String, linkId: String) {
        self.name = name
        self.linkId = linkId
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getLinkId() -> String {
        return self.linkId
    }
    
}
