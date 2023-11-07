//
//  MusapKey.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class MusapKey: Codable {
    
    var keyName:          String?
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
    
    
    init(
        keyname:          String,
        keyType:          String? = nil,
        keyId:            String? = nil,
        sscdId:           String? = nil,
        sscdType:         String,
        createdDate:      Date?   = nil,
        publicKey:        PublicKey,
        certificate:      MusapCertificate,
        certificateChain: [MusapCertificate]? = nil,
        attributes:       [KeyAttribute],
        keyUsages:        [String]? = nil,
        loa:              [MusapLoa],
        algorithm:        KeyAlgorithm? = nil,
        keyUri:           KeyURI,
        attestation:      KeyAttestation? = nil
    )
    {
        self.keyName          = keyname
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
    }
    
}

