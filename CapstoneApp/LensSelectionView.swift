//
//  LensSelectionView.swift
//  CapstoneApp
//
//  Created by Dahlia Taylor on 2024-11-09.
//

// LensSelectionView.swift

// LensSelectionView.swift

import SwiftUI

struct LensSelectionView: View {
    // This property will store the selected lens type
    @State private var selectedLens: String = "Wide Lens"
    
    // This flag will track whether to navigate to the camera
    @State private var navigateToCamera = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select a Lens")
                    .font(.title)
                    .padding()
                
                Button("Ultra Wide (12mm)") {
                    selectedLens = "Ultra Wide Lens"
                    navigateToCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Wide (24mm)") {
                    selectedLens = "Wide Lens"
                    navigateToCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Telephoto (120mm)") {
                    selectedLens = "Telephoto Lens"
                    navigateToCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            // Use navigationDestination to define the destination view when navigateToCamera is true
            .navigationDestination(isPresented: $navigateToCamera) {
                CameraViewWrapper(selectedLens: selectedLens)
            }
        }
    }
}
