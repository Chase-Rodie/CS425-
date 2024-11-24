//
//  ViewModel.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/9/24.
//
/*
import Foundation
import Firebase
import FirebaseFirestore

class ViewModel: ObservableObject {
    
    // Create a list of Foods structs
    @Published var list = [Food]()
    
    func getData() {
        
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
                            return Food(id: d.documentID,
                                        name: d["name"] as? String ?? "",
                                        food_id: d["ID"] as? Int32 ?? 0)
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
*/
