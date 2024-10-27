//
//  ApiModels.swift
//  Chalk-Ayan-2
//
//  Created by Ayan Khanna on 10/27/24.
//

import Foundation

struct AnalyzeImageRequest: Codable {
    let className: String
    let image: String
}

struct AnalyzeImageResponse: Codable {
    struct Topic: Codable {
        let title: String
        let detail: String
    }
    
    struct BoardContent: Codable {
        let topic1: Topic
        let topic2: Topic
    }
    
    struct Prereq: Codable {
        let title: String
        let detail: String
    }
    
    struct Future: Codable {
        let title: String
        let detail: String
    }
    
    let boardContent: [String: Topic]
    let prereqs: [String: Prereq]
    let future: [String: Future]
}
