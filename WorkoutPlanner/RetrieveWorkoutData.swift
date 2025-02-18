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
    @Published var completedExercisesCounts: [Int] = []
    
//    func resetWorkoutPlan() {
//         self.workoutPlan = []  // Clear the in-memory workout plan
//         print("In-memory workoutPlan cleared.")
//     }
    
    //this function will allow for data to show properly in the progressrings for the homepage
    //does need further testing
    func completedExercises() {
           completedExercisesCounts = workoutPlan.map { day in
               day.filter { $0.isComplete }.count
           }
       }
    
    func progress(forDay index: Int) -> Double {
            guard index < workoutPlan.count else { return 0.0 }
            let totalExercises = workoutPlan[index].count
            let completedExercises = completedExercisesCounts[index]
            return totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0.0
        }
    
    
    func markComplete(for exercise: Exercise){
        //find the exercise
        
        for dayIndex in workoutPlan.indices{
            if let exerciseIndex = workoutPlan[dayIndex].firstIndex(where: { $0.id == exercise.id }){
                workoutPlan[dayIndex][exerciseIndex].isComplete.toggle()
                
                saveWorkoutPlan()
                break
            }
        }
        
    }
    
    func queryExercises(days: [(String, String)], maxExercises: Int = 4, level: String)  {
      //  FirebaseApp.configure()
        let db = Firestore.firestore()
        
        var tempExercises: [[Exercise]] = Array(repeating: [], count: days.count)
        
        let group = DispatchGroup()
        
        for(index,(type, primaryMuscle)) in days.enumerated(){
            group.enter()
            db.collection("exercises").whereField("force", isEqualTo: type).whereField("level", isEqualTo: level ).whereField("primaryMuscles", arrayContains: primaryMuscle).limit(to: maxExercises).getDocuments{ snapshot, error in
                
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
                DispatchQueue.main.async{
                    self.workoutPlan = decodedData
                }
                return true 
            } else {
                print("No saved exercises found.")
                return false
            }
        }
    
    
}




