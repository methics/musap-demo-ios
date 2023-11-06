//
//  SignatureReq.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

public class SignatureReq {
    
    let key:       MusapKey
    let data:      Data
    let algorithm: SignatureAlgorithm
    let format:    SignatureFormat
    
    init(key: MusapKey, data: Data, algorithm: SignatureAlgorithm, format: SignatureFormat) {
        self.key       = key
        self.data      = data
        self.algorithm = algorithm
        self.format    = format
    }
    
}
