//
//  ConfirmSignView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct ConfirmSignView: View {
    
    var dataToBeSigned: String
    var musapKey: MusapKey?
    @State private var base64Signature: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sign input")
                .font(.system(size: 12, weight: .semibold))
                .padding()
                .padding(.bottom, -25)
            
            
            Text(self.dataToBeSigned)
                .padding()
            
            if (base64Signature != nil) {
                Text("base64 signature: ")
                    .font(.system(size: 18, weight: .regular))
                Text(base64Signature ?? "EMPTY")
                    .font(.system(size: 10, weight: .regular))
            }
            
            Button("Confirm Sign", action: self.confirmSignTapped)
                .buttonStyle(.borderedProminent)
                .padding()
            
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        
    }
    
    private func confirmSignTapped() {
        print("confirm sign tapped")
        
        guard let musapKey = self.musapKey else {
            print("MusapKey was nil, cant sign")
            return
        }
        
        guard let data = self.dataToBeSigned.data(using: .utf8) else {
            print("Couldnt turn self.dataTobeSigned to Data()")
            return
        }
        let algo = SignatureAlgorithm(algorithm: .ecdsaSignatureMessageX962SHA256)
        let signatureFormat = SignatureFormat("RAW")
        let sigReq = SignatureReq(key: musapKey, data: data, algorithm: algo, format: signatureFormat)
        
        Task {
            await MusapClient.sign(req: sigReq) { result in
                
                switch result {
                case .success(let musapSignature):
                    print("Success!")
                    print(" B64 signature: \(musapSignature.getB64Signature()) ")
                    base64Signature = musapSignature.getB64Signature()
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                }
            }
            
        }
        
    }
    
}

/*
#Preview {
    ConfirmSignView(dataToBeSigned: "")
}
*/
