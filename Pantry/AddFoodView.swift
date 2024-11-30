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
                .onChange(of: searchText) { //newValue in
                    searchManager.fetchItems(searchQuery: searchText)
                }
            // Display search results
            List(searchManager.items, id: \.id) {item in
                Text(item.name)
            }
        }
        .padding()
    }
}

#Preview {
    AddFoodView()
}
