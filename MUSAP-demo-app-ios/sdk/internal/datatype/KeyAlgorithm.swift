//
//  KeyAlgorithm.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 8.11.2023.
//


import Foundation
import Security

public struct KeyAlgorithm: Codable, Equatable {
    
    static let PRIMITIVE_RSA = kSecAttrKeyTypeRSA as String
    static let PRIMITIVE_EC = kSecAttrKeyTypeECSECPrimeRandom as String

    static let CURVE_SECP256K1 = "secp256k1"
    static let CURVE_SECP384K1 = "secp384k1"
    static let CURVE_SECP256R1 = "secp256r1"
    static let CURVE_SECP384R1 = "secp384r1"
    
    static let RSA_2K = KeyAlgorithm(primitive: PRIMITIVE_RSA, bits: 2048)
    static let RSA_4K = KeyAlgorithm(primitive: PRIMITIVE_RSA, bits: 4096)
    static let ECC_P256_K1 = KeyAlgorithm(primitive: PRIMITIVE_EC, curve: CURVE_SECP256K1, bits: 256)
    static let ECC_P384_K1 = KeyAlgorithm(primitive: PRIMITIVE_EC, curve: CURVE_SECP384K1, bits: 384)
    static let ECC_P256_R1 = KeyAlgorithm(primitive: PRIMITIVE_EC, curve: CURVE_SECP256R1, bits: 256)
    static let ECC_P384_R1 = KeyAlgorithm(primitive: PRIMITIVE_EC, curve: CURVE_SECP384R1, bits: 384)

    let primitive: String
    let curve: String?
    let bits: Int

    /// Initialize for RSA with bit size
    init(primitive: String, bits: Int) {
        self.primitive = primitive
        self.bits = bits
        self.curve = nil
    }

    /// Initialize for EC with a curve and bit size
    init(primitive: String, curve: String, bits: Int) {
        self.primitive = primitive
        self.curve = curve
        self.bits = bits
    }

    /// Check if it is RSA key
    func isRsa() -> Bool {
        return primitive == KeyAlgorithm.PRIMITIVE_RSA
    }

    /// Check if it is EC key
    func isEc() -> Bool {
        return primitive == KeyAlgorithm.PRIMITIVE_EC
    }

    /// Description of key algorithm
    func description() -> String {
        if let curve = curve {
            return "[\(primitive)/\(curve)/\(bits)]"
        } else {
            return "[\(primitive)/\(bits)]"
        }
    }
}
