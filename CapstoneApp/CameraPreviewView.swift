//
//  CameraPreviewView.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-08.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @Binding var session: AVCaptureSession?
   // @Binding var capturedImages: [UIImage]

    /*
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        //vc.capturedImages = $capturedImages
        vc.setupCamera()
        return vc
    }
     */

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            //previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.main.async {
                previewLayer.frame = view.bounds 
                session.startRunning() // Start the session
            }
            
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
            // Make sure the preview layer is updated when the session is set
            if let session = session, let previewLayer = uiView.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
                previewLayer.session = session // Bind the session to the preview layer
                previewLayer.frame = uiView.bounds // Update layer bounds in case the view changes size
            }
        }
}
