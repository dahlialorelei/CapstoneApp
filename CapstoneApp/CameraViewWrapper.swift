//
//  CameraViewWrapper.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-08.
//

import SwiftUI
import AVFoundation

struct CameraViewWrapper: View {
    let selectedLens: String
    //@StateObject private var cameraCapture = CameraCaptureView() // Create an instance of CameraCaptureView
    // Initialize CameraCaptureView with the selected lens
    @StateObject private var cameraCapture: CameraCaptureView
    
    init(selectedLens: String) {
        self.selectedLens = selectedLens
        _cameraCapture = StateObject(wrappedValue: CameraCaptureView(selectedLens: selectedLens))
    }
    @State private var focusDistance: Float = 0.5
    
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
                
                //Slider(value: $cameraCapture.zoomFactor, in: 1.0...cameraCapture.videoMaxZoomFactor)
                Slider(value: $cameraCapture.zoomFactor, in: 0.0...1.0)
                    .padding()
                
                Text("Focus Distance: \(cameraCapture.focusDistance, specifier: "%.2f")")
                    .padding()
                
                Slider(value: $focusDistance, in: 0.0...1.0)
                    .onChange(of: focusDistance) { newValue in
                    cameraCapture.setManualFocus(lensPosition: newValue)
                }
                /*
                HStack {
                    // Individual buttons for each lens
                    Button("Ultra Wide (12mm)") {
                        cameraCapture.switchToUltraWideLens()
                    }
                    Button("Wide (24mm)") {
                        cameraCapture.switchToWideLens()
                    }
                    Button("Telephoto (120mm)") {
                        cameraCapture.switchToTelephotoLens()
                    }
                }
                 */
                
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
