//
//  LinkSigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 17.1.2024.
//

import SwiftUI

struct LinkSigningView: View {
    @State private var dtbd: String? = ""
    @State private var mode: String? = ""
    var payload: PollResponsePayload? // property that needs to be set when moving to LinkSigningView
    
    var body: some View {
        
        VStack {
            if let dtbd = dtbd {
                Text(dtbd)
                    .padding()
                Button("Sign") {
                    self.sendReq()
                }
                .padding()
                
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            self.mode = payload?.getMode()
            self.dtbd = payload?.getDisplayText()
        }
        
    }
    
    private func sendReq() {
        let sigReq = payload?.toSignatureReq(key: <#T##MusapKey#>)
        let sign = MusapClient.sign(req: <#T##SignatureReq#>, completion: <#T##(Result<MusapSignature, MusapError>) -> Void#>)
    }

}

