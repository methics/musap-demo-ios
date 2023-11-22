//
//  KeyBindReq.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class KeyBindReq {
    
    var keyAlias: String
    var did: String
    var role: String
    var stepUpPolicy: StepUpPolicy //TODO: StepUpPolicy class
    var attributes: [KeyAttribute]
    var generateNewKey: Bool
    
    init(
        keyAlias:       String,
        did:            String,
        role:           String,
        stepUpPolicy:   StepUpPolicy,
        attributes:     [KeyAttribute],
        generateNewKey: Bool = false
    ) 
    {
        self.keyAlias = keyAlias
        self.did = did
        self.role = role
        self.stepUpPolicy = stepUpPolicy
        self.attributes = attributes
        self.generateNewKey = generateNewKey
    }
    
    private func addAttribute(key: String, value: String) -> Void {
        let keyAttribute = KeyAttribute(name: key, value: value)
        self.attributes.append(keyAttribute)
    }
    
    private func addAttribute(attribute: KeyAttribute) {
        self.attributes.append(attribute)
    }
    
    
    
    
}


