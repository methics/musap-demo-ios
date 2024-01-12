//
//  LinkAccountResponsePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class LinkAccountResponsePayload: ResponsePayload {
    
    public let linkId: String
    public let name:   String
    
    init(linkId: String, name: String, status: String, errorCode: String?) {
        self.linkId = linkId
        self.name = name
        super.init(status: status, errorCode: errorCode)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func isSuccess() -> Bool {
        return self.status.lowercased() == "success"
    }
    
}
