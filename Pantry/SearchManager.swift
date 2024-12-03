//
//  SearchManager.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/29/24.
//

import Foundation
import FirebaseFirestore
import Combine

class SearchManager: ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var items : [Food] = []
    
    func fetchItems(searchQuery: String) {
        //print(searchQuery)

        // Get the collection from the database
        db.collection("test")
        .whereField("name", isGreaterThanOrEqualTo: searchQuery)
        .whereField("name", isLessThanOrEqualTo: searchQuery + "\u{f7ff}")
        
        /*
        .whereField("name", isGreaterThanOrEqualTo: "A")
        .whereField("name", isLessThanOrEqualTo: "A\u{f7ff}")
        */
        //.whereField("name", in: ["Apples"])
        //.whereField("name", arrayContains: searchQuery)
        //.whereField("name", isEqualTo: searchQuery) // Where searching occurs
        .getDocuments { snapshot, error in
            
            // Check for errors
            if error == nil {
                // No errors
                print("No errors")
                if let snapshot = snapshot {
                    
                    // Update the list property in the main thread
                    DispatchQueue.main.async {
                        
                        // Get all documents
                        self.items = snapshot.documents.map { d in
                            
                            // Create an item for each document
                            return Food(id: d.documentID,
                                            name: d["name"] as? String ?? "",
                                            foodGroup: d["Food Group"] as? String ?? "",
                                            food_id: d["ID"] as? Int32 ?? 0,
                                            calories: d["Calories"] as? Int32 ?? 0,
                                            fat: d["Fat (g)"] as? Float32 ?? 0.0,
                                            carbohydrates: d["Carbohydrate (g)"] as? Float32 ?? 0.0,
                                            protein: d["Protein (g)"] as? Float32 ?? 0.0,
                                            suitableFor: d["suitableFor"] as? [String] ?? []
                            )
                        }
                    }
                    
                    
                }
            }
            // If there are errors
            else {
                print("Error getting documents: \(error as Optional)")
            }
        }
        
        
        // Tutorial code, doesn't work
        /*
         func fetchItems(searchQuery: String) {
         print(searchQuery)
         db.collection("test")
         .whereField("Calories", isGreaterThanOrEqualTo: 50)
         //.whereField("name", isEqualTo: searchQuery)
         .getDocuments { snapshot, error in
         if let error = error {
         print("Error fetching data: \(error)")
         return
         }
         
         
         
         
         self.items = snapshot?.documents.compactMap { document in
         try? document.data(as: FoodTest.self)
         } ?? []
         print(self.items)
         }
         
         }
         */
    }
}

