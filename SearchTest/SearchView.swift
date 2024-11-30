//
//  SearchView.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/29/24.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @ObservedObject var firestoreManager = FirestoreManager()
    
    var body: some View {
        VStack{
            TextField("Search", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { //newValue in
                    firestoreManager.fetchItems(searchQuery: searchText)
                }
            
            List(firestoreManager.items, id: \.id) {item in
                Text(item.name)
            }
        }
        .padding()
    }
}

#Preview {
    SearchView()
}

