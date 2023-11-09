//
//  SignTask.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.11.2023.
//

import Foundation

class SignTask {
    
    typealias CompletionHandler = (Result<MusapSignature, MusapError>) -> Void


    func sign(req: SignatureReq, completion: @escaping CompletionHandler) async throws -> MusapSignature {
        do {
            let signature = try await withCheckedThrowingContinuation {
                continuation in
                Task {
                    
                    do {
                        let sscd = req.getKey().getSscdImplementation()
                        let signature = try sscd?.sign(req: req)
                        
                        if signature != nil {
                            continuation.resume(returning: signature)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }

                }
            }
            
            guard let theSignature = signature else {
                completion(.failure(MusapError.internalError))
                throw MusapError.internalError
            }
            
            completion(.success(theSignature))
            return theSignature
        
        } catch {
            completion(.failure(MusapError.internalError))
            throw MusapError.internalError
        }
    }
    
}
