//
//  CouplingView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 12.1.2024.
//

import SwiftUI

struct CouplingView: View {
    @State private var couplingCode: String = ""
    @State private var isCouplingSuccess: Bool = false
    @State private var isError: Bool = false
    @State private var errorMessage  = "Failed to couple."
    @State private var successMessage = ""
    
    var body: some View {
        TextField("Enter Coupling Code", text: $couplingCode)
            .padding()
            .border(Color.blue, width: 1)
        
        Button("Submit") {
            print("Submit pressed")
            sendCoupleReq()
        }
        .padding()
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
                    case .failure(let error):
                        self.isError = true
                        self.errorMessage = "Coupling failed"
                        print("musap error: \(error)")
                    }
                }
            }
        }
        
    }
}
