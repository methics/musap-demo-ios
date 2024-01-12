//
//  ExternalSscdSettings.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 5.1.2024.
//

import Foundation

public class ExternalSscdSettings: SscdSettings {
    
    public static let SETTINGS_TIMEOUT   = "timeout"
    public static let SETTINGS_CLIENT_ID = "clientid"
    public static let SETTINGS_SSCD_NAME = "sscdname"
    
    private var settings: [String: String] = [:]
    private var timeout: TimeInterval
    
    init(timeout: TimeInterval, clientId: String) {
        self.timeout = timeout
        settings[ExternalSscdSettings.SETTINGS_TIMEOUT, default: ""]//TODO: Duration
        settings[ExternalSscdSettings.SETTINGS_CLIENT_ID, default: clientId]
    }
    
    public func setSscdName(name: String) {
        self.setSetting(key: ExternalSscdSettings.SETTINGS_SSCD_NAME, value: name)
    }
    
    public func getSscdName() -> String {
        guard let name = self.getSetting(forKey: ExternalSscdSettings.SETTINGS_SSCD_NAME) else {
            return "External Signature"
        }
        return name
    }
    
    public func getTimeout() -> TimeInterval {
        return self.timeout
    }
    
    public func getClientId() -> String? {
        guard let clientId = self.getSetting(forKey: ExternalSscdSettings.SETTINGS_CLIENT_ID) else {
            return nil
        }
        return clientId
    }
    
    func getSettings() -> [String : String]? {
        return ["": ""]
    }
    
    func getMusapLink() -> MusapLink? {
        return MusapClient.getMusapLink()
    }
    
    
    
}
