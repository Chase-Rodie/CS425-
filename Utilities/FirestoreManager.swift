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

    func fetchMeals(for category: MealCategory, completion: @escaping ([MealPlanner]) -> Void) {
        db.collection("Food")
            .whereField("category", isEqualTo: category.rawValue.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch \(category.rawValue) meals: \(error.localizedDescription)")
                    completion([])
                    return
                }

                var meals: [MealPlanner] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    let docID = document.documentID

                    guard let name = data["name"] as? String,
                          let calories = data["calories"] as? Double,
                          let protein = data["protein"] as? Double,
                          let fat = data["fat"] as? Double,
                          let carbs = data["carbohydrates"] as? Double else {
                        return
                    }

                    let meal = MealPlanner(
                        pantryDocID: docID,
                        name: name,
                        foodID: String(data["id"] as? Int ?? -1),
                        imageURL: data["imageURL"] as? String,
                        category: category,
                        quantity: 1.0,
                        calories: calories,
                        protein: protein,
                        fat: fat,
                        carbohydrates: carbs
                    )

                    meals.append(meal)
                }
                completion(meals)
            }
    }
    
    func fetchAllMeals(completion: @escaping ([MealPlanner]) -> Void) {
        let group = DispatchGroup()
        var allMeals: [MealPlanner] = []

        for category in MealCategory.allCases {
            group.enter()
            fetchMeals(for: category) { meals in
                allMeals.append(contentsOf: meals)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(allMeals)
        }
    }

    
    func fetchUserMeals(for userID: String, completion: @escaping ([MealPlanner]) -> Void) {
        let pantryRef = db.collection("users").document(userID).collection("pantry")

        pantryRef.getDocuments { pantrySnapshot, error in
            guard let pantryDocs = pantrySnapshot?.documents else {
                print("Error fetching pantry: \(error?.localizedDescription ?? "unknown error")")
                completion([])
                return
            }

            let pantryItems: [(foodID: String, quantity: Double, pantryDocID: String)] = pantryDocs.compactMap { doc in
                guard let id = doc.data()["id"] as? Int,
                      let quantity = doc.data()["quantity"] as? Double else { return nil }
                return (String(id), quantity, doc.documentID)
            }

            let idChunks = pantryItems.map { $0.foodID }.chunked(into: 10)
            var meals: [MealPlanner] = []
            let group = DispatchGroup()

            for chunk in idChunks {
                group.enter()
                self.db.collection("Food")
                    .whereField("id", in: chunk.compactMap { Int($0) })
                    .getDocuments { foodSnapshot, error in
                        defer { group.leave() }

                        guard let foodDocs = foodSnapshot?.documents else {
                            print("Error fetching Food chunk: \(error?.localizedDescription ?? "unknown error")")
                            return
                        }

                        for doc in foodDocs {
                            let data = doc.data()
                            guard let id = data["id"] as? Int,
                                  let name = data["name"] as? String,
                                  let calories = data["calories"] as? Double,
                                  let protein = data["protein"] as? Double,
                                  let fat = data["fat"] as? Double,
                                  let carbs = data["carbohydrates"] as? Double else {
                                print("Skipping doc with missing info: \(doc.documentID)")
                                continue
                            }

                            guard let match = pantryItems.first(where: { $0.foodID == String(id) }) else { continue }

                            let categoryStr = (data["category"] as? String)?.capitalized ?? "Prepared"
                            let category = MealCategory(rawValue: categoryStr) ?? .prepared

                            let meal = MealPlanner(
                                pantryDocID: match.pantryDocID,
                                name: name,
                                foodID: String(id),
                                imageURL: data["imageURL"] as? String,
                                category: category,
                                quantity: match.quantity,
                                calories: calories,
                                protein: protein,
                                fat: fat,
                                carbohydrates: carbs
                            )

                            meals.append(meal)
                        }
                    }
            }

            group.notify(queue: .main) {
                completion(meals)
            }
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
