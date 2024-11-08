//
//  ContentView.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-05.
//

import SwiftUI
//import FirebaseAuth

struct ContentView: View {
    //@State private var isAuthenticated = Auth.auth().currentUser != nil
    @State private var isAuthenticated = true  // Set to true to bypass login

    var body: some View {
        if isAuthenticated {
            //MainCaptureView(isAuthenticated: $isAuthenticated)
        } else {
            //SignInView(isAuthenticated: $isAuthenticated)
            //MainCaptureView(isAuthenticated: $isAuthenticated)
        }
    }
}


#Preview {
    ContentView()
}
