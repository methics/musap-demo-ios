//
//  PollView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 17.1.2024.
//

import SwiftUI

struct PollView: View {
    @State private var payload: PollResponsePayload? = nil
    @State private var showSignView = false
    @State private var showBindKeyView = false
    
    var body: some View {
        Text("MUSAP Link is active")
            .padding()
        Button("Poll") {
            self.sendPollReq()
        }
        .padding()
        
        // MODE = generate-sign or generate-only
        NavigationLink(destination: BindKeyView(payload: self.payload, mode: payload?.getMode()), isActive: $showBindKeyView) {
            
        }
        /*
        //TODO: Decide where to send the user by payload.getMode()
        NavigationLink(destination: LinkSigningView(payload: self.payload, mode: self.payload?.getMode()), isActive: $showSignView) {
            
        }
         */
        

        
    }
    
    func sendPollReq() {
        print("Sending POLL")
        
        
        Task {
            await MusapClient.pollLink() { result in
                switch result {
                case .success(let payload):
                    print("Successfully polled Link")
                    self.payload = payload
                    
                    let mode = payload.getMode()
                    
                    switch mode {
                    case "sign":
                        print("Sign only")
                        self.showSignView = true
                    case "generate-sign":
                        print("Generate and sign")
                        self.showBindKeyView = true
                    case "generate-only":
                        print("Generate only")
                        self.showBindKeyView = true
                    default:
                        break
                    }
                    
                    self.showSignView = true
                case .failure(let error):
                    print("Error in pollLink: \(error)")
                }
                
            }
        }
        
    }
    
}
