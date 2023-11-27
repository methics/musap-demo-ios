//
//  MusapClient.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class MusapClient {
    
    /**
     Generate a keypair and store the key metadata to MUSAP.
     - Parameters:
       - sscd: An instance conforming to `MusapSscdProtocol`, providing security services for key generation.
       - req: A `KeyGenReq` instance specifying key generation parameters like key alias, role, policy, attributes, and algorithm.
       - completion: A completion handler called with a `Result` type containing `MusapKey` on success or `MusapError` on failure.

     - Note: The method handles the asynchronous task internally and uses the `GenerateKeyTask` for the key generation process.
     */
    static func generateKey(sscd: any MusapSscdProtocol, req: KeyGenReq, completion: @escaping (Result<MusapKey, MusapError>) -> Void) async {
        do {
            let generateKeyTask = GenerateKeyTask()
            let key = try await generateKeyTask.generateKeyAsync(sscd: sscd, req: req, completion: completion)
            completion(.success(key))
        } catch {
            completion(.failure(MusapError.internalError))
        }
    }

    /**
     Binds a keypair and stores its metadata in MUSAP.

     - Parameters:
       - sscd: The SSCD used for binding the key.
       - req: A `KeyBindReq` instance, specifying the key binding requirements.
       - completion: A completion handler returning a `Result` with either a `MusapKey` on success or a `MusapError` on failure.

     - Note: Asynchronous execution, leveraging `BindKeyTask` for the key binding operation.
     */
    static func bindKey(sscd: any MusapSscdProtocol, req: KeyBindReq, completion: @escaping (Result<MusapKey, MusapError>) -> Void) async {
        let bindKeyTask = BindKeyTask()
        do {
            let musapKey = try await bindKeyTask.bindKey(req: req, sscd: sscd)
            completion(.success(musapKey))
        } catch {
            completion(.failure(MusapError.bindUnsupported))
        }
    }
    
    /**
     Signs data using a specified SSCD.

     - Parameters:
       - req: A `SignatureReq` detailing the signature request.
       - completion: A completion handler that returns a `Result` with either `MusapSignature` on success or `MusapError` on failure.

     - Note: The signing process is asynchronous, utilizing `SignTask` for the operation.
     */
    static func sign(req: SignatureReq, completion: @escaping (Result<MusapSignature, MusapError>) -> Void) async {
        do {
            let signTask = SignTask()
            let signature = try await signTask.sign(req: req)
            completion(.success(signature))
        } catch let musapError as MusapError {
            completion(.failure(musapError))
        } catch {
            completion(.failure(MusapError.internalError))
        }
    }
    
    /**
     Lists SSCDs enabled in the MUSAP library. Add an SSCD using `enableSscd` before listing.

     - Returns: An array of enabled SSCDs conforming to `MusapSscdProtocol`, or nil if no SSCDs are enabled.
     */
    static func listEnabledSscds() -> [any MusapSscdProtocol]? {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        let enabledSscds = keyDiscovery.listEnabledSscds()
        print("enabledSscds in MusapClient: \(enabledSscds.count)")
        return enabledSscds
    }
    
    /**
     Lists enabled SSCDs based on specified search criteria.

     - Parameters:
       - req: A `SscdSearchReq` to filter the list of SSCDs.
     - Returns: An array of SSCDs matching the search criteria.
     */
    static func listEnabledSscds(req: SscdSearchReq) -> [any MusapSscdProtocol] {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        
        //TODO: Will this work? What is the issue?
        return keyDiscovery.listMatchingSscds(req: req)
    }
    
    /**
     Lists active SSCDs with user-generated or bound keys.

     - Returns: An array of active SSCDs that can generate or bind keys.
     */

    static func listActiveSscds() -> [MusapSscd] {
        return KeyDiscoveryAPI(storage: MetadataStorage()).listActiveSscds()
    }
    
    /**
     Lists active SSCDs based on specified search criteria.

     - Parameters:
       - req: A `SscdSearchReq` to filter the list of active SSCDs.
     - Returns: An array of active `MusapSscd` objects matching the search criteria.
     */
    public static func listActiveSscds(req: SscdSearchReq) -> [MusapSscd] {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        return keyDiscovery.listActiveSscds()
    }
    
    /**
     Lists all available Musap Keys.

     - Returns: An array of `MusapKey` instances found in storage.
     */
    public static func listKeys() -> [MusapKey] {
        let keys = MetadataStorage().listKeys()
        print("Found: \(keys.count) keys from storage")
        return keys
    }
    
    /**
     Lists keys matching given search parameters.

     - Parameters:
       - req: A `KeySearchReq` to filter the list of keys.
     - Returns: An array of `MusapKey` instances matching the search criteria.
     */
    public static func listKeys(req: KeySearchReq) -> [MusapKey] {
        let keys = MetadataStorage().listKeys(req: req)
        print("Found: \(keys.count) keys from storage")
        return keys
    }
    /**
     Enables an SSCD for use with MUSAP. Must be called for each SSCD the application intends to support.

     - Parameters:
       - sscd: The SSCD to be enabled.
     */
    static func enableSscd(sscd: any MusapSscdProtocol) {
        let keyDiscovery = KeyDiscoveryAPI(storage: MetadataStorage())
        keyDiscovery.enableSscd(sscd)
    }
    
    /**
     Retrieves a `MusapKey` based on a given KeyURI string.

     - Parameters:
       - keyUri: The KeyURI as a string.
     - Returns: An optional `MusapKey` matching the provided KeyURI.
     */
    public static func getKeyByUri(keyUri: String) -> MusapKey? {
        let keyList = MetadataStorage().listKeys()
        let keyUri = KeyURI(keyUri: keyUri)
        
        for key in keyList {
            if let loopKeyUri = key.getKeyUri() {
                if loopKeyUri.keyUriMatches(keyUri: keyUri) {
                    return key
                }
            }
        }
        
        return nil
    }
    
    /**
     Retrieves a `MusapKey` based on a provided KeyURI object.

     - Parameters:
       - keyUriObject: A `KeyURI` object.
     - Returns: An optional `MusapKey` matching the KeyURI object.
     */
    public static func getKeyByUri(keyUriObject: KeyURI) -> MusapKey? {
        let keyList = MetadataStorage().listKeys()
        
        for key in keyList {
            if let loopKeyUri = key.getKeyUri() {
                if loopKeyUri.keyUriMatches(keyUri: keyUriObject) {
                    return key
                }
            }
        }
        
        return nil
    }
    
    /**
     Imports MUSAP key data and SSCD details from JSON.

     - Parameters:
       - data: JSON string containing MUSAP data.
     - Throws: `MusapError` if the data cannot be parsed or is invalid.
     */
    public static func importData(data: String) throws {
        let storage = MetadataStorage()
        guard let importData = MusapImportData.fromJson(jsonString: data) else {
            throw MusapError.internalError
        }
        
        try storage.addImportData(data: importData)
        
    }
    
    /**
     Exports MUSAP key data and SSCD details as a JSON string.

     - Returns: A JSON string representing MUSAP data, or nil if the data cannot be exported.
     */
    public static func exportData() -> String? {
        let storage = MetadataStorage()
        
        guard let exportData = storage.getImportData().toJson() else {
            print("Could not export data")
            return nil
        }
        
        return exportData
    }
    
    /**
     Remove a key from MUSAP.
     - Parameters:
        - key: MusapKey to remove
     - Returns: `Bool`
     */
    public static func removeKey(musapKey: MusapKey) -> Bool {
        return KeyDiscoveryAPI(storage: MetadataStorage()).removeKey(key: musapKey)
    }
    
    /**
     Remove an active SSCD from MUSAP
     - Parameters:
        - musapSscd: SSCD to remove
     */
    public static func removeSscd(musapSscd: String) {
        //TODO: code this
    }
    
    //TODO: return new MusapLink
    public static func enableLink() {
        
    }
    
    public static func disableLink() {
        
    }
    
    //TODO: returns signatureReq
    public static func pollLink() {
        
    }
    
    public static func updateKey(req: UpdateKeyReq) -> Bool {
        let storage = MetadataStorage()
        return storage.updateKeyMetaData(req: req)
    }
    
}

