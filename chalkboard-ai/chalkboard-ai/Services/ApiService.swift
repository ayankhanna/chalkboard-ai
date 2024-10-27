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
    func analyzeImage(className: String, imageUrl: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://chalkboard-ai-api.vercel.app/api/analyzeImage") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = AnalyzeImageRequest(className: className, image: imageUrl)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let rawResponseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            // Return the raw response string
            completion(.success(rawResponseString))
        }.resume()
    }
}

//struct ApiResponse: Decodable {
//    let boardContent: [String: Topic]
//    let prereqs: [String: Topic]
//    let future: [String: Topic]
//
//    enum CodingKeys: String, CodingKey {
//        case boardContent = "BOARD_CONTENT"
//        case prereqs = "PREREQS"
//        case future = "FUTURE"
//    }
//}
//
//struct Topic: Decodable {
//    let title: String
//    let detail: String
//}
