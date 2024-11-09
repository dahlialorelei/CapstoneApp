//
//  CameraCaptureView.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-08.
//

import SwiftUI
import AVFoundation

final class CameraCaptureView: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isImageCaptured = false
    @Published var capturedImage: UIImage?
    @Published var brightness: Float = 0.5
    @Published var focusDistance: Float = 0.5
    @Published var currentLens: String
    @Published var zoomFactor: CGFloat = 1.0 {  // Add zoom factor property
           didSet {
               applyZoom(zoomFactor)
           }
       }
    
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var selectedLens: String
    private var currentDevice: AVCaptureDevice?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    var videoMaxZoomFactor: CGFloat {
        return AVCaptureDevice.default(for: .video)?.activeFormat.videoMaxZoomFactor ?? 1.0
    }
    
    init(selectedLens: String) {
       self.selectedLens = selectedLens
       self.currentLens = selectedLens
       super.init()
       setupCamera()
   }
    /*
    override init() {
        super.init()
        setupCamera()
    }
     */
    
    private func applyZoom(_ factor: CGFloat) {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let minZoom: CGFloat = 1.0
        //let maxZoom = videoMaxZoomFactor
        //let maxZoom = videoDevice.activeFormat.videoMaxZoomFactor
        let maxZoom: CGFloat
        
        if videoDevice.deviceType == .builtInTelephotoCamera {
            maxZoom = min(3.0, videoDevice.activeFormat.videoMaxZoomFactor) // limit to 3x zoom for telephoto
        } else {
            maxZoom = videoMaxZoomFactor // Use default for other lenses
        }
        
        let zoomFactor = pow(maxZoom / minZoom, factor) * minZoom
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.videoZoomFactor = max(1.0, min(factor, videoDevice.activeFormat.videoMaxZoomFactor))  // Limit zoom within allowed range
            videoDevice.videoZoomFactor = zoomFactor
            videoDevice.unlockForConfiguration()
        } catch {
            print("Error setting zoom factor: \(error)")
        }
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
    
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Get the camera device based on the selected lens
        switch currentLens {
           case "Ultra Wide Lens":
               currentDevice = getCamera(ofType: .builtInUltraWideCamera)
           case "Wide Lens":
               currentDevice = getCamera(ofType: .builtInWideAngleCamera)
           case "Telephoto Lens":
               currentDevice = getCamera(ofType: .builtInTelephotoCamera)
           default:
               currentDevice = getCamera(ofType: .builtInWideAngleCamera)
           }
        
        /*
        // Get camera device based on selected zoom level (12mm, 24mm, 120mm)
        guard let videoDevice = getCamera(for: currentCameraPosition) else {
            print("No camera found for position \(currentCameraPosition)")
            return
        }
         */
        
        guard let videoDevice = currentDevice else {
           print("No camera found for selected lens")
           return
        }
        //currentDevice = videoDevice
        
        //guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            // Remove existing inputs before adding new one
            if let currentInput = captureSession.inputs.first {
                captureSession.removeInput(currentInput)
            }
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            }
            
            let photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                self.photoOutput = photoOutput
            }
            
            //self.captureSession = session
            captureSession.commitConfiguration()
            //captureSession.startRunning()
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning() // This will run in the background
            }
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    
    private func getCamera(ofType deviceType: AVCaptureDevice.DeviceType) -> AVCaptureDevice? {
            return AVCaptureDevice.DiscoverySession(
                deviceTypes: [deviceType],
                mediaType: .video,
                position: .back
            ).devices.first
        }
    
    /*
    private func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera],
                                                       mediaType: .video,
                                                       position: position).devices
        
        // Logic for selecting the desired lens (12mm, 24mm, 120mm)
        if let wideLens = devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) {
            return wideLens
        } else if let ultraWideLens = devices.first(where: { $0.deviceType == .builtInUltraWideCamera }) {
            return ultraWideLens
        } else if let telephotoLens = devices.first(where: { $0.deviceType == .builtInTelephotoCamera }) {
            return telephotoLens
        }
        return nil
    }
     */
    
    /*
        
    // Switch to the 12mm (ultra-wide) lens
    func switchToUltraWideLens() {
        stopSession()
        currentLens = "Ultra Wide Lens (12mm)"
        currentDevice = getCamera(for: .back) // Switch to ultra-wide lens
        setupCamera()
    }
    
    // Switch to the 24mm (wide) lens
    func switchToWideLens() {
        stopSession()
        currentLens = "Wide Lens (24mm)"
        currentDevice = getCamera(for: .back) // Switch to wide lens
        setupCamera()
    }
    
    // Switch to the 120mm (telephoto) lens
    func switchToTelephotoLens() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               if let telephotoLens = self.getCamera(for: .back), telephotoLens.deviceType == .builtInTelephotoCamera {
                   self.currentLens = "Telephoto Lens (120mm)"
                   self.currentDevice = telephotoLens
                   self.setupCamera()
                   print("Switched to Telephoto Lens (120mm) successfully.")
               } else {
                   print("Telephoto lens not available on this device or failed to configure.")
                   // Optional fallback to another lens or notify the user
                   self.currentLens = "Wide Lens (24mm)"
                   self.switchToWideLens()
               }
           }
    }
    */
    
    // Stop the capture session and remove the preview layer
   private func stopSession() {
       if let session = captureSession {
           session.stopRunning()
       if let currentInput = session.inputs.first {
           session.removeInput(currentInput)
       }
           
           // Remove the preview layer
           previewLayer?.removeFromSuperlayer()
       }
   }
    
    // Adjust the focus using the focus distance slider
    func setManualFocus(lensPosition: Float) {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            device.focusMode = .locked
            device.setFocusModeLocked(lensPosition: lensPosition) { time in
                print("Focus locked at position: \(lensPosition)")
                self.focusDistance = lensPosition
            }
            
            
            /*
            // Set the focus distance based on the slider value
            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            
            let focusPoint = CGPoint(x: focusDistance, y: 0.5)  // Adjust this for manual focus point
            device.focusPointOfInterest = focusPoint
            device.focusMode = .autoFocus
             */
            
            device.unlockForConfiguration()
        } catch {
            print("Error adjusting focus: \(error)")
        }
    }

    func capturePhoto() {
        guard let photoOutput = self.photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func handleCapturedImage(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        capturedImage = image
        isImageCaptured = true
    }

    func saveImageToCameraRoll() {
        guard let image = capturedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    func discardImage() {
        capturedImage = nil
        isImageCaptured = false
    }


    // AVCapturePhotoCaptureDelegate method
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            capturedImage = image
            isImageCaptured = true
        }
    }
}
