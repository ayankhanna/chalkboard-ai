//
//  ApiService.swift
//  Chalk-Ayan-2
//
//  Created by Ayan Khanna on 10/27/24.
//

import Foundation

class APIService {
    // Base URL for your API
    private let baseURL = URL(string: "https://chalkboard-ai-api.vercel.app/api/analyzeImage")!
    
    // Function to analyze image
    func analyzeImage(className: String, imageUrl: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        print("Starting analyzeImage with className: \(className) and imageUrl: \(imageUrl)")
        
        // Create the URL request
        guard let url = URL(string: "https://chalkboard-ai-api.vercel.app/api/analyzeImage") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "className": className,
            "image": imageUrl
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            print("Request URL: \(url.absoluteString)")
            print("Request Method: \(request.httpMethod ?? "Unknown")")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let requestBodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Request Body: \(requestBodyString)")
            }
        } catch {
            print("Error creating request body: \(error)")
            completion(.failure(error))
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            // Debug: Log the raw response data
            if let rawResponseString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(rawResponseString)")
            } else {
                print("Failed to convert response data to string")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                print("analyzeImage succeeded")
                completion(.success(decodedResponse))
            } catch {
                print("Failed to decode response: \(error)")
                if let rawResponseString = String(data: data, encoding: .utf8) {
                    print("Decoding failed. Raw response data: \(rawResponseString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}

struct ApiResponse: Decodable {
    let boardContent: [String: Topic]
    let prereqs: [String: Topic]
    let future: [String: Topic]

    enum CodingKeys: String, CodingKey {
        case boardContent = "BOARD_CONTENT"
        case prereqs = "PREREQS"
        case future = "FUTURE"
    }
}

struct Topic: Decodable {
    let title: String
    let detail: String
}
