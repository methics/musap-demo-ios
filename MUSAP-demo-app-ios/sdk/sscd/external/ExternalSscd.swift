//
//  ExternalSscd.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 5.1.2024.
//

import Foundation

/**
 * SSCD that uses MUSAP Link to request signatures with the "externalsign" Coupling API call
 */
public class ExternalSscd: MusapSscdProtocol {

    
    typealias CustomSscdSettings = ExternalSscdSettings
    
    static let SSCD_TYPE        = "External Signature"
    static let ATTRIBUTE_MSISDN = "msisdn"
    static let SIGN_MSG_TYPE    = "externalsignature"
    private static let POLL_AMOUNT = 10
    
    private let clientId: String
    private let settings = ExternalSscdSettings()
    private let musapLink: MusapLink
    
    init(clientId: String, musapLink: MusapLink) {
        self.clientId = settings.getClientId()
        self.musapLink = settings.getMusapLink()
    }
    
    
    
    func bindKey(req: KeyBindReq) throws -> MusapKey {
        let request: ExternalSignaturePayload = ExternalSignaturePayload(clientId: self.clientId)
    }
    
    func generateKey(req: KeyGenReq) throws -> MusapKey {
        <#code#>
    }
    
    func sign(req: SignatureReq) throws -> MusapSignature {
        <#code#>
    }
    
    func getSscdInfo() -> MusapSscd {
        <#code#>
    }
    
    func generateSscdId(key: MusapKey) -> String {
        <#code#>
    }
    
    func isKeygenSupported() -> Bool {
        <#code#>
    }
    
    func getSettings() -> [String : String]? {
        return self.settings.getSettings()
    }
    
    func getSettings() -> ExternalSscdSettings {
        return self.settings
    }
    
    
}
