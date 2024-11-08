//
//  CapstoneAppApp.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-05.
//

import SwiftUI

@main
struct CapstoneAppApp: App {
    var body: some Scene {
        WindowGroup {
            CameraViewWrapper()
            //MainCaptureView(isAuthenticated: .constant(true))
            //MainCaptureView()
        }
    }
}
