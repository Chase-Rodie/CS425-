//
//  RetrieveWorkoutData.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/26/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore



class RetrieveWorkoutData : ObservableObject {
    
    //will reflect changes in all views
    
    @Published var exercise: Exercise? = nil
    
   
    func queryExercises()  {
        FirebaseApp.configure()
        let db = Firestore.firestore()

        db.collection("exercises").whereField("name", isEqualTo: "Suspended Row").getDocuments{ snapshot, error in
            
            if error == nil{
                 print("No errors")
                if let snapshot = snapshot, let document = snapshot.documents.first {
                    DispatchQueue.main.async {
                        self.exercise = Exercise(
                            id: document.documentID,
                            category: document["category"] as? String ?? "",
                            equipment: document["equipment"] as? String ?? "",
                            force: document["force"] as? String ?? "",
                            instructions: (document["instructions"] as? [String]) ?? [],
                            level: document["level"] as? String ?? "",
                            mechanic: document["mechanic"] as? String ?? "",
                            name: document["name"] as? String ?? "",
                            primaryMuscles: (document["primaryMuscles"] as? [String]) ?? [],
                            secondaryMuscles: (document["secondaryMuscles"] as? [String]) ?? []
                        )
                    }
                } else {
                    print("No document found!")
                }
            }
            else{
                print("Error getting documents.")
            }
        }
        
    }
    
}
