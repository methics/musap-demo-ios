//
//  MusapMessage.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 24.11.2023.
//

import Foundation

/// Message between the MUSAP library and MUSAP link
public class MusapMessage: Codable {
    
    public var payload:   String?
    public var musapId:   String?
    public var type:      String?
    public var uuid:      String?
    public var transId:   String?
    public var requestId: String?
    public var mac:       String?
    public var iv:        String?
    
    init(payload:   String,
         musapId:   String,
         type:      String,
         uuid:      String,
         transId:   String,
         requestId: String,
         mac:       String,
         iv:        String
    ) {
        self.payload = payload
        self.musapId = musapId
        self.type = type
        self.uuid = uuid
        self.transId = transId
        self.requestId = requestId
        self.mac = mac
        self.iv = iv
    }
    
    init() {
        
    }

    
}
