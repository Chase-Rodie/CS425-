//
//  ShoppingList.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 12/1/24.
//

//import Foundation
//
//class ShoppingList{
//    var items: [String] = []
//
//    func addItems(for mealPlan: [String]){
//        for meal in mealPlan{
//            switch meal{
//            case "Breakfast":
//                items.append("eggs")
//                items.append("milk")
//            case "Lunch":
//                items.append("Grilled Cheese")
//                items.append("Apples")
//            case "Dinner":
//                items.append("Chicken and Salad")
//            default:
//                break
//            }
//        }
//    }
//
//    func printShoppingList(){
//        print("Shopping List: \(items)")
//    }
//}

import Foundation
import Firebase
import FirebaseAuth

class ShoppingList: ObservableObject {
    @Published var items: [String] = []
    private let db = Firestore.firestore()
    
    private var userID: String? {
        Auth.auth().currentUser?.uid
    }
    
    func addItem(_ item: String) {
        items.append(item)
        saveToFirestore()
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
        saveToFirestore()
    }
    
    func saveToFirestore() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("shoppingList").document("items").setData(["items": items]) { error in
            if let error = error {
                print("Error saving shopping list: \(error)")
            } else {
                print("Shopping list saved successfully.")
            }
        }
    }
    
    func loadFromFirestore() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("shoppingList").document("items").getDocument { snapshot, error in
            if let error = error {
                print("Error loading shopping list: \(error)")
                return
            }
            
            if let data = snapshot?.data(), let items = data["items"] as? [String] {
                DispatchQueue.main.async {
                    self.items = items
                }
                print("Shopping list loaded successfully.")
            }
        }
    }
    
    func printShoppingList() {
        print("Shopping List: \(items)")
    }
}
