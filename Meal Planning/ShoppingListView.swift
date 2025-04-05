//
//  ShoppingListView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/2/25.

import SwiftUI
import Firebase

struct ShoppingListView: View {
    @StateObject private var shoppingList = ShoppingList()
    @State private var newItem: String = ""
    @State private var newQuantity: String = ""
    @State private var showQuantityPrompt = false
    @State private var pendingItemName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(Array(shoppingList.items.enumerated()), id: \.1.id) { index, item in
                        HStack {
                            Text("\(item.name) (\(item.quantity, specifier: "%.1f"))")
                            Spacer()
                            Button(action: {
                                shoppingList.removeItem(at: index)
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
                        pendingItemName = trimmedItem
                        newItem = ""
                        showQuantityPrompt = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("BackgroundColor"))
                            .font(.title)
                    }
                    .padding(.trailing)
                }
                .padding()
            }
            .navigationTitle("Shopping List")
        }
        .sheet(isPresented: $showQuantityPrompt) {
            VStack(spacing: 20) {
                Text("Enter quantity for \(pendingItemName)")
                    .font(.headline)

                TextField("Quantity", text: $newQuantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                HStack {
                    Button("Cancel") {
                        newQuantity = ""
                        showQuantityPrompt = false
                    }
                    .foregroundColor(Color("Orange"))

                    Spacer()

                    Button("Add") {
                        if let quantity = Double(newQuantity) {
                            shoppingList.addItem(name: pendingItemName, quantity: quantity)
                        }
                        newQuantity = ""
                        pendingItemName = ""
                        showQuantityPrompt = false
                    }
                    .foregroundColor(Color("Navy"))
                }
                .padding()
            }
            .padding()
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
