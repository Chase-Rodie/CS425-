//
//  FirestoreManager.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 02/28/2025
//

import Firebase
import FirebaseFirestore

#if DEBUG
let isPreview = true
#else
let isPreview = false
#endif

class FirestoreManager {
    private let db: Firestore = {
        if isPreview {
            print("Running in preview mode - skipping Firestore setup.")
            return Firestore.firestore()
        } else {
            print("Running in production mode - Firestore configured.")
            return Firestore.firestore()
        }
    }()

//    func fetchMeals(completion: @escaping ([MealPlanner]) -> Void) {
//        db.collection("Food").getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Failed to fetch meals: \(error.localizedDescription)")
//                completion([])
//                return
//            }
//
//            var meals = [MealPlanner]()
//            snapshot?.documents.forEach { document in
//                let data = document.data()
//                if let name = data["name"] as? String,
//                   let foodID = document.documentID as String? {
//                    let imageURL = data["imageURL"] as? String
//                    let meal = MealPlanner(name: name, foodID: foodID, imageURL: imageURL)
//                    meals.append(meal)
//                }
//            }
//            print("Fetched \(meals.count) meals.")
//            completion(meals)
//        }
//    }
    
    func fetchMeals(completion: @escaping ([MealPlanner]) -> Void) {
        db.collection("Food").getDocuments { (snapshot, error) in
            if let error = error {
                print("Failed to fetch meals: \(error.localizedDescription)")
                completion([])
                return
            }

            var meals = [MealPlanner]()
            snapshot?.documents.forEach { document in
                let data = document.data()
                let docID = document.documentID
                if let name = data["name"] as? String {
                    let rawID = document.documentID
                    let foodID = "[\(rawID)]"
                    let imageURL = data["imageURL"] as? String

                    let categoryString = data["category"] as? String
                    let category = MealCategory(rawValue: categoryString ?? "Prepared") ?? .prepared

                    let meal = MealPlanner(pantryDocID: docID, name: name, foodID: foodID, imageURL: imageURL, category: category, quantity: 1.0)
                    meals.append(meal)
                } else {
                    print("Skipping \(document.documentID) — missing name.")
                }
            }

            print("Fetched \(meals.count) meals.")
            completion(meals)
        }
    }


    func fetchFoodDetails(for foodID: String, completion: @escaping ([String: Any]?) -> Void) {
        let timeoutSeconds = 5.0
        var isCompleted = false

        db.collection("Food").document(foodID).getDocument { (document, error) in
            if isCompleted { return }
            isCompleted = true

            if let error = error {
                print("Firestore error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let document = document, document.exists {
                print("Successfully fetched data for foodID \(foodID): \(document.data() ?? [:])")
                completion(document.data())
            } else {
                print("Document does not exist or data is nil.")
                completion(nil)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds) {
            if !isCompleted {
                isCompleted = true
                print("Request timed out for foodID \(foodID).")
                completion(nil)
            }
        }
    }
}
