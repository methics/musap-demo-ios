//
//  LinkSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 17.1.2024.
//

import SwiftUI
import musap_ios

struct LinkSigningView: View {
    @State private var dtbd: String? = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var payload: PollResponsePayload? // property that needs to be set when moving to LinkSigningView
    var mode: String? = ""
    
    var body: some View {
        if mode == PollResponsePayload.MODE_SIGN {
            VStack {
                if let dtbd = dtbd {
                    Text(dtbd)
                        .padding()
                    Button("Sign") {
                        self.sendSignReq()
                    }
                    .padding()
                    
                } else {
                    Text("Loading...")
                }
            }
            .onAppear {
                self.dtbd = payload?.getDisplayText()
            }        
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    
    }
    
    private func sendSignReq() {
        if mode == PollResponsePayload.MODE_SIGN {
            
            print("starting signing")
 
            guard let sscds = MusapClient.listEnabledSscds() else {
                print("NO enabled sscds")
                return
            }
            
            var theSscd: (any MusapSscdProtocol)?
            for sscd in sscds {
                if sscd.getSscdInfo().sscdType == "External Signature" {
                    print("Found external signature sscd")
                    theSscd = sscd
                }
                
                print("Provider:")
                print(sscd.getSscdInfo().provider)
                                
            }
            
            if let sscdType = theSscd?.getSscdInfo().sscdType {
                print("Search req")
                let req = KeySearchReq(sscdType: sscdType)
                let keys = MusapClient.listKeys()
                
                print("list keys done")
                
                var musapKey: MusapKey?
                for key in keys {
                    print("key: \(key.getKeyAlias())")
                    print("\(String(describing: key.getSscdType())) vs. \(sscdType)")
                    if key.getSscdType() == sscdType {
                        print("key set")
                        musapKey = key
                    }
                }
                
                guard let theKey = musapKey else {
                    print("musap key was nil")
                    return
                }
                
                print("getting signatureReq from signaturePayload")
                guard let signatureReq = payload?.getSignaturePayload().toSignatureReq(key: theKey) else {
                    print("failed to get signatureReq")
                    return
                }
                guard let transId = payload?.getTransId() else {
                    print("NO Transid")
                    return
                }
                //signatureReq.setTransId(transId: transId)

                Task {
                    await MusapClient.sign(req: signatureReq) { result in
                        
                        switch result {
                        case .success(let signature):
                            print("signature: \(signature.getB64Signature())")
                            alertTitle = "Success"
                            alertMessage = "Signature: \(signature.getB64Signature())"
                            showAlert = true
                            
                            MusapClient.sendSignatureCallback(signature: signature, txnId: transId)
                            
                        case .failure(let error):
                            alertTitle = "Error"
                            alertMessage = "Error in LinkSigningView: \(error)"
                            showAlert = true
                            print("error in LinkSigningView: \(error)")
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
}

