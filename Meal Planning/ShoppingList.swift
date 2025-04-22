//
//  ShoppingList.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 12/1/24.

import Foundation
import Firebase
import FirebaseAuth

struct ShoppingListItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String
}

class ShoppingList: ObservableObject {
    @Published var items: [ShoppingListItem] = []
    private let db = Firestore.firestore()

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

//    func addItem(name: String, quantity: Double) {
//        let newItem = ShoppingListItem(name: name, quantity: quantity)
//        items.append(newItem)
//        saveToFirestore()
//    }
    func addItem(name: String, quantity: Double, unit: String) {
        let newItem = ShoppingListItem(name: name, quantity: quantity, unit: unit)
        items.append(newItem)
        saveToFirestore()
    }

    func removeItem(at index: Int) {
        items.remove(at: index)
        saveToFirestore()
    }

    func saveToFirestore() {
        guard let userID = userID else { return }
        let encodedItems = items.map { ["name": $0.name, "quantity": $0.quantity, "unit": $0.unit] }
        db.collection("users")
            .document(userID)
            .collection("shoppingList")
            .document("items")
            .setData(["items": encodedItems]) { error in
                if let error = error {
                    print("Error saving shopping list: \(error)")
                } else {
                    print("Shopping list saved successfully.")
                }
            }
    }

    func loadFromFirestore() {
        guard let userID = userID else { return }
        db.collection("users")
            .document(userID)
            .collection("shoppingList")
            .document("items")
            .getDocument { snapshot, error in
                if let error = error {
                    print("Error loading shopping list: \(error)")
                    return
                }

                if let data = snapshot?.data(),
                   let rawItems = data["items"] as? [[String: Any]] {
                    let loadedItems = rawItems.compactMap { dict -> ShoppingListItem? in
                        guard let name = dict["name"] as? String,
                              let quantity = dict["quantity"] as? Double,
                              let unit = dict["unit"] as? String else { return nil }
                        return ShoppingListItem(name: name, quantity: quantity, unit: unit)
                    }

                    DispatchQueue.main.async {
                        self.items = loadedItems
                    }
                }
            }
    }
    func updateQuantity(for itemID: UUID, newQuantity: Double) {
        if let index = items.firstIndex(where: { $0.id == itemID }) {
            items[index].quantity = newQuantity
            saveToFirestore()
        }
    }
}
