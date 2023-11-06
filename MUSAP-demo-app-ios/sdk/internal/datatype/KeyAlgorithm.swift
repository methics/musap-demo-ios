//
//  KeyAlgorithm.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 6.11.2023.
//

import Foundation

public class KeyAlgorithm: Equatable, Hashable, Codable {
    
    public static let PRIMITIVE_RSA   = "RSA"
    public static let PRIMITIVE_EC    = "EC"
    
    public static let CURVE_SECP256K1 = "secp256k1"
    public static let CURVE_SECP384K1 = "secp384k1"
    
    public static let CURVE_SECP256R1 = "secp256r1"
    public static let CURVE_SECP384R1 = "secp384r1"
    
    public static let RSA_2K = KeyAlgorithm(PRIMITIVE_RSA, 2048)
    public static let RSA_4K = KeyAlgorithm(PRIMITIVE_RSA, 4096)
    
    public static let ECC_P256_K1 = KeyAlgorithm(PRIMITIVE_EC, CURVE_SECP256K1, 256)
    public static let ECC_P384_K1 = KeyAlgorithm(PRIMITIVE_EC, CURVE_SECP384K1, 384)
    public static let ECC_P256_R1 = KeyAlgorithm(PRIMITIVE_EC, CURVE_SECP256R1, 256)
    public static let ECC_P384_R1 = KeyAlgorithm(PRIMITIVE_EC, CURVE_SECP384R1, 384)
    
    
    public let primitive: String
    public let curve: String?
    public let bits: Int
    
    init(_ primitive: String, _ bits: Int) {
        self.primitive = primitive
        self.bits      = bits
        self.curve     = nil
    }
    
    init(_ primitive: String, _ curve: String, _ bits: Int) {
        self.primitive = primitive
        self.curve     = curve
        self.bits      = bits
    }
    
    public func isRsa() -> Bool {
        return KeyAlgorithm.PRIMITIVE_RSA == self.primitive
    }
    
    public func isEc() -> Bool {
        return KeyAlgorithm.PRIMITIVE_EC == self.primitive
    }
    
    public func toString() -> String {
        if self.curve != nil {
            return "[\(self.primitive)/\(String(describing: self.curve))/\(self.bits)]"
        }
        return "[\(self.primitive)/\(self.bits)]"
    }
    
    public static func ==(lhs: KeyAlgorithm, rhs: KeyAlgorithm) -> Bool {
        if lhs === rhs {
            return true
        }
        guard type(of: lhs) == type(of: rhs) else {
            return false
        }
        return lhs.bits == rhs.bits && lhs.primitive == rhs.primitive && lhs.curve == rhs.curve
    }

    // Implementing the Hashable protocol
    public func hash(into hasher: inout Hasher) {
        hasher.combine(primitive)
        hasher.combine(curve)
        hasher.combine(bits)
    }
    
    
}
