//
//  GetData.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/23/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class GetData: ObservableObject {
    
    // Create a list of Foods structs
    //@Published var list = [Food]()
    @Published var list = [FoodTest]()
    
    func query() {
        
        FirebaseApp.configure()
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Get the collection from the database
        db.collection("test").getDocuments { snapshot, error in
        
            // Check for errors
            if error == nil {
                // No errors
                print("No errors")
                if let snapshot = snapshot {
                    
                    // Update the list property in the main thread
                    DispatchQueue.main.async {
                        
                        // Get all documents
                        self.list = snapshot.documents.map { d in
                            
                            // Create an item for each document
                            return FoodTest(id: d.documentID,
                                            name: d["name"] as? String ?? "",
                                            foodGroup: d["Food Group"] as? String ?? "",
                                            food_id: d["ID"] as? Int32 ?? 0,
                                            calories: d["Calories"] as? Int32 ?? 0,
                                            fat: d["Fat (g)"] as? Float32 ?? 0.0,
                                            carbohydrates: d["Carbohydrate (g)"] as? Float32 ?? 0.0,
                                            protein: d["Protein (g)"] as? Float32 ?? 0.0
                            )
                            /*
                             var id: String
                             var name: String
                             var foodGroup: String
                             var food_id: Int32
                             var calories: Int32
                             var fat: Float32
                             var carbohydrates: Float32
                             var protein: Float32
                             */
                        }
                    }
                    
                    
                }
            }
            // If there are errors
            else {
                print("Error getting documents: \(error as Optional)")
            }
        
        }
        
    }
}
