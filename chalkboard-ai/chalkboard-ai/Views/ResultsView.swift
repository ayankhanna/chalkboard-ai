//
//  ResultsView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI

struct ResultsView: View {
    var rawApiResponse: String

    @State private var boardContent: [String: Topic] = [:]
    @State private var prereqs: [String: Topic] = [:]
    @State private var future: [String: Topic] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !boardContent.isEmpty {
                    Section(header: Text("Board Content").font(.headline).foregroundColor(.white)) {
                        ForEach(boardContent.keys.sorted(), id: \.self) { key in
                            if let topic = boardContent[key] {
                                TopicView(topic: topic)
                            }
                        }
                    }
                }

                if !prereqs.isEmpty {
                    Section(header: Text("Prerequisites").font(.headline).foregroundColor(.white)) {
                        ForEach(prereqs.keys.sorted(), id: \.self) { key in
                            if let topic = prereqs[key] {
                                TopicView(topic: topic)
                            }
                        }
                    }
                }

                if !future.isEmpty {
                    Section(header: Text("Future Topics").font(.headline).foregroundColor(.white)) {
                        ForEach(future.keys.sorted(), id: \.self) { key in
                            if let topic = future[key] {
                                TopicView(topic: topic)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.black) // Ensure the background is set
        }
        .navigationBarTitle("Results", displayMode: .inline)
        .onAppear {
            parseApiResponse()
        }
    }

    private func parseApiResponse() {
        guard let data = rawApiResponse.data(using: .utf8) else {
            print("Failed to convert rawApiResponse to data")
            return
        }
        
        do {
            // First, decode the data as a string
            let jsonString = try JSONDecoder().decode(String.self, from: data)
            
            // Convert the JSON string back to Data
            if let jsonData = jsonString.data(using: .utf8) {
                // Decode the JSON data into your model
                let response = try JSONDecoder().decode(ApiResponse.self, from: jsonData)
                boardContent = response.boardContent
                prereqs = response.prereqs
                future = response.future
                print("Parsed API response successfully")
            }
        } catch {
            print("Failed to parse API response: \(error)")
        }
    }
}

struct TopicView: View {
    var topic: Topic

    var body: some View {
        VStack(alignment: .leading) {
            Text(topic.title)
                .font(.headline)
                .foregroundColor(.white) // Ensure text is visible
            Text(topic.detail)
                .font(.subheadline)
                .foregroundColor(.gray) // Use a lighter color for details
        }
        .padding(.vertical, 5)
    }
}

struct Topic: Codable {
    let title: String
    let detail: String
}

struct ApiResponse: Codable {
    let boardContent: [String: Topic]
    let prereqs: [String: Topic]
    let future: [String: Topic]

    enum CodingKeys: String, CodingKey {
        case boardContent = "BOARD_CONTENT"
        case prereqs = "PREREQS"
        case future = "FUTURE"
    }
}

#Preview {
    ResultsView(rawApiResponse: "Your raw JSON string here")
}
