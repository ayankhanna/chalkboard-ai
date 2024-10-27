//
//  TakePhotoView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI

struct TakePhotoView: View {
    var className: String
    @State private var capturedImage: UIImage?
    @State private var captureAction: (() -> Void)?
    @State private var navigateToPhotoConfirm = false
    @State private var photoUploadUrl: String?
    @State private var isLoading = false // Loading state
    
    var body: some View {
        NavigationView {
            ZStack {
                CameraView(capturedImage: $capturedImage, onCapture: {
                    captureAndUploadPhoto()
                }, captureAction: $captureAction)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(className)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    Button(action: {
                        captureAction?()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.5), lineWidth: 3)
                            )
                    }
                    .padding(.bottom, 30)
                }
                
                if isLoading {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView("Uploading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                NavigationLink(destination: PhotoConfirmView(photoUrl: photoUploadUrl ?? "", className: className), isActive: $navigateToPhotoConfirm) {
                    EmptyView()
                }
            }
        }
    }
    
    private func captureAndUploadPhoto() {
        guard let image = capturedImage else { return }
        
        // Rotate the image 90 degrees counterclockwise
        guard let rotatedImage = rotateImage(image: image) else { return }
        
        guard let imageData = rotatedImage.jpegData(compressionQuality: 0.8) else { return }
        let fileName = UUID().uuidString + ".jpg"
        
        isLoading = true // Start loading
        
        Task {
            do {
                try await SupabaseService.shared.uploadPhoto(imageData: imageData, fileName: fileName)
                if let url = SupabaseService.shared.photoUploadUrl {
                    print("Photo uploaded successfully: \(url)")
                    DispatchQueue.main.async {
                        self.photoUploadUrl = url
                        self.navigateToPhotoConfirm = true
                    }
                }
            } catch {
                print("Failed to upload photo: \(error.localizedDescription)")
                // Handle the error (e.g., show an alert to the user)
            }
            
            DispatchQueue.main.async {
                self.isLoading = false // Stop loading
            }
        }
    }
    
    private func rotateImage(image: UIImage) -> UIImage? {
        let size = CGSize(width: image.size.height, height: image.size.width)
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Move the origin to the middle of the image so we can rotate around the center.
        context.translateBy(x: size.width / 2, y: size.height / 2)
        // Rotate the image context
        context.rotate(by: -.pi / 2)
        // Draw the image into the context
        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
