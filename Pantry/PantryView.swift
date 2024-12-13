//
//  PantryView.swift
//  Fit Pantry
//
//  View to let users view and edit the contents of their Pantry
//
//  Created by Chase Rodie on 10/31/24.
//  Code in this file was authored by Zach Greenhill
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PantryView: View {
    // Array to hold pantry items
    @State private var pantryItems: [PantryItem] = []
    // Error message for fetching errors
    @State private var errorMessage: String? = nil
    
    // Variables to control item edits
    @State private var showEditSheet: Bool = false
    @State private var selectedItem: PantryItem?
    @State private var newQuantity: String = ""
    @State private var newQuantityDbl: Double = 0.0
    
    // Function to fetch pantry items
    private func fetchPantryItems() {
        // Get the user's ID
        /*
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        */
        // Tempoarary static assignemt of user for testing
        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
        
        let db = Firestore.firestore()
            .collection("userData_test")
            .document(userID)
            .collection("pantry")
        
        db.getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch pantry items: \(error.localizedDescription)"
                return
            }
            
            guard let snapshot = snapshot else {
                self.errorMessage = "No pantry data found"
                return
            }
            
            // Map Firestore documents to PantryItem model
            self.pantryItems = snapshot.documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                let food_id = data["id"] as? Int ?? 0
                let name = data["name"] as? String ?? "name not found"
                let quantity = data["quantity"] as? Double ?? 0.0
                
                return PantryItem(id: id, food_id: food_id, name: name, quantity: quantity)
            }
            
            self.errorMessage = nil // Clear any previous error
        }
    }
    
    // Pantry view
    var body: some View {
        NavigationView {
            VStack {
                // Display pantry items
                if pantryItems.isEmpty {
                    Text("Your pantry is empty")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(pantryItems, id: \.id) { item in
                            Button(action: {
                                // Set the selected item and show the edit popup
                                editQuantity(item)
                            }) {
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("\(item.quantity, specifier: "%.1f")")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deletePantryItem) // Swipe-to-delete functionality
                    }
                }
                
                // Display error if fetching failed
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("My Pantry")
            .onAppear {
                fetchPantryItems()
            }
            
            // Sheet to prompt user for the amount of food they have
            // when item is selected
            .sheet(isPresented: $showEditSheet) {
                VStack {
                    // Text to display
                    Text("Amount on hand?")
                        .font(.headline)
                        .padding()
                    
                    TextField("Quantity", text: $newQuantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        // Displays keypad
                        .keyboardType(.decimalPad)
                        .padding()
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Show buttons at bottom
                    HStack {
                        // Submit Button
                        Button("Submit") {
                            submitAmount()
                        }
                        .padding()
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        //Cancel Button
                        Button("Cancel") {
                            
                            // Get rid of popup without commiting changes
                            showEditSheet = false
                        }
                        .padding()
                    }
                    .padding()
                }
                .padding()
            } // End .sheet popup entry
        }
    }
    
    
    // Function to delete an item by swiping left
    private func deletePantryItem(at offsets: IndexSet) {
        // Get the user's ID
        /*
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        */
        // Tempoarary static assignemt of user for testing
        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
        
        for index in offsets {
            let itemToDelete = pantryItems[index]
            
            let db = Firestore.firestore()
                .collection("userData_test")
                .document(userID)
                .collection("pantry")
                .document(itemToDelete.id)
            
            db.delete { error in
                if let error = error {
                    self.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                } else {
                    self.pantryItems.remove(at: index) // Remove from the local array
                    self.errorMessage = nil
                }
            }
        }
    }
    
    private func editQuantity(_ item: PantryItem){
        // Debug message
        //print("Item tapped: \(item.id)")
        
        // Get Food that was selected
        selectedItem = item
        
        // Reset Values
        newQuantity = ""
        
        // Display popup menu
        showEditSheet = true
    }
    
    // Get amount and validate for entry into database
    private func submitAmount() {
        
        // Ensure a valid item has been selected
        guard let selectedItem = selectedItem else {
            return
        }
        
        if let value = Double(newQuantity) {
            // Set amount to value if numerical
            newQuantityDbl = value
            
            // Valid value add food to database
            updatePantryItem(item: selectedItem, value: value)
            
        } else {
            // Conversion to numerical value failed
            // Display error message
            errorMessage = "Please enter a valid number"
            print("\(errorMessage ?? "")")
            //showError = true
        }
        
        // Close any popups and return to search view
        //showError = false
        fetchPantryItems()
        showEditSheet = false
    }
    
    // Function to update the quantity of a pantry item
    private func updatePantryItem(item: PantryItem, value: Double) {
        // Get the user's ID
        /*
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        */
        // Tempoarary static assignemt of user for testing
        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
        
        let db = Firestore.firestore()
            .collection("userData_test")
            .document(userID)
            .collection("pantry")
            .document(item.id)
        
        let data: [String: Any] = [
            "id": item.food_id,
            "name": item.name,
            "quantity": value
        ]
        
        // Update the document in Firestore
        db.setData(data, merge: true) { error in
            if error != nil {
                print("Error updating document")
            } else {
                print("Document updated!")
            }
        }
    }
}

#Preview {
    PantryView()
}

