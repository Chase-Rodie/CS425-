// PantryManager.swift
// Fit Pantry
//
// Created by Chase Rodie on 3/15/25.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class PantryManager {
    static let shared = PantryManager()
    func saveFoodToFirestore(pantryItem: PantryItem, foodData: Food) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("pantry")
            .document(pantryItem.id) // Using pantry item's ID for Firestore document

        // Directly use the values without rounding
        let carbs = foodData.carbohydrates
        let fat = foodData.fat
        let protein = foodData.protein

        // Prepare the data to be saved to Firestore
        let data: [String: Any] = [
            "ID": pantryItem.food_id,  // Link pantry item with its food ID
            "name": pantryItem.name,  // Name of the food
            "Food Group": foodData.foodGroup,  // Fetch food group from the Food data
            "Calories": foodData.calories,  // Pantry data's calories (already a whole number)
            "Carbohydrate (g)": carbs,  // Keep original carbs value
            "Fat (g)": fat,  // Keep original fat value
            "Protein (g)": protein,  // Keep original protein value
            "quantity": pantryItem.quantity  // Pantry item's quantity
        ]

        // Save the data to Firestore
        db.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated!")
            }
        }
    }

    // Ensure rounding function is used consistently
    func roundToTwoDecimalPlaces(_ value: Double) -> Double {
        return round(value * 100) / 100.0
    }
}


