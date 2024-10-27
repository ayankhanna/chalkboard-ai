//
//  LandingPageView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI

struct LandingPageView: View {
    @State private var selectedClass: String = ""
    @State public var arePhotoButtonsEnabled: Bool = false
    @State public var className: String = "SELECT YOUR CLASS HERE"
    @State private var isPhotoPickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var navigateToAnalyzingView = false
    @State public var photoUploadUrl: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                NavigationLink(destination: ClassSelectionView(onClassSelected: { selectedClass in
                    self.className = selectedClass
                })) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black) // Set icon color to black
                        Text(className)
                            .foregroundColor(.black) // Set text color to black
                    }
                    .padding()
                    .background(Color.white) // Set button background to white
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        isPhotoPickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Upload Photo")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white) // Set text color to white
                    .cornerRadius(10)
                    .padding(.horizontal, 80)
                    .disabled(!arePhotoButtonsEnabled)
                    .opacity(arePhotoButtonsEnabled ? 1.0 : 0.5)
                    .sheet(isPresented: $isPhotoPickerPresented) {
                        PhotoPicker(selectedImage: $selectedImage)
                            .onDisappear {
                                if let image = selectedImage {
                                    uploadPhoto(image: image)
                                }
                            }
                    }
                    
                    Button(action: {
                        // Action for take picture
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Picture")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white) // Set text color to white
                    .cornerRadius(10)
                    .padding(.horizontal, 80)
                    .disabled(!arePhotoButtonsEnabled)
                    .opacity(arePhotoButtonsEnabled ? 1.0 : 0.5)
                }
                
                Spacer()
                
                // NavigationLink to AnalyzingView with photoUploadUrl
                NavigationLink(destination: AnalyzingView(photoUploadUrl: photoUploadUrl ?? "", className: className), isActive: $navigateToAnalyzingView) {
                    EmptyView()
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Set entire background to black
            .onChange(of: className) { newValue in
                arePhotoButtonsEnabled = (newValue != "SELECT YOUR CLASS HERE")
            }
        }
    }
    
    private func uploadPhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let fileName = UUID().uuidString + ".jpg"
        
        Task {
            do {
                try await SupabaseService.shared.uploadPhoto(imageData: imageData, fileName: fileName)
                print("Photo uploaded successfully")
                // Set the photoUploadUrl from the SupabaseService
                photoUploadUrl = SupabaseService.shared.photoUploadUrl
                print("photoUploadUrl set to: \(photoUploadUrl ?? "No URL")") // Debugging print statement
                // Navigate to AnalyzingView after successful upload
                navigateToAnalyzingView = true
            } catch {
                print("Failed to upload photo: \(error)")
            }
        }
    }
}

#Preview {
    LandingPageView()
}
