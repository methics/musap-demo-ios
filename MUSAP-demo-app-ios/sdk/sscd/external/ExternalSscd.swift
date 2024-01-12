//
//  ExternalSscd.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 5.1.2024.
//

import Foundation
import SwiftUI

/**
 * SSCD that uses MUSAP Link to request signatures with the "externalsign" Coupling API call
 */
public class ExternalSscd: MusapSscdProtocol {

    
    typealias CustomSscdSettings = ExternalSscdSettings
    
    static let SSCD_TYPE           = "External Signature"
    static let ATTRIBUTE_MSISDN    = "msisdn"
    static let SIGN_MSG_TYPE       = "externalsignature"
    private static let POLL_AMOUNT = 10
    
    private let clientId:  String
    private let settings:  ExternalSscdSettings
    private let musapLink: MusapLink
    
    init(settings: ExternalSscdSettings, clientId: String, musapLink: MusapLink) {
        self.settings = settings
        self.clientId = settings.getClientId() ?? ""
        self.musapLink = settings.getMusapLink()! //TODO: Dont use !
    }
    
    func bindKey(req: KeyBindReq) throws -> MusapKey {
        var request: ExternalSignaturePayload = ExternalSignaturePayload(clientId: self.clientId)
        
        var theMsisdn: String? = nil
        let msisdn = req.getAttribute(name: ExternalSscd.ATTRIBUTE_MSISDN)
        if msisdn == nil {
            ExternalSscd.showEnterMsisdnDialog { msisdn in
                print("Received MSISDN: \(msisdn)")
                theMsisdn = msisdn
            }
        } else {
            theMsisdn = msisdn
        }
        
        
        let data = "Bind Key".data(using: .utf8)
        guard let base64Data = data?.base64EncodedString(options: .lineLength64Characters) else {
            throw MusapError.internalError
        }
        
        
        request.data     = base64Data
        request.clientId = self.clientId
        request.display  = req.getDisplayText()
        request.format   = "CMS"
        request.attributes?[ExternalSscd.ATTRIBUTE_MSISDN] = theMsisdn
        
        do {
            var theKey: MusapKey?
            
            self.musapLink.sign(payload: request) { result in
                
                switch result {
                case .success(let response):
                    guard let publicKeyData = response.getPublicKey().data(using: .utf8) else {
                        print("Could not get public key in bindKey()")
                        return
                    }
                    
                    theKey =  MusapKey(
                        keyAlias: req.getKeyAlias(),
                        sscdType: ExternalSscd.SSCD_TYPE,
                        publicKey: PublicKey(publicKey: publicKeyData),
                        keyUri: KeyURI(name: req.getKeyAlias(), sscd: ExternalSscd.SSCD_TYPE, loa: "loa2") //TODO: What LoA?
                    )
                    
                case .failure(let error):
                    print("error while binding key: \(error)")
                }
                
            }
        
            guard let musapKey = theKey else {
                throw MusapError.internalError
            }
            
            return musapKey

        } catch {
            print("error: \(error)")
        }
        
        // If we get to here, some error happened
        throw MusapError.internalError
    }
    
    func generateKey(req: KeyGenReq) throws -> MusapKey {
        fatalError("Unsupported Operation")
    }
    
    func sign(req: SignatureReq) throws -> MusapSignature {
        var request = ExternalSignaturePayload(clientId: self.clientId)
        
        var theMsisdn: String? = nil // Eventually this gets set into the attributes
        
        let msisdn = req.getAttribute(name: ExternalSscd.ATTRIBUTE_MSISDN)
        if msisdn == nil {
            ExternalSscd.showEnterMsisdnDialog { msisdn in
                print("Received MSISDN: \(msisdn)")
                theMsisdn = msisdn
            }
        } else {
            theMsisdn = msisdn
        }
        
        let dataBase64 = req.getData().base64EncodedString(options: .lineLength64Characters)
        
        request.attributes?[ExternalSscd.ATTRIBUTE_MSISDN] = theMsisdn
        request.clientId = self.clientId
        request.display  = req.getDisplayText()
        request.format   = req.getFormat().getFormat()
        request.data     = dataBase64
        
        do {
            var theSignature: MusapSignature?
            self.musapLink.sign(payload: request) { result in
                
                switch result {
                case .success(let response):
                    
                    guard let rawSignature = response.getRawSignature() else {
                        return
                    }
                    
                    theSignature = MusapSignature(rawSignature: rawSignature)
                    
                case .failure(let error):
                    print("an error occured: \(error)")
                }
                
            }
            
            guard let signature = theSignature else {
                throw MusapError.internalError
            }
            
            return signature
            
        } catch {
            print("error in ExternalSscd.sign(): \(error)")
        }
        
        // If we got to here, some error happened
        throw MusapError.internalError
    }
    
    func getSscdInfo() -> MusapSscd {
        let sscd = MusapSscd(sscdName: self.settings.getSscdName(),
                             sscdType: ExternalSscd.SSCD_TYPE,
                             sscdId: "", //TODO: Fix
                             country: "FI",
                             provider: "MUSAP LINK",
                             keyGenSupported: false,
                             algorithms: [KeyAlgorithm.RSA_2K],
                             formats: [SignatureFormat.RAW, SignatureFormat.CMS]
        )
        return sscd
    }
    
    func generateSscdId(key: MusapKey) -> String {
        return ExternalSscd.SSCD_TYPE + "/" + (key.getAttributeValue(attrName: ExternalSscd.ATTRIBUTE_MSISDN) ?? "")
    }
    
    func isKeygenSupported() -> Bool {
        return false
    }
    
    func getSettings() -> [String : String]? {
        return self.settings.getSettings()
    }
    
    func getSettings() -> ExternalSscdSettings {
        return self.settings
    }
    
    
    /**
     Displays Enter MSISDN prompt for the user
     Usage:
     ExternalSscd.showEnterMsisdnDialog { msisdn in
         print("Received msisdn: \(msisdn)")
         // Handle the received msisdn
     }
     */
    private static func showEnterMsisdnDialog(completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene

            if let rootViewController = windowScene?.windows.first?.rootViewController {
                let msisdnInputView = MsisdnInputView { msisdn in
                    completion(msisdn)
                    rootViewController.dismiss(animated: true, completion: nil)
                }
                
                let hostingController = UIHostingController(rootView: msisdnInputView)

                hostingController.modalPresentationStyle = .fullScreen
                rootViewController.present(hostingController, animated: true, completion: nil)
            }
        }
    }
}
