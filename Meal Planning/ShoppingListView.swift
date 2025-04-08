//
//  ShoppingListView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/2/25.
//

import SwiftUI
import Firebase

struct ShoppingListView: View {
    @StateObject private var shoppingList = ShoppingList()
    @State private var newItem: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(shoppingList.items, id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            Button(action: {
                                if let index = shoppingList.items.firstIndex(of: item) {
                                    shoppingList.removeItem(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .onAppear {
                    shoppingList.loadFromFirestore()
                }

                HStack {
                    TextField("Add new item", text: $newItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: {
                        let trimmedItem = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedItem.isEmpty else { return }

                        shoppingList.addItem(trimmedItem)
                        newItem = ""  // Clear the input field
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                    .padding(.trailing)
                }
                .padding()
            }
            .background(Color("LighterColor").ignoresSafeArea())
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        shoppingList.loadFromFirestore()  // Refresh the list
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
