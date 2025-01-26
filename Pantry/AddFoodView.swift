//
//  AddFoodView.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/29/24.
//

import Foundation
import SwiftUI

struct AddFoodView: View {
    @State private var searchText: String = ""
    @ObservedObject var searchManager = SearchManager()
    
    var body: some View {
        VStack{
            
            // Display search field
            TextField("Search", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
                // Update search on each character being entered
                .onChange(of: searchText) {
                    searchManager.fetchItems(searchQuery: searchText)
                }
            
            // Display search results
            List(searchManager.items, id: \.id) {item in
                //Text(item.name) //  Displays items as a list
                
                // Show search results as buttons
                Button(action: {
                    
                    // Preform the function when item is pressed
                    selectFood(item)
                }) {
                    
                    // Display search results
                    HStack {
                        Text(item.name)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue))
                }
            }
        }
        .padding()
    }
    
    // Function for what happens when a food is selected
    private func selectFood(_ item: Food) {
        // Prompt user for quantity
        print("Item tapped: \(item.id)")
    }
}

#Preview {
    AddFoodView()
}
