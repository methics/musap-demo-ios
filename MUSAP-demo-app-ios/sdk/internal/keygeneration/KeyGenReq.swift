//
//  KeyGenReq.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class KeyGenReq {
    
    let keyAlias: String
    let did: String
    let role: String
    let stepUpPolicy: StepUpPolicy
    let attributes: [KeyAttribute]
    let keyAlgorithm: KeyAlgorithm?
    
    
    init(
        keyAlias: String,
        did: String,
        role: String,
        stepUpPolicy: StepUpPolicy,
        attributes: [KeyAttribute],
        keyAlgorithm: KeyAlgorithm
    )
    {
        self.keyAlias = keyAlias
        self.did = did
        self.role = role
        self.stepUpPolicy = stepUpPolicy
        self.attributes = attributes
        self.keyAlgorithm = keyAlgorithm
    }
    
}
