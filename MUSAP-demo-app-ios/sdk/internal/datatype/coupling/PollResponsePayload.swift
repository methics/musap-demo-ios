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
    
    init(signaturePayload: SignaturePayload, transId: String, status: String?, errorCode: String?) {
        self.signaturePayload = signaturePayload
        self.transId = transId
        super.init(status: status ?? "", errorCode: errorCode)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func toSignatureReq(key: MusapKey) -> SignatureReq? {
        let req = self.signaturePayload.toSignatureReq(key: key)
        
        guard req != nil else {
            return nil
        }
        
        return req
    }
    
}
