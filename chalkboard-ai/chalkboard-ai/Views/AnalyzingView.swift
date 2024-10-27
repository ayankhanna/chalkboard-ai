//
//  AnalyzingView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI
import Combine

struct AnalyzingView: View {
    let photoUploadUrl: String
    let className: String

    @State private var animationOffset: CGFloat = 0
    @State private var currentMessageIndex = 0
    @State private var messageTimer: AnyCancellable?
    @State private var messages = [
        "Analyzing the image...",
        "Looking for your course...",
        "Reading the syllabus...",
        "Finalizing...."
    ]
    @State private var navigateToResultsView = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(messages[currentMessageIndex])
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    ZStack {
                        if let url = URL(string: photoUploadUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                            }
                        } else {
                            Text("Invalid URL")
                                .foregroundColor(.red)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                        }

                        Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: geometry.size.width, height: 4)
                            .offset(y: animationOffset)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                    .clipped()

                    Spacer()
                }
            }
            .onAppear {
                startAnimation(height: geometry.size.height * 0.7)
                startMessageRotation()
                analyzeImage()
            }
            .onDisappear {
                messageTimer?.cancel()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: ResultsView(), isActive: $navigateToResultsView) {
                EmptyView()
            }
        )
    }

    private func startAnimation(height: CGFloat) {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            animationOffset = height / 2
        }
    }

    private func startMessageRotation() {
        messageTimer = Timer.publish(every: 4, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if currentMessageIndex < messages.count - 1 {
                    currentMessageIndex += 1
                } else {
                    messageTimer?.cancel()
                }
            }
    }

    private func analyzeImage() {
        let apiService = APIService() // Create an instance of APIService
        if let photoApiInput = SupabaseService.shared.photoApiInput {
            print("Using photoApiInput: \(photoApiInput)")
            apiService.analyzeImage(className: className, imageUrl: photoApiInput) { result in
                switch result {
                case .success:
                    print("analyzeImage completed successfully")
                    navigateToResultsView = true
                case .failure(let error):
                    print("analyzeImage failed with error: \(error)")
                }
            }
        } else {
            print("photoApiInput is nil")
        }
    }
}

struct AnalyzingView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzingView(photoUploadUrl: "https://example.com/image.jpg", className: "Sample Class")
    }
}
