//
//  MusapKey.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class MusapKey: Codable, Identifiable {
    
    public var id = UUID()
    var keyAlias:         String?
    var keyType:          String?
    var keyId:            String?
    var sscdId:           String?
    var sscdType:         String?
    let createdDate:      Date?
    var publicKey:        PublicKey?
    var certificate:      MusapCertificate?
    var certificateChain: [MusapCertificate]?
    var attributes:       [KeyAttribute]?
    var keyUsages:        [String]?
    var loa:              [MusapLoa]?
    var algorithm:        KeyAlgorithm?
    var keyUri:           KeyURI?
    var attestation:      KeyAttestation?
    var isBiometricRequired: Bool
    
    init(
        keyname:          String,
        keyType:          String? = nil,
        keyId:            String? = nil,
        sscdId:           String? = nil,
        sscdType:         String,
        createdDate:      Date = Date(),
        publicKey:        PublicKey,
        certificate:      MusapCertificate,
        certificateChain: [MusapCertificate]? = nil,
        attributes:       [KeyAttribute]? = nil,
        keyUsages:        [String]? = nil,
        loa:              [MusapLoa],
        algorithm:        KeyAlgorithm? = nil,
        keyUri:           KeyURI,
        attestation:      KeyAttestation? = nil,
        isBiometricRequired: Bool = false
    )
    {
        self.keyAlias          = keyname
        self.keyType          = keyType
        self.keyId            = keyId
        self.sscdId           = sscdId
        self.sscdType         = sscdType
        self.createdDate      = createdDate
        self.publicKey        = publicKey
        self.certificate      = certificate
        self.certificateChain = certificateChain
        self.attributes       = attributes
        self.keyUsages        = keyUsages
        self.loa              = loa
        self.algorithm        = algorithm
        self.keyUri           = keyUri
        self.attestation      = attestation
        self.isBiometricRequired = isBiometricRequired
    }
    
    func getSscdImplementation() -> (any MusapSscdProtocol)? {
        let sscdType = self.sscdType
        print("Looking for SSCD with type: \(String(describing: sscdType))")
        
        let enabledSscds = MusapClient.listEnabledSscds()
        
        print("enabledSscds count: \(String(describing: enabledSscds?.count))")
        
        for sscd in enabledSscds! {
            print("sscd found: \(sscd.getSscdInfo().sscdType ?? "sscdType = nil")")
            //TODO: SSCD Type should never be nil
            guard let sscdType = sscd.getSscdInfo().sscdId else {
                print("SSCD type not set!")
                return nil
            }
            
            if (self.sscdType == sscdType) {
                return sscd
            } else {
                print("SSCD " + sscdType + " does not match " + self.sscdType! + ". Continue loop..." )
            }
        }
        
        return nil
    }
    
}

