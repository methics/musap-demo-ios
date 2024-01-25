//
//  CouplingView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 12.1.2024.
//

import SwiftUI
import musap_ios

struct CouplingView: View {
    @State private var couplingCode: String = ""
    @State private var isCouplingSuccess: Bool = false
    @State private var isError: Bool  = false
    @State private var errorMessage   = "Failed to couple."
    @State private var successMessage = ""
    @State private var showPollView   = false
    
    var body: some View {
        VStack {
            Text("Enter Coupling Code")
                .padding()
                .font(.headline)
            
            Text("You can get the coupling code from relying party website")
                .padding()
                .font(.subheadline)

            TextField("Enter Coupling Code", text: $couplingCode)
                .padding()
                .border(Color.blue, width: 1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.1) // 10% padding on each side
            
            Button("Submit") {
                print("Submit pressed")
                sendCoupleReq()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .font(.headline)
            
            .alert(isPresented: $isCouplingSuccess) {
                Alert(
                    title: Text("Successfully coupled!"),
                    message: Text(successMessage),
                    dismissButton: .default(Text("OK"), action: {
                        self.isCouplingSuccess = false
                    })
                )
            }
            .alert(isPresented: $isError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"), action: {
                        self.isError = false
                    })
                )
            }
            
            NavigationLink(destination: LinkStatusView(), isActive: $showPollView) {
                
            }
            .onAppear {
                isCoupledAlready()
            }
        }

    
        
    }
    
    func sendCoupleReq() {
        let theCode = couplingCode
        print("THe code: \(theCode)")
        
        Task {
            await MusapClient.coupleWithRelyingParty(couplingCode: theCode) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let rp):
                        print("Coupling OK: RP name: \(rp.getName())  linkid: \(rp.getLinkId())")
                        self.successMessage = "Link ID: \(rp.getLinkId())"
                        self.isCouplingSuccess = true
                        self.showPollView = true
                        
                    case .failure(let error):
                        self.isError = true
                        self.errorMessage = "Coupling failed"
                        print("musap error: \(error)")
                    }
                }
            }
        }
    }
    
    func isCoupledAlready() {
        guard MusapClient.listRelyingParties() != nil else {
            return
        }
        
        self.showPollView = true
    }
    
}
