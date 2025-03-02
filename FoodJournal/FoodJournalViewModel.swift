//
//  FoodJournalViewModel.swift
//  Fit Pantry
//
//  Created by Lexie Reddon
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


@MainActor class FoodJournalViewModel: ObservableObject {

    @Published var showingFoodJournalItemAddView = false
    
    @Published var breakfastFoodEntries: [Food] = []
    @Published var lunchFoodEntries: [Food] = []
    @Published var dinnerFoodEntries: [Food] = []
    @State private var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private let collectionName = "foodEntries"
    let now = Date()
    
    func fetchFoodEntries(mealName: String){
//        guard let userID = Auth.auth().currentUser?.uid else {
//            return
//        }
        let userID = "gwj5OvTOGmNA8GCfd7nkEzo3djA2"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let formattedDate = dateFormatter.string(from: now)
       
        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("foodjournal")
            .document(formattedDate)
           // .collection("breakfast")
            .collection(mealName)
        
        db.getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch food journal items for "+mealName+": \(error.localizedDescription)"
                return
            }
            
            
            guard let snapshot = snapshot else {
                DispatchQueue.main.async{
                    self.errorMessage = "No food journal items found"
                }
                return
            }
            
            let fetchedfoodEntries = snapshot.documents.compactMap{ doc in
                let data = doc.data()
                    let id = doc.documentID
                    let food_id = data["id"] as? Int32 ?? 0
                    let name = data["name"] as? String ?? "Unknown"
                    let foodGroup = data["foodGroup"] as? String ?? "Unknown"
                    let calories = (data["calories"] as? NSNumber)?.intValue ?? 0
                    let fat = (data["fat"] as? NSNumber)?.floatValue ?? 0.0
                    let carbohydrates = (data["carbohydrates"] as? NSNumber)?.floatValue ?? 0.0
                    let protein = (data["protein"] as? NSNumber)?.floatValue ?? 0.0
                    let suitableFor = data["suitableFor"] as? [String] ?? []

                    return Food(id: id, name: name, foodGroup: foodGroup, food_id: food_id, calories: Int32(calories), fat: fat, carbohydrates: carbohydrates, protein: protein, suitableFor: suitableFor)
                }
            DispatchQueue.main.async{
                switch mealName.lowercased(){
                case "breakfast":
                    self.breakfastFoodEntries = fetchedfoodEntries
                case "lunch":
                    self.lunchFoodEntries = fetchedfoodEntries
                case "dinner":
                    self.dinnerFoodEntries = fetchedfoodEntries
                default:
                    print("Invalid Meal Name")
                    
                }
                self.saveLocally(foodEntries: fetchedfoodEntries, for: mealName)

                self.objectWillChange.send()
            }
            
        }
        
    }
    
    func saveLocally(foodEntries: [Food], for mealName: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(foodEntries) {
            UserDefaults.standard.set(encoded, forKey: "\(mealName.lowercased())foodEntries")
        }
    }

    
    func loadLocally(for mealName: String) -> [Food] {
        if let savedData = UserDefaults.standard.data(forKey: "foodEntries_\(mealName.lowercased())"),
           let decodedEntries = try? JSONDecoder().decode([Food].self, from: savedData) {
            return decodedEntries
        }
        return []
    }

  
    
    func deleteFoodEntry(mealName: String, food: Food) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let formattedDate = dateFormatter.string(from: now)
        
        let foodDocument = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("foodjournal")
            .document(formattedDate)
            .collection(mealName)
            .document(food.id)

        foodDocument.delete { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to delete food entry: \(error.localizedDescription)"
                }
                return
            }
            
            DispatchQueue.main.async {
                switch mealName.lowercased() {
                case "breakfast":
                    self.breakfastFoodEntries.removeAll { $0.id == food.id }
                case "lunch":
                    self.lunchFoodEntries.removeAll { $0.id == food.id }
                case "dinner":
                    self.dinnerFoodEntries.removeAll { $0.id == food.id }
                default:
                    print("Invalid Meal Name")
                }
                
                self.saveLocally(foodEntries: self.loadLocally(for: mealName), for: mealName)
                self.objectWillChange.send()
            }
        }
    }

}


