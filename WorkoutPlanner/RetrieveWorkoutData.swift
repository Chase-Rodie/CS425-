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
    
    //2D array for workoutplan
    @Published var workoutPlan : [[Exercise]] = []
    
    
    func queryExercises(type: [String], maxExercises: Int = 4)  {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        
        var tempExercises: [[Exercise]] = Array(repeating: [], count: type.count)
        
        let group = DispatchGroup()
        
        for(index, type) in type.enumerated(){
            group.enter()
            db.collection("exercises").whereField("force", isEqualTo: type).limit(to: maxExercises).getDocuments{ snapshot, error in
                
                if error == nil{
                    print("No errors")
                    if let snapshot = snapshot{
                        let exercises = snapshot.documents.compactMap{document -> Exercise? in
                            return Exercise(
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
                        tempExercises[index] = exercises
                        print("Fetched \(exercises.count) exercises for category \(type)")
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main){
            DispatchQueue.main.async{
                self.workoutPlan = tempExercises
                self.saveWorkoutPlan()
            }
        }
    }
    
    private func saveWorkoutPlan(){
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(workoutPlan){
            UserDefaults.standard.set(encodedData, forKey: "workoutPlan")
        } else{
            print("Failed to encode exercises.")
        }
    }
    
    
    func loadWorkoutPlan() -> Bool {
            let decoder = JSONDecoder()
            if let savedData = UserDefaults.standard.data(forKey: "workoutPlan"),
               let decodedData = try? decoder.decode([[Exercise]].self, from: savedData) {
                self.workoutPlan = decodedData
                return true
            } else {
                print("No saved exercises found.")
                return false
            }
        }
    
    
}
