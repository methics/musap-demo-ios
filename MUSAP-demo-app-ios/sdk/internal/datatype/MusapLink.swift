//
//  MusapLink.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class MusapLink: Encodable {
    
    private static let COUPLE_MSG_TYPE       = "linkaccount"
    private static let ENROLL_MSG_TYPE       = "enrolldata"
    private static let POLL_MSG_TYPE         = "getdata"
    private static let SIG_CALLBACK_MSG_TYPE = "signaturecallback"
    private static let SIGN_MSG_TYPE         = "externalsignature"
    
    private static let POLL_AMOUNT = 20
    
    private let url:     String
    private var musapId: String
    private var aesKey:  String
    private var macKey:  String
    
    init(url: String, musapId: String) {
        self.url = url
        self.musapId = musapId
    }
    
    public func setMusapId(musapId: String) {
        self.musapId = musapId
    }
    
    public func setAesKey(aesKey: String) {
        self.aesKey = aesKey
    }
    
    public func setMacKey(macKey: String) {
        self.macKey = macKey
    }
    
    public func encrypt(msg: MusapMessage) {
        //TODO:
    }
    
    public func decrypt(msg: MusapMessage) {
        //TODO:
    }
    
    public func enroll(fcmToken: String) throws -> MusapLink {
        let payload = EnrollDataPayload(fcmToken: fcmToken)
        
        guard let payload = payload.getBase64Encoded() else {
            throw MusapError.internalError
        }
        
        var msg = MusapMessage()
        msg.payload = payload
        msg.type    = MusapLink.ENROLL_MSG_TYPE
        
        
        //TODO: DO THE HTTP REQ

        
    }
    
    public func couple(couplingCode: String, uuid: String) throws -> RelyingParty {
        let payload = LinkAccountPayload(couplingCode: couplingCode, musapId: uuid)
        
        let msg = MusapMessage()
        if let payload = payload.getBase64Encoded() {
            msg.payload = payload
        } else {
            throw MusapError.internalError
        }
        msg.type = MusapLink.COUPLE_MSG_TYPE
        
        //TODO: HTTP REQ
        
        
    }
    
    public func poll() throws -> PollResponsePayload? {
        var msg = MusapMessage()
        msg.type = MusapLink.POLL_MSG_TYPE
        msg.musapId = self.musapId
        
        //TODO Send HTTP REQ, return PollResponsePayload
        
    }
    
    
    public func sendSignatureCallback(signature: MusapSignature, transId: String) throws {
        
    }
    
    public func sign(payload: ExternalSignaturePayload) throws -> ExternalSignatureResponsePayload {
        
    }
    
    public func sendRequest(msg: MusapMessage) -> MusapMessage? {
        
    }
    
    private func pollForSignature(transId: String, completion: @escaping (Result<ExternalSignatureResponsePayload, Error>) -> Void) {
        for i in 0..<MusapLink.POLL_AMOUNT {
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2 * i)) {
                let payload = ExternalSignaturePayload()
                payload.transId = transId

                guard let payloadBase64 = payload.getBase64Encoded() else {
                    completion(.failure(MusapError.internalError))
                    return
                }

                var msg = MusapMessage()
                msg.payload = payloadBase64
                msg.type = MusapLink.SIGN_MSG_TYPE
                msg.musapId = self.getMusapId()

                guard let respMsg = self.sendRequest(msg: msg), let payloadData = Data(base64Encoded: respMsg.payload) else {
                    completion(.failure(MusapError.internalError))
                    return
                }

                if let resp = try? JSONDecoder().decode(ExternalSignatureResponsePayload.self, from: payloadData) {
                    if resp.status == "pending" {
                        return
                    }

                    if resp.status == "failed" {
                        completion(.failure(MusapError.internalError))
                        return
                    }

                    completion(.success(resp))
                    return
                } else {
                    completion(.failure(MusapError.internalError))
                }
            }
        }
    }
    
    public func getMusapId() -> String {
        return self.musapId
    }
    
}
