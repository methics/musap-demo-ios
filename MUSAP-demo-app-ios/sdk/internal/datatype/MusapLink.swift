//
//  MusapLink.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.1.2024.
//

import Foundation

public class MusapLink: Encodable, Decodable {
    
    private static let COUPLE_MSG_TYPE       = "linkaccount"
    private static let ENROLL_MSG_TYPE       = "enrolldata"
    private static let POLL_MSG_TYPE         = "getdata"
    private static let SIG_CALLBACK_MSG_TYPE = "signaturecallback"
    private static let SIGN_MSG_TYPE         = "externalsignature"
    
    private static let POLL_AMOUNT = 20
    
    private let url:     String
    private var musapId: String?
    private var aesKey:  String?
    private var macKey:  String?
    
    init(url: String, musapId: String?) {
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
    
    /**
    Enroll this MUSAP instance with MUSAP Link
     - returns: MusapLink
     - throws:  MusapError
     */
    public func enroll(fcmToken: String) async throws -> MusapLink {
        let payload = EnrollDataPayload(fcmToken: fcmToken)
        
        guard let payload = payload.getBase64Encoded() else {
            print("MusapLink.enroll(): no payload")
            throw MusapError.internalError
        }
        
        let msg = MusapMessage()
        msg.payload = payload
        msg.type    = MusapLink.ENROLL_MSG_TYPE
        
        guard let url = URL(string: self.url) else {
            print("Could not create URL object")
            throw MusapError.internalError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(msg)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode to JSON")
            throw MusapError.internalError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Bad http response or statuscode: \(response)")
            throw MusapError.internalError
        }
        
        do {
            // Get the MusapMessage from json
            let decodedMessage = try JSONDecoder().decode(MusapMessage.self, from: data)
            
            // Make sure payload is there, and turn it into data from base64encoded str
            guard let payloadBase64 = decodedMessage.payload,
                  let payloadData = Data(base64Encoded: payloadBase64)
            else {
                print("Failed to turn payload to data")
                throw MusapError.internalError
            }
            
            // Turn the data to EnrollDataResponsePayload
            let enrollDataResponsePayload = try JSONDecoder().decode(EnrollDataResponsePayload.self, from: payloadData)
            
            // Make sure the musap ID is there since it is required
            guard let musapId = enrollDataResponsePayload.musapid else {
                print("enroll: Could not get Musap ID ")
                throw MusapError.internalError
            }
            
            // Return MusapLink
            self.musapId = musapId
            return self
        } catch {
            print("error in enroll with json: \(error)")
        }

        // if we got to here, there was some error
        throw MusapError.internalError
    }
    
    
    //TODO: Finish
    public func couple(couplingCode: String, uuid: String) async throws -> RelyingParty {
        let payload = LinkAccountPayload(couplingCode: couplingCode, musapId: uuid)
        
        let msg = MusapMessage()
        msg.type = MusapLink.COUPLE_MSG_TYPE
        
        if let payload = payload.getBase64Encoded() {
            msg.payload = payload
        } else {
            throw MusapError.internalError
        }
        
        guard let url = URL(string: self.url) else {
            throw MusapError.internalError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(msg)
            request.httpBody = jsonData
            
            // To see from xcode what we are getting for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("COUPLING request body: \(jsonString)")
            }
            
        } catch {
            print("error encoding json: \(error)")

            throw MusapError.internalError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MusapError.internalError
        }
        
        do {
            
            let musapMessage = try JSONDecoder().decode(MusapMessage.self, from: data)
            let rp = RelyingParty(name: "name", linkId: "link_id")
            //TODO: This needs some work still, debug
            return rp
            
        } catch {
            print("Error while coupling: \(error)")
        }
        
        throw MusapError.internalError
    }
    
