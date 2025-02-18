//
//  RetrieveWorkoutData.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/26/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



class RetrieveWorkoutData : ObservableObject {
    
    //2D array for workoutplan
    @Published var workoutPlan : [[Exercise]] = []
    @Published var completedExercisesCounts: [Int] = []
    
    let now = Date()
    
    //reworked function to load the workoutplan from the database
    private func saveWorkoutPlanLocally(){
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(workoutPlan){
                UserDefaults.standard.set(encodedData, forKey: "workoutPlan")
            } else{
                print("Failed to encode exercises.")
            }
        }
    
    //untested
    func fetchWorkoutPlan() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        //get current date in correct format for document naming purposes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy"
        let formattedDate = dateFormatter.string(from: now)

        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)

        var tempWorkoutPlan: [[Exercise]] = []

        //let group = DispatchGroup()

        for i in 1...4 {
          //  group.enter()
            db.collection("Day\(i)").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
              //      group.leave()
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No documents found for Day \(i)")
                   // group.leave()
                    return
                }

                var exercisesForDay: [Exercise] = []
                for document in documents {
                    let data = document.data()
                    
                    let exercise = Exercise(
                        category: data["category"] as? String ?? "",
                        equipment: data["equipment"] as? String ?? "",
                        force: data["force"] as? String ?? "",
                        id: document.documentID,
                        imageURLs: data["imageURLs"] as? [String] ?? [],
                        instructions: data["instructions"] as? [String] ?? [],
                        level: data["level"] as? String ?? "",
                        mechanic: data["mechanic"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        primaryMuscles: data["primaryMuscles"] as? [String] ?? [],
                        secondaryMuscles: data["secondaryMuscles"] as? [String] ?? [],
                        isComplete: data["isComplete"] as? Bool ?? false
                    )
                        exercisesForDay.append(exercise)
                    
                }

                DispatchQueue.main.async {
                    while tempWorkoutPlan.count < i {
                        tempWorkoutPlan.append([])  // Ensure we have a slot for each day
                    }
                    tempWorkoutPlan[i - 1] = exercisesForDay
                    print("Fetched \(exercisesForDay.count) exercises for Day \(i)")
                }
               // group.leave()
            }
        }

       // group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.workoutPlan = tempWorkoutPlan
                self.saveWorkoutPlanLocally()  // Save locally after fetching
                print("Workout Plan after fetch: \(self.workoutPlan)")
            }
        }
    
    
    
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
                
                saveWorkoutPlanDB()
                break
            }
        }
        
    }
    
    func queryExercises(days: [(String, String)], maxExercises: Int = 4, level: String, completion: @escaping () -> Void)  {
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
                                category: document["category"] as? String ?? "",
                                equipment: document["equipment"] as? String ?? "",
                                force: document["force"] as? String ?? "",
                                id: document.documentID,
                                imageURLs: (document["imageURLs"] as? [String]) ?? [],
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
                print("Test1")
                //self.saveWorkoutPlan()
                self.saveWorkoutPlanDB()
                print("Test2")

                self.saveWorkoutPlanLocally()
                print("Test3")

                completion()
                
            }
        }
    }

//previous saveWorkoutPlan for saving plan to device
    
//    private func saveWorkoutPlan(){
//        let encoder = JSONEncoder()
//        if let encodedData = try? encoder.encode(workoutPlan){
//            UserDefaults.standard.set(encodedData, forKey: "workoutPlan")
//        } else{
//            print("Failed to encode exercises.")
//        }
//    }
    
    //reworked function to save the workoutplan to the database
    func saveWorkoutPlanDB(){
        //get user ID
        //temp. user id for testing
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy"
        let formattedDate = dateFormatter.string(from: now)
       
        let db = Firestore.firestore()
        
//        let group = DispatchGroup()
        //iterate through every exercise in the weekly plan
        for(dayIndex, exercises) in workoutPlan.enumerated(){
            let dayCollection = db
            //we will want to change week based off the current week it is generated
                .collection("users")
                .document(userID)
                .collection("workoutplan")
                .document(formattedDate)
                .collection("Day\(dayIndex + 1)")
            
            for exercise in exercises{
                let exerciseDocument = dayCollection.document(exercise.name)
                
                let data: [String: Any] = [
                    "category": exercise.category,
                    "equipment": exercise.equipment,
                    "force": exercise.force,
                    "id": exercise.id,
                    "imageURLs": exercise.imageURLs,
                    "instructions": exercise.instructions,
                    "level": exercise.level,
                    "mechanic": exercise.mechanic,
                    "name": exercise.name,
                    "primaryMuscles": exercise.primaryMuscles,
                    "secondaryMuscles": exercise.secondaryMuscles,
                    //may need to exclude this one?
                    "isComplete": exercise.isComplete
                ]
                //may need to add an error/catch for if the exercise already exists in there?
                exerciseDocument.setData(data, merge: true) { error in
                    if error != nil{
                        print("Error updating Workout Document \(exercise.name).")
                    } else{
                        print("Updated Workout Document\(exercise.name).")
                    }
//                    group.leave()
                }
            }
            
        }
//        group.notify(queue: .main) {
//                // Notify when all updates are complete
//                print("All exercises have been saved to the database.")
//            }
        
    }
    //need to pull from database instead! rework this function?
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




