//
//  BindKeyView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 17.1.2024.
//

import SwiftUI

struct BindKeyView: View {
    
    var payload: PollResponsePayload? = nil
    var mode: String? = "" // if is generate-sign, after generate, add poll button?
                           // if is generate, go to homeview?
    
    var body: some View {
        Text("You need to bind a key")
            .padding()
        Button("Start Binding") {
            self.bindKey()
        }
        .padding()
    }
    
    private func bindKey() {
        print("starting key binding")
        
        print("MODE: \(String(describing: mode))")
        guard let dtbd = self.payload?.getDisplayText() else {
            print("no dtbd")
            return
        }
        
        guard let link = MusapClient.getMusapLink() else {
            print("NO link")
            return
        }
        
        print("getting settings")
        let settings = ExternalSscdSettings(clientId: "1")
        
        print("getting externalSSCD")
        let sscd = ExternalSscd(settings: settings, clientid: "1", musapLink: link)
        

        print("Creating key bind req")
        let keyBindReq = KeyBindReq(
            keyAlias: "keyForMusap",
            did: "",
            role: "",
            stepUpPolicy: StepUpPolicy(),
            attributes: [KeyAttribute](),
            generateNewKey: true,
            displayText: "Bind key to MUSAP"
        )
        
        Task {
            await MusapClient.bindKey(sscd: sscd, req: keyBindReq) { result in
                
                print("Do we run this")
                switch result {
                case .success(let musapKey):
                    print("musapKey: \(String(describing: musapKey.getKeyAlias()))")
                case .failure(let error):
                    print("BindKeyView: error in bindkey: \(error)")
                }
                
                
            }
        }

    }
    
}
