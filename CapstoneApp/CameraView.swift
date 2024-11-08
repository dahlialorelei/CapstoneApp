//
//  CameraView.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-05.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImages: [UIImage]

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.capturedImages = $capturedImages
        vc.setupCamera()
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var capturedImages: Binding<[UIImage]>?
    private var captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    @Published var isImageCaptured = false
    @Published var capturedImage: UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            captureSession.startRunning()

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)
        } catch {
            print("Camera setup error: \(error)")
        }
    }

    /*
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    */
    
    func capturePhoto() {
        //guard let photoOutput = self.photoOutput else { return }
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
    /*
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            capturedImages?.wrappedValue.append(image)
        }
    }
     */
}
