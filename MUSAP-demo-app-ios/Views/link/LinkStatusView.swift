//
//  LinkStatusView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 25.1.2024.
//

import SwiftUI
import musap_ios

struct LinkStatusView: View {
    @State private var linkStatus:         String = "Inactive"
    @State private var isLinkEnabledState: Bool   = false
    @State private var isCoupled:          Bool   = false
    
    @State private var showSignView    = false
    @State private var showBindKeyView = false
    @State private var showCoupleView  = false
    
    @State private var payload: PollResponsePayload? = nil
    
    var body: some View {
        VStack {
            Text("MUSAP Link")
                .padding()
                .font(.system(size: 24, weight: .heavy))
            
            if isLinkEnabledState {
                
                if !isCoupled {
                    Text("Enabled, ready to couple")
                        .foregroundColor(.blue)
                        .padding()
                    
                    Button("Start Coupling") {
                        showCoupleView = true
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    Text("LINK is coupled. Ready to generate keys and sign.")
                        .foregroundColor(.green)
                        .padding()
                    
                    Button("Poll") {
                        self.sendPollReq()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                
            } else {
                Text("Not in use")
                    .foregroundColor(.red)
                    .padding()
                
                NavigationLink(destination: CouplingView()) {
                    Text("Couple with MUSAP Link")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                            
            }
            
            // MODE = generate-sign or generate-only
            NavigationLink(destination: BindKeyView(payload: self.payload, mode: payload?.getMode()), isActive: $showBindKeyView) {
                
            }

            NavigationLink(destination: LinkSigningView(payload: self.payload, mode: self.payload?.getMode()), isActive: $showSignView) {
                
            }
            
            NavigationLink(destination: CouplingView(), isActive: $showCoupleView) {
                
            }
        }
        .onAppear {
            isCoupledAlready()
            isLinkEnabledState = isLinkEnabled()
        }
        
    }
    
    func isCoupledAlready() {
        guard MusapClient.listRelyingParties() != nil else {
            // fire an alert?
            isCoupled = false
            return
        }
        
        isCoupled = true
        print("Link is coupled.")
        
    }
    
    func isLinkEnabled() -> Bool {
        return MusapClient.isLinkEnabled()
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
                    
                case .failure(let error):
                    print("Error in pollLink: \(error)")
                }
                
            }
        }
        
    }
}
