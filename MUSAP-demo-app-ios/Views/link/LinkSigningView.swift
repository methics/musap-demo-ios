//
//  LinkSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 17.1.2024.
//

import SwiftUI

struct LinkSigningView: View {
    @State private var dtbd: String? = ""
    
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
        }
        
        if mode == PollResponsePayload.MODE_GENONLY {
            // Display Generate key only UI
            Text("GENERATE ONLY")
        }
        
        if mode == PollResponsePayload.MODE_GENSIGN {
            // Display generate and then sign UI
            Text("GENERATE and SIGN")
        }
    
    }
    
    private func sendSignReq() {
        if mode == PollResponsePayload.MODE_SIGN {
            //let signaturePayload = payload?.getSignaturePayload().toSignatureReq(key: <#T##MusapKey#>)
            
            guard let sscds = MusapClient.listEnabledSscds() else {
                print("NO enabled sscds")
                return
            }
            
            var theSscd: any MusapSscdProtocol
            for sscd in sscds {
                if sscd.getSscdInfo().sscdType == "External Signature" {
                    theSscd = sscd
                }
                                
            }
            
            
            Task {
                //MusapClient.sign(req: <#T##SignatureReq#>, completion: <#T##(Result<MusapSignature, MusapError>) -> Void#>)

            }
             
            
            
        }
        
    }
    
}