    public func poll() async throws -> PollResponsePayload? {
        let msg = MusapMessage()
        msg.type = MusapLink.POLL_MSG_TYPE
        msg.musapid = self.musapId
        
        guard let url = URL(string: self.url) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(msg)
            request.httpBody = jsonData
            
            // To see from xcode what we are getting for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("POLL request body: \(jsonString)")
            }
            
        } catch {
            print("error encoding json: \(error)")
        }

        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("poll: HTTP status code was not 200")
            throw MusapError.internalError
        }
        
        let decoder = JSONDecoder()
        let respMsg = try decoder.decode(MusapMessage.self, from: data)
        
        guard let payloadBase64 = respMsg.payload else {
            print("No payload in musap message")
            throw MusapError.internalError
        }
        
        guard let payloadData = Data(base64Encoded: payloadBase64) else {
            print("Cant turn payload to Data()")
            throw MusapError.internalError
        }
        
        do {
            let signaturePayload = try decoder.decode(SignaturePayload.self, from: payloadData)
            
            guard let transId = respMsg.transid else {
                print("error in poll: no transId")
                throw MusapError.internalError
            }
            
            return PollResponsePayload(
                signaturePayload: signaturePayload,
                transId: transId,
                status: "success",
                errorCode: nil
            )
        } catch {
            print("error: \(error)")
        }
        
        return nil
        
    }
    
    
    public func sendSignatureCallback(signature: MusapSignature, transId: String) throws {
        
    }
    
    func sign(payload: ExternalSignaturePayload, completion: @escaping (Result<ExternalSignatureResponsePayload, Error>) -> Void) {
        guard let payloadBase64 = payload.getBase64Encoded() else {
            print("Could not get payload as base64")
            completion(.failure(MusapError.internalError))
            return
        }

        let msg = MusapMessage()
        msg.payload = payloadBase64
        msg.type = MusapLink.SIGN_MSG_TYPE
        msg.musapid = self.getMusapId()

        self.sendRequest(msg) { respMsg, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let respMsg = respMsg,
                  let payloadString = respMsg.payload,
                  let payloadData = Data(base64Encoded: payloadString) else {
                DispatchQueue.main.async {
                    completion(.failure(MusapError.internalError))
                }
                return
            }

            do {
                let resp = try JSONDecoder().decode(ExternalSignatureResponsePayload.self, from: payloadData)
                DispatchQueue.main.async {
                    if resp.status == "pending" {
                        self.pollForSignature(transId: resp.transId, completion: completion)
                    } else if resp.status == "failed" {
                        completion(.failure(MusapError.internalError))
                    } else {
                        completion(.success(resp))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(MusapError.internalError))
                }
            }
        }
    }

    
    func sendRequest(_ msg: MusapMessage, completion: @escaping (MusapMessage?, Error?) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(msg) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"]))
            return
        }
        
        guard let url = URL(string: self.url) else {
            completion(nil, MusapError.internalError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data,
                  let responseMsg = try? JSONDecoder().decode(MusapMessage.self, from: data)
            else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
                return
            }

            completion(responseMsg, nil)
        }

        task.resume()
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

                let msg = MusapMessage()
                msg.payload = payloadBase64
                msg.type = MusapLink.SIGN_MSG_TYPE
                msg.musapid = self.getMusapId()

                self.sendRequest(msg) { respMsg, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }

                    guard let respMsg = respMsg,
                          let payloadData = Data(base64Encoded: respMsg.payload ?? "") else {
                        DispatchQueue.main.async {
                            completion(.failure(MusapError.internalError))
                        }
                        return
                    }

                    if let resp = try? JSONDecoder().decode(ExternalSignatureResponsePayload.self, from: payloadData) {
                        DispatchQueue.main.async {
                            if resp.status == "pending" {
                                return
                            } else if resp.status == "failed" {
                                completion(.failure(MusapError.internalError))
                                return
                            }

                            completion(.success(resp))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(MusapError.internalError))
                        }
                    }
                }
            }
        }
    }
    
    public func getMusapId() -> String? {
        return self.musapId
    }
    
}
