//
//  SupabaseService.swift
//  Chalk-Ayan-2
//
//  Created by Ayan Khanna on 10/26/24.
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    private let client: SupabaseClient
    
    // Public variable to store the URL of the uploaded photo
    public var photoUploadUrl: String?
    
    // Public variable to store a copy of the photoUploadUrl for API input
    public var photoApiInput: String?

    private init() {
        // Initialize SupabaseClient with your Supabase URL and Key
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://dkfifcfgdjylhfmccugf.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrZmlmY2ZnZGp5bGhmbWNjdWdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk5NTY3OTgsImV4cCI6MjA0NTUzMjc5OH0.GPqOtZIfLWv8mTdflSNluQmdZi1fWZhD1gnfUW-ALsM"
        )
    }
    
    func searchClasses(query: String) async throws -> [Class] {
        let response = try await client.database
            .from("classes")
            .select("id, class_name")
            .ilike("class_name", value: "%\(query)%")
            .execute()
        
        // Decode JSON directly to `[Class]`
        let jsonData = response.data
        let decodedData = try JSONDecoder().decode([Class].self, from: jsonData)
        return decodedData
    }
    
    func uploadPhoto(imageData: Data, fileName: String) async throws {
        let response = try await client.storage
            .from("image-uploads")
            .upload(path: fileName, file: imageData)
        
        // Assuming the upload is successful if no exception is thrown
        print("Photo uploaded successfully to path: \(response.path)")
        
        // Manually construct the public URL
        let baseUrl = "https://dkfifcfgdjylhfmccugf.supabase.co/storage/v1/object/public/image-uploads/"
        self.photoUploadUrl = baseUrl + response.path
        self.photoApiInput = self.photoUploadUrl // Copy the URL to photoApiInput
        print("Constructed URL: \(self.photoUploadUrl ?? "No URL")") // Debugging print statement
    }
}

struct Class: Identifiable, Codable {
    let id: Int
    let class_name: String
}
