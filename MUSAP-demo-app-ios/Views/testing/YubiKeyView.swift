//
//  YubiKeyView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 30.11.2023.
//e

import SwiftUI
import YubiKit

struct YubiKeyView: View {
    
    let yubiKeyConnection = YubiKeyConnection()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                yubiKeyConnection.connection { connection in
                    
                    if let accessoryConnection = yubiKeyConnection.accessoryConnection {
                        print("Connected to yubikey via accessory")
                    } else if let nfcConnection = yubiKeyConnection.nfcConnection {
                        print("Connected to yubikey via NFC")
                        nfcConnection.pivSession { session, error in
                            guard let session = session else {
                                print("ERROR IN GETTING SESSION")
                                return
                            }
                            
                            let managementKey = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
                            
                            session.authenticate(withManagementKey: managementKey, type: .tripleDES()) { error in
                                
                                guard error == nil else {
                                    print("Error in authentication: \(String(describing: error))")
                                    return
                                }
                                
                                print("Authenticated successfully!")
                                
                                session.generateKey(in: .signature, type: .ECCP256) { publicKey, error in
                                    session.verifyPin("123456", completion: { retries, error in
                                        
                                        if error != nil {
                                            print("error in verifyPin: \(String(describing: error))")
                                        }
                                        
                                    })
                                    
                                    if publicKey != nil {
                                        print("PublicKey: \(String(describing: publicKey))")
                                    }
                                    
                                    if error != nil {
                                        print("error in generate key: \(String(describing: error))")
                                    }
                                    
                                    
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }
            }
    }
    
}
