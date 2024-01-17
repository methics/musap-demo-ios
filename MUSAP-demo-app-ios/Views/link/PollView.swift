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
    
    var body: some View {
        Text("MUSAP Link is active")
            .padding()
        Button("Poll") {
            self.sendPollReq()
        }
        .padding()
        
        NavigationLink(destination: LinkSigningView(payload: self.payload), isActive: $showSignView) {
            
        }
        
    }
    
    func sendPollReq() {
        print("Sending POLL")
        
        
        Task {
            await MusapClient.pollLink() { result in
                switch result {
                case .success(let payload):
                    print("Successfully polled Link")
                    self.payload = payload
                    self.showSignView = true
                case .failure(let error):
                    print("Error in pollLink: \(error)")
                }
                
            }
        }
        
    }
    
}
