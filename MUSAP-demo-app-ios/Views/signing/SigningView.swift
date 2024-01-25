//
//  SigningView.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 1.11.2023.
//

import SwiftUI

struct SigningView: View {
    
    @State private var selectedKey = ""
    @State private var dataToBeSigned: String? = nil
    @State private var isNextButtonDisabled = true
        
    let dtbsList = [
        "Sample string": "Sample text to sign",
        "Sample JWT": "THE JWT"
    ]

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            
            Text("Choose what to sign")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 30)
            
            Picker("Select value", selection: $selectedKey) {
                
                ForEach(Array(dtbsList.keys), id: \.self) { key in
                    Text(key).tag(key)
                }
                
            }
            .pickerStyle(DefaultPickerStyle())
            .padding()
            .onReceive([self.selectedKey].publisher.first(), perform: { (key) in
                self.dataToBeSigned = self.dtbsList[key]
                self.isNextButtonDisabled = (self.dataToBeSigned == nil)
            })
            
            
            
            NavigationLink(destination: ChooseKeyForSigningView(dataToBeSigned: self.dataToBeSigned)) {
                Text("Next")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .font(.headline)
            }
            
            
             
        }
        .onAppear {
            self.dataToBeSigned = dtbsList["Sample String"]
        }
    }
    
    private func nextButtonTapped() {
        print("selected key: \(selectedKey)")
        print("selected value: \(String(describing: dtbsList[selectedKey]))")
        
        // Send data to be signed forward
        self.dataToBeSigned = dtbsList[selectedKey]
        
        
    }}

#Preview {
    SigningView()
}
