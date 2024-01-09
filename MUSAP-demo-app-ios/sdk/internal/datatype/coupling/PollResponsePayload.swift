//
//  PollResponsePayload.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class PollResponsePayload: ResponsePayload {
    
    private let signaturePayload: SignaturePayload
    private let transId: String
    
    init(signaturePayload: SignaturePayload, transId: String) {
        self.signaturePayload = signaturePayload
        self.transId = transId
    }
    
    public func toSignatureReq(key: MusapKey) -> SignatureReq {
        let req = self.signaturePayload.toSignatureReq(key: key)
        
    }
    
}
