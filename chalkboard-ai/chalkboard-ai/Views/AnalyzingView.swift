//
//  AnalyzingView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI
import Combine
import Foundation

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
    @State private var rawApiResponse: String? // Variable to store raw API response

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ZStack {
                        if let url = URL(string: photoUploadUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width*0.9, height: geometry.size.height * 0.3)
                                    .clipped()
                                    .border(Color.blue, width: 2)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: geometry.size.width*0.9, height: geometry.size.height * 0.3)
                                    .border(Color.blue, width: 2)
                                    .offset(y: (geometry.size.height * 0.15))
                            }
                        } else {
                            Text("Invalid URL")
                                .foregroundColor(.red)
                                .frame(width: geometry.size.width*0.9, height: geometry.size.height * 0.3)
                                .border(Color.blue, width: 2)
                                .offset(y: (geometry.size.height * 0.15))
                        }

                        Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: geometry.size.width, height: 4)
                            .offset(y: animationOffset)
                            .offset(y: (geometry.size.height * 0.15))
                    }
                    .frame(width: geometry.size.width*0.9, height: geometry.size.height * 0.3)
                    .clipped()
                    Spacer()
                    Text(messages[currentMessageIndex])
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 20)
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
            NavigationLink(destination: ResultsView(rawApiResponse: rawApiResponse ?? ""), isActive: $navigateToResultsView) {
                EmptyView()
            }
        )
    }

    private func startAnimation(height: CGFloat) {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
            animationOffset = height
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
                case .success(let rawResponseString):
                    print("Raw response data: \(rawResponseString)")
                    rawApiResponse = rawResponseString
                    
                    // Ensure UI updates are on the main thread
                    DispatchQueue.main.async {
                        navigateToResultsView = true
                    }
                    
                case .failure(let error):
                    print("analyzeImage failed with error: \(error)")
                }
            }
        } else {
            print("photoApiInput is nil")
        }
    }
}

// struct AnalyzingView_Previews: PreviewProvider {
//     static var previews: some View {
//         AnalyzingView(photoUploadUrl: "https://example.com/image.jpg", className: "Sample Class")
//     }
// }

// struct AnalyzeImageResponse: Codable {
//     struct Topic: Codable {
//         let title: String
//         let detail: String
//     }
    
//     struct BoardContent: Codable {
//         let topic1: Topic
//     }
    
//     struct Prereq: Codable {
//         let title: String
//         let detail: String
//     }
    
//     struct Future: Codable {
//         let title: String
//         let detail: String
//     }
    
//     let boardContent: BoardContent
//     let prereqs: [String: Prereq]
//     let future: [String: Future]
// }

func decodeResponse(data: Data) {
    do {
        // First, decode the data as a string
        let jsonString = try JSONDecoder().decode(String.self, from: data)
        
        // Convert the JSON string back to Data
        if let jsonData = jsonString.data(using: .utf8) {
            // Decode the JSON data into your model
            let response = try JSONDecoder().decode(AnalyzeImageResponse.self, from: jsonData)
            print("Decoded response: \(response)")
        }
    } catch {
        print("Failed to decode response: \(error)")
    }
}
