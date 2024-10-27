//
//  ClassSelectionView.swift
//  chalkboard-ai
//
//  Created by Ayan Khanna on 10/27/24.
//

import SwiftUI

struct ClassSelectionView: View {
    var onClassSelected: (String) -> Void // Closure to handle class selection
    
    @Environment(\.presentationMode) var presentationMode
    @State private var searchQuery = ""
    @State private var classes: [Class] = []
    @State private var isLoading = false
    @State private var debouncedSearchQuery = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    
                    TextField("Type in your class", text: $searchQuery)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .onChange(of: searchQuery) { newValue in
                            debounceSearch(newValue)
                        }
                }
                .padding([.top, .leading, .trailing], 16)
                
                // Results area with fixed height
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        VStack(spacing: 8) {
                            ForEach(classes.prefix(5)) { classItem in
                                ClassItemView(className: classItem.class_name)
                                    .onTapGesture {
                                        onClassSelected(classItem.class_name)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            }
                            
                            // Add "Other" option if there's text in the search bar
                            if !searchQuery.isEmpty {
                                ClassItemView(className: "Other: \(searchQuery)")
                                    .onTapGesture {
                                        onClassSelected("Other: \(searchQuery)")
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            }
                        }
                    }
                }
                .frame(height: 300) // Fixed height for results area
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func debounceSearch(_ query: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if query == searchQuery {
                debouncedSearchQuery = query
                Task { await searchClasses() }
            }
        }
    }
    
    private func searchClasses() async {
        guard !debouncedSearchQuery.isEmpty else {
            classes = []
            return
        }
        
        isLoading = true
        do {
            classes = try await SupabaseService.shared.searchClasses(query: debouncedSearchQuery)
            classes = Array(classes.prefix(5)) // Limit to 5 results
        } catch {
            print("Error fetching classes: \(error)")
            classes = []
        }
        isLoading = false
    }
}

// Helper view for consistent class item styling
struct ClassItemView: View {
    let className: String
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.white)
            
            Text(className)
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(white: 0.85))
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
    }
}
