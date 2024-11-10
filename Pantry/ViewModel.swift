//
//  ViewModel.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/9/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class ViewModel: ObservableObject {
    @Published var list = [Food]()
    
    func getData() {
        
        FirebaseApp.configure()
        // Get a reference to the database
        let db = Firestore.firestore()
        
        /*
        do {
            let snapshot = try await db.collection("test").getDocuments()
            for document in snapshot.documents {
                print("\(document.documentID) => \(document.data())")
            }
        } catch {
           print("Error getting documents: \(error)")
        }
        */
        // Read documents at a specified path
        //db.collection("test").getDocuments(source: <#T##FirestoreSource#>, completion: <#T##(QuerySnapshot?, Error?) -> Void#>)
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
            else {
                print("Error getting documents: \(error as Optional)")
            }
        
        }
        
    }
}
