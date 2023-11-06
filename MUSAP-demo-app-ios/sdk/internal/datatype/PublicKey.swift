//
//  PublicKey.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 3.11.2023.
//

import Foundation

class PublicKey: Codable {
    
    private var publickeyDer: Data

    init(publicKey: Data) {
        self.publickeyDer = publicKey
    }

    func getDER() -> Data {
        return publickeyDer
    }

    func getPEM() -> String {
        let base64Signature = publickeyDer.base64EncodedString()

        var pem = "-----BEGIN PUBLIC KEY-----\n"

        let width = 64
        let length = base64Signature.count

        for i in stride(from: 0, to: length, by: width) {
            let end = min(i + width, length)
            let range = base64Signature.index(base64Signature.startIndex, offsetBy: i)..<base64Signature.index(base64Signature.startIndex, offsetBy: end)
            pem += base64Signature[range]
            pem += "\n"
        }

        pem += "-----END PUBLIC KEY-----\n"
        return pem
    }
}
