//
//  ExternalSscd.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 5.1.2024.
//

import Foundation
import SwiftUI
import Security

/**
 * SSCD that uses MUSAP Link to request signatures with the "externalsign" Coupling API call
 */
public class ExternalSscd: MusapSscdProtocol {

    typealias CustomSscdSettings = ExternalSscdSettings
    
    static let SSCD_TYPE           = "External Signature"
    static let ATTRIBUTE_MSISDN    = "msisdn"
    static let SIGN_MSG_TYPE       = "externalsignature"
    private static let POLL_AMOUNT = 10
    
    private let clientid:  String
    private let settings:  ExternalSscdSettings
    private let musapLink: MusapLink
    
    init(settings: ExternalSscdSettings, clientid: String, musapLink: MusapLink) {
        self.settings = settings
        self.clientid = settings.getClientId() ?? "LOCAL"
        self.musapLink = settings.getMusapLink()! //TODO: Dont use !
    }
    
    func bindKey(req: KeyBindReq) throws -> MusapKey {
        print("ExternalSscd.bindKey() started")
        let request: ExternalSignaturePayload = ExternalSignaturePayload(clientid: self.clientid)
        
        var theMsisdn: String? = nil
        let msisdn = req.getAttribute(name: ExternalSscd.ATTRIBUTE_MSISDN)
        
        let semaphore = DispatchSemaphore(value: 0)
        if msisdn == nil {
            ExternalSscd.showEnterMsisdnDialog { msisdn in
                print("Received MSISDN: \(msisdn)")
                theMsisdn = msisdn
                semaphore.signal()
            }
        } else {
            theMsisdn = msisdn
        }
        
        semaphore.wait()
        
        let data = "Bind Key".data(using: .utf8)
        guard let base64Data = data?.base64EncodedString(options: .lineLength64Characters) else {
            throw MusapError.internalError
        }
        
        request.data     = base64Data
        request.clientid = self.clientid
        request.display  = req.getDisplayText()
        request.format   = "RAW"
        
        if request.attributes == nil {
            request.attributes = [String: String]()
        }
        
        request.attributes?[ExternalSscd.ATTRIBUTE_MSISDN] = theMsisdn
        
        do {
            var theKey: MusapKey?
            
            let signSemaphore = DispatchSemaphore(value: 0)
            print("Starting sign for key bind")
            self.musapLink.sign(payload: request) { result in
                
                switch result {
                case .success(let response):
                    
                    guard let signature = response.signature else {
                        print("no signature")
                        return
                    }
                    
                    print("the signature: \(signature)")
                    
                    guard let certData = Data(base64Encoded: signature) else {
                        print("unable to create Data() from signature")
                        return
                    }
                    
                    guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
                        print("unable to create certificate")
                        return
                    }
                    
                    guard let publicKey = MusapCertificate(cert: certificate)?.getPublicKey().getDER() else {
                        print("bad publickey")
                        return
                    }
                    /*
                    guard let publicKeyData = publicKey.data(using: .utf8) else {
                        print("Could not get public key in bindKey()")
                        return
                    }
                     */
                    //TODO: Get pubkey etc from LINK response instead after backend updates
                    print("Succesfully signed and got public keye")
                    
                    theKey =  MusapKey(
                        keyAlias: req.getKeyAlias(),
                        sscdType: ExternalSscd.SSCD_TYPE,
                        publicKey: PublicKey(publicKey: publicKey),
                        keyUri: KeyURI(name: req.getKeyAlias(), sscd: ExternalSscd.SSCD_TYPE, loa: "loa2") //TODO: What LoA?
                    )
                    theKey?.addAttribute(attr: KeyAttribute(name: ExternalSscd.ATTRIBUTE_MSISDN, value: theMsisdn))
                    
                case .failure(let error):
                    print("bindKey()->musapLink->sign() error while binding key: \(error)")
    
                }
                signSemaphore.signal()
            }
            signSemaphore.wait()
        
            guard let musapKey = theKey else {
                print("ExternalSscd.bindKey() - ERROR: No MUSAP KEY")
                throw MusapError.internalError
            }
            
            print("RETURNING MUSAP KEY \(musapKey.getPublicKey())")
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
        let request = ExternalSignaturePayload(clientid: self.clientid)
        
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
        request.clientid = self.clientid
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
