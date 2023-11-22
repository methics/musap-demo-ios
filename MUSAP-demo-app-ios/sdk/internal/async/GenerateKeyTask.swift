//
//  GenerateKeyTask.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 6.11.2023.
//

import Foundation

class GenerateKeyTask {

    typealias CompletionHandler = (Result<MusapKey, MusapError>) -> Void

    func generateKeyAsync(sscd: any MusapSscdProtocol, req: KeyGenReq, completion: @escaping CompletionHandler) async throws -> MusapKey {
        do {
            let key = try await withCheckedThrowingContinuation { continuation in
                do {
                    let generatedKey = try sscd.generateKey(req: req)
                    let activeSscd   = sscd.getSscdInfo()
                    let sscdId       = sscd.generateSscdId(key: generatedKey)

                    activeSscd.sscdId = sscdId
                    generatedKey.sscdId = sscdId
                    let storage = MetadataStorage()
                    try storage.storeKey(key: generatedKey, sscd: activeSscd)

                    continuation.resume(returning: generatedKey)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            //completion(.success(key))
            return key
        } catch {
            completion(.failure(MusapError.internalError))
            throw MusapError.internalError
        }
    }
}
