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
    @Published var zoomFactor: CGFloat = 1.0 {  // Add zoom factor property
           didSet {
               applyZoom(zoomFactor)
           }
       }
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var videoMaxZoomFactor: CGFloat {
        return AVCaptureDevice.default(for: .video)?.activeFormat.videoMaxZoomFactor ?? 1.0
    }
    
    private func applyZoom(_ factor: CGFloat) {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let minZoom: CGFloat = 1.0
        let maxZoom = videoMaxZoomFactor
        let zoomFactor = pow(maxZoom / minZoom, factor) * minZoom
        do {
            try videoDevice.lockForConfiguration()
           // videoDevice.videoZoomFactor = max(1.0, min(factor, videoDevice.activeFormat.videoMaxZoomFactor))  // Limit zoom within allowed range
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
        
        
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
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
            captureSession.startRunning()
            /*
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning() // This will run in the background
            }
             */
            
        } catch {
            print("Error setting up camera: \(error)")
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
