//
//  BindKeyView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 17.1.2024.
//

import SwiftUI
import musap_ios

struct BindKeyView: View {
    
    var payload: PollResponsePayload? = nil
    var mode: String? = "" // if is generate-sign, after generate, add poll button?
                           // if is generate, go to homeview?
    //var musapKeyFromBind: MusapKey? = nil
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var isKeyBinded = false
    
    @State private var musapKeyFromBind: MusapKey? = nil
    
    var body: some View {
        Text("You need to bind a key")
            .padding()
        Button("Start Binding") {
            self.bindKey()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Key Binding"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2)
        }
        
        if isKeyBinded {
            Button("Sign") {
                self.sign()
            }
        }
        
    }
    
    private func sign() {
        
        guard let musapKey = musapKeyFromBind else {
            return
        }
        guard let signatureReq = payload?.getSignaturePayload().toSignatureReq(key: musapKey) else {
            return
        }
        
        guard let transId = payload?.getTransId() else {
            return
        }
        
        Task {
            await MusapClient.sign(req: signatureReq) { result in
                switch result {
                case .success(let signature):
                    print("got signature: \(signature.getB64Signature())")
                    
                    MusapClient.sendSignatureCallback(signature: signature, txnId: transId)
                    
                case .failure(let error):
                    print("error: \(error)")
                }
                
            }
        }
        
        
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
            self.isLoading = true
            await MusapClient.bindKey(sscd: sscd, req: keyBindReq) { result in
            
                switch result {
                case .success(let musapKey):
                    print("musapKey: \(String(describing: musapKey.getKeyAlias()))")
                    alertMessage = "Key binding successful!"
                    showAlert    = true
                    isLoading    = false
                    isKeyBinded  = true
                    musapKeyFromBind     = musapKey
                case .failure(let error):
                    print("BindKeyView: error in bindkey: \(error)")
                    alertMessage = "Error in key binding: \(error.localizedDescription)"
                    showAlert    = true
                    isLoading    = false
                }
                
                
            }
        }

    }
    
}
