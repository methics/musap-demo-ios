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
    let createdDate:      Date
    var publicKey:        PublicKey?
    var certificate:      MusapCertificate?
    var certificateChain: [MusapCertificate]?
    var attributes:       [KeyAttribute]?
    let keyUsages:        [String]
    let loa:              [MusapLoa]
    let algorithm:        KeyAlgorithm
    let keyUri:           String
    let attestation:      KeyAttestation
    
    
    init(
        keyname:          String,
        keyType:          String,
        keyId:            String,
        sscdId:           String,
        sscdType:         String,
        createdDate:      Date,
        publicKey:        PublicKey,
        certificate:      MusapCertificate,
        certificateChain: [MusapCertificate],
        attributes:       [KeyAttribute],
        keyUsages:        [String],
        loa:              [MusapLoa],
        algorithm:        KeyAlgorithm,
        keyUri:           String,
        attestation:      KeyAttestation
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

struct MusapCertificate: Codable {
    
}

struct MusapLoa: Codable {
    
}

struct KeyAlgorithm: Codable {
    
}

struct KeyAttestation: Codable {
    
}
