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
    
    @Published var breakfastFoodEntries: [FoodJournalItem] = []
    @Published var lunchFoodEntries: [FoodJournalItem] = []
    @Published var dinnerFoodEntries: [FoodJournalItem] = []
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private let collectionName = "foodEntries"
    @Published var now: Date = Date()
    
    
    func fetchFoodEntries(mealName: String, for date: Date) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        
        self.now = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: now)

        let docRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("mealLogs")
            .document(formattedDate)

        docRef.getDocument { document, error in
            if let error = error {
                self.errorMessage = "Error fetching meal log: \(error.localizedDescription)"
                return
            }
            
            guard let document = document, document.exists else {
                DispatchQueue.main.async {
                    self.errorMessage = "No meal log found for this date"
                    self.breakfastFoodEntries = []
                    self.lunchFoodEntries = []
                    self.dinnerFoodEntries = []
                }
                return
            }


            guard let mealData = document.data()?[mealName.lowercased()] as? [[String: Any]] else {
                self.errorMessage = "No data found for meal: \(mealName)"
                return
            }

            var entries: [FoodJournalItem] = []
            let group = DispatchGroup()

            for item in mealData {
                guard
                    let foodID = item["foodID"] as? String,
                    let name = item["name"] as? String,
                    let amount = item["amount"] as? Double
                else {
                    print("Failed to parse item: \(item)")
                    continue
                }

                group.enter()

                Firestore.firestore()
                    .collection("Food")
                    .document(foodID)
                    .getDocument { foodDoc, error in
                        defer { group.leave() }

                        if let error = error {
                            print("Error fetching food doc for ID \(foodID): \(error.localizedDescription)")
                            return
                        }

                        guard let data = foodDoc?.data() else {
                            print("No data for food ID \(foodID)")
                            return
                        }

                        let entry = FoodJournalItem(
                            id: UUID().uuidString,
                            name: name,
                            foodGroup: data["foodGroup"] as? String ?? "Unknown",
                            food_id: foodID,
                            calories: Int32(data["calories"] as? Double ?? 0),
                            fat: Float32(data["fat"] as? Double ?? 0),
                            carbohydrates: Float32(data["carbohydrates"] as? Double ?? 0),
                            protein: Float32(data["protein"] as? Double ?? 0),
                            suitableFor: data["suitableFor"] as? [String] ?? [],
                            quantity: amount
                        )

                        entries.append(entry)
                    }
            }

            // Wait for all lookups to complete
            group.notify(queue: .main) {
                switch mealName.lowercased() {
                case "breakfast":
                    self.breakfastFoodEntries = entries
                case "lunch":
                    self.lunchFoodEntries = entries
                case "dinner":
                    self.dinnerFoodEntries = entries
                default:
                    break
                }

                self.saveLocally(foodEntries: entries, for: mealName)
                self.objectWillChange.send()
            }
        }
    }
    
    func saveLocally(foodEntries: [FoodJournalItem], for mealName: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(foodEntries) {
            UserDefaults.standard.set(encoded, forKey: "\(mealName.lowercased())foodEntries")
        }
    }
    
    func loadLocally(for mealName: String) -> [FoodJournalItem] {
        if let savedData = UserDefaults.standard.data(forKey: "foodEntries_\(mealName.lowercased())"),
           let decodedEntries = try? JSONDecoder().decode([FoodJournalItem].self, from: savedData) {
            return decodedEntries
        }
        return []
    }

    
    func deleteFoodEntry(mealName: String, food: FoodJournalItem) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: now)
        
        let mealDocRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("mealLogs")
            .document(formattedDate)
        
        mealDocRef.getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch meal data: \(error.localizedDescription)"
                }
                return
            }
            
            // Get array from document for the mealName field
            guard let document = snapshot,
                  let mealArray = document.data()?[mealName] as? [[String: Any]] else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data found for \(mealName)"
                }
                return
            }

            // Filter out the item to be deleted
            let updatedMealArray = mealArray.filter { entry in
                guard let entryFoodID = entry["foodID"] else { return true }

                // Match Int, Int32, or even String-based foodIDs
                if let intID = entryFoodID as? Int {
                    return String(intID) != food.food_id
                } else if let strID = entryFoodID as? String, let intID = Int32(strID) {
                    return intID != Int32(food.food_id)
                }
                return true // if type is weird or doesn't match, keep it
            }

            // Overwrite the mealName field with the updated array
            mealDocRef.updateData([
                mealName: updatedMealArray
            ]) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to delete entry in Firestore: \(error.localizedDescription)"
                    }
                    return
                }

                DispatchQueue.main.async {
                    // Update local state
                    switch mealName.lowercased() {
                    case "breakfast":
                        self.breakfastFoodEntries.removeAll { $0.food_id == food.food_id }
                    case "lunch":
                        self.lunchFoodEntries.removeAll { $0.food_id == food.food_id }
                    case "dinner":
                        self.dinnerFoodEntries.removeAll { $0.food_id == food.food_id }
                    default:
                        print("Invalid Meal Name")
                    }

                    self.saveLocally(foodEntries: self.loadLocally(for: mealName), for: mealName)
                    self.objectWillChange.send()
                }
            }
        }
    }


    
    func totalCaloriesForDay()-> Int {
        let breakfastCalories = breakfastFoodEntries.reduce(0) { $0 + Int($1.calories) }
        let lunchCalories = lunchFoodEntries.reduce(0) { $0 + Int($1.calories) }
        let dinnerCalories = dinnerFoodEntries.reduce(0) { $0 + Int($1.calories) }
        
        return breakfastCalories + lunchCalories + dinnerCalories
    }
}


