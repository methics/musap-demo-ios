//
//  ConfirmSignView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 2.11.2023.
//

import SwiftUI

struct ConfirmSignView: View {
    
    //TODO: pass from other views
    let signInput = "data to sign"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sign input")
                .font(.system(size: 12, weight: .semibold))
                .padding()
                .padding(.bottom, -25)
            
            Text(self.signInput)
                .padding()
            
            Button("Confirm Sign", action: self.confirmSignTapped)
                .buttonStyle(.borderedProminent)
                .padding()
            
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)

    }
    
    private func confirmSignTapped() {
        print("confirm sign tapped")
    }
}

#Preview {
    ConfirmSignView()
}
