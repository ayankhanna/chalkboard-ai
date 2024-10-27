//
//  PhotoConfirmView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI

struct PhotoConfirmView: View {
    var photoUrl: String
    var className: String
    @State private var navigateToAnalyzing = false
    
    var body: some View {
        VStack {
            if let url = URL(string: photoUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    case .failure:
                        Text("Failed to load image")
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("Invalid image URL")
            }
            
            Spacer()
            
            Button(action: {
                navigateToAnalyzing = true
            }) {
                Text("Looks Good!")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
            .padding()
            
            NavigationLink(destination: AnalyzingView(photoUploadUrl: photoUrl, className: className), isActive: $navigateToAnalyzing) {
                EmptyView()
            }
            .isDetailLink(false) // Ensures no back button
        }
        .navigationBarTitle("Photo Confirmation", displayMode: .inline)
    }
}
