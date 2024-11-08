//
//  MainCaptureView.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-05.
//


import SwiftUI

struct MainCaptureView: View {
    @Binding var isAuthenticated: Bool
    @State private var isSessionActive = false
    @State private var capturedImages = [UIImage]()

    var body: some View {
        VStack {
            CameraView(capturedImages: $capturedImages)
                .frame(height: UIScreen.main.bounds.height * 0.6)

            FlashlightControl()  // Flashlight brightness control

            HStack {
                Button("Capture") {
                    // Capture image function here
                    //cameraCapture.capturePhoto()
                }
                .padding()
                
                Button("End Session") {
                    endSession()
                }
                .padding()
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(capturedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                }
            }
            
            Button("Sign Out") {
                //try? Auth.auth().signOut()
                isAuthenticated = false
            }
            .padding(.top)
        }
    }

    private func endSession() {
        isSessionActive = false
        capturedImages.removeAll()
    }
}
