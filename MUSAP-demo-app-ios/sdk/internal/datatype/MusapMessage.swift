//
//  MusapMessage.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 24.11.2023.
//

import Foundation

/// Message between the MUSAP library and MUSAP link
public class MusapMessage {
    
    public let payload: String
    public let type: String
    public let uuid: String
    public let transId: String
    public let requestId: String
    public let mac: String
    public let iv: String
    
    init(payload: String, type: String, uuid: String, transId: String, requestId: String, mac: String, iv: String) {
        self.payload = payload
        self.type = type
        self.uuid = uuid
        self.transId = transId
        self.requestId = requestId
        self.mac = mac
        self.iv = iv
    }
    
}
