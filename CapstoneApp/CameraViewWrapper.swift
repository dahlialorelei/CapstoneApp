//
//  CameraViewWrapper.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-08.
//

import SwiftUI
import AVFoundation

struct CameraViewWrapper: View {
    @StateObject private var cameraCapture = CameraCaptureView() // Create an instance of CameraCaptureView

    var body: some View {
        VStack {
            if let image = cameraCapture.capturedImage, cameraCapture.isImageCaptured {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                
                
                HStack {
                    Button("Discard") {
                        cameraCapture.discardImage()
                    }
                    Button("Save") {
                        cameraCapture.saveImageToCameraRoll()
                    }
                }
            } else {
                CameraPreviewView(session: $cameraCapture.captureSession)
                    //.frame(height: 300)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                FlashlightControl()  // Flashlight brightness control
                
                Button("Capture Photo") {
                    cameraCapture.capturePhoto()
                }
            }
        }
        .onAppear {
            if cameraCapture.captureSession == nil {
                cameraCapture.setupCamera() // Setup camera only if session is nil
            }
        }
    }
}
