//
//  CouplingView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 12.1.2024.
//

import SwiftUI

struct CouplingView: View {
    @State private var couplingCode: String = ""
    
    var body: some View {
        TextField("Enter Coupling Code", text: $couplingCode)
            .padding()
            .border(Color.blue, width: 1)
        
        Button("Submit") {
            print("Submit pressed")
        }
        .padding()
    }
    
    func getCouplingCode() {
        
    }
}
