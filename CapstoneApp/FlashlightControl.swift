//
//  FlashlightControl.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-05.
//

import SwiftUI
import AVFoundation

struct FlashlightControl: View {
    @State private var brightness: Float = 0.5

    var body: some View {
        VStack {
            Slider(value: $brightness, in: 0.01...1, step: 0.1) {
                Text("Adjust Flashlight Brightness")
            }.onChange(of: brightness) { _ in
                setTorchLevel(level: brightness)
            }
        }
        .padding()
    }

    func setTorchLevel(level: Float) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        if device.deviceType == .builtInTelephotoCamera {
            return
        }
        
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: level)
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
}
