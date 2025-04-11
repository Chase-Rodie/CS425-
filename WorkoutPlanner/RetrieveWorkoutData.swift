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
    
    @Published var isWorkoutPlanAvailable:Bool = false
    //2D array for workoutplan
    @Published var workoutPlan : [[Exercise]] = []
    @Published var completedExercisesCounts: [Int] = []
    var workoutDays: [(String, [String])] = []
    @Published var workoutMetadata: [String: Any] = [:]
    
    
    
    let now = Date()
    
    //reworked function to load the workoutplan from the database
    func saveWorkoutPlanLocally(){
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(workoutPlan){
            UserDefaults.standard.set(encodedData, forKey: "workoutPlan")
        } else{
            print("Failed to encode exercises.")
        }
        
        UserDefaults.standard.set(workoutMetadata, forKey: "workoutMetadata")
    }
    
    
    func fetchWorkoutPlan() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        //get current date in correct format for document naming purposes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
        
        var tempWorkoutPlan: [[Exercise]] = []
        
        for i in 1...7 {
            db.collection("Day\(i)").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
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
                        isComplete: data["isComplete"] as? Bool ?? false,
                        sets: data["sets"] as? Int ?? 3,
                        reps: data["reps"] as? Int ?? 10
                    )
                    exercisesForDay.append(exercise)
                    
                }
                if !exercisesForDay.isEmpty {
                    
                    DispatchQueue.main.async {
                        while tempWorkoutPlan.count < i {
                            tempWorkoutPlan.append([])
                        }
                        tempWorkoutPlan[i - 1] = exercisesForDay
                        print("Fetched \(exercisesForDay.count) exercises for Day \(i)")
                        self.workoutPlan = tempWorkoutPlan
                        self.saveWorkoutPlanLocally()  // Save locally after fetching
                        print("Workout Plan after fetch: \(self.workoutPlan)")
                    }
                }
            }
        }
    }
    
    
    
    //this function will allow for data to show properly in the progressrings for the homepage
    //does need further testing
    //    func completedExercises() {
    //           completedExercisesCounts = workoutPlan.map { day in
    //               day.filter { $0.isComplete }.count
    //           }
    //       }
    //
    //    func progress(forDay index: Int) -> Double {
    //            guard index < workoutPlan.count else { return 0.0 }
    //            let totalExercises = workoutPlan[index].count
    //            let completedExercises = completedExercisesCounts[index]
    //            return totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0.0
    //        }
    //
    
    
    func markComplete(for exercise: Exercise){
        for dayIndex in workoutPlan.indices{
            if let exerciseIndex = workoutPlan[dayIndex].firstIndex(where: { $0.id == exercise.id }){
                workoutPlan[dayIndex][exerciseIndex].isComplete.toggle()
                saveExerciseCompletionStatus(exercise: workoutPlan[dayIndex][exerciseIndex])
                updateExerciseCompletionInDB(exercise: workoutPlan[dayIndex][exerciseIndex], dayIndex: dayIndex)
                break
            }
        }
        
    }
    
    func queryExercises(days: [(String, [String])], maxExercises: Int = 4, level: String, completion: @escaping () -> Void)  {
        let db = Firestore.firestore()
        self.workoutDays = days
        
        var tempExercises: [[Exercise]] = Array(repeating: [], count: days.count)
        
        let group = DispatchGroup()
        
        for(index,(type, primaryMuscle)) in days.enumerated(){
            group.enter()
            db.collection("exercises").whereField("force", isEqualTo: type).whereField("level", isEqualTo: level ).whereField("primaryMuscles", arrayContainsAny: primaryMuscle).limit(to: maxExercises*2).getDocuments{ snapshot, error in
                
                if error == nil{
                    print("No errors")
                    if let snapshot = snapshot{
                        let allExercises = snapshot.documents.compactMap{document -> Exercise? in
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
                                secondaryMuscles: (document["secondaryMuscles"] as? [String]) ?? [],
                                sets: document["sets"] as? Int ?? 3,
                                reps: document["reps"] as? Int ?? 10
                            )
                        }
                        
                        let randomizedExercises = allExercises.shuffled().prefix(maxExercises)
                        tempExercises[index] = Array(randomizedExercises)
                        //print("Fetched \(exercises.count) exercises for category \(type)")
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main){
            DispatchQueue.main.async{
                self.workoutPlan = tempExercises
                
                self.saveWorkoutPlanDB()
                
                self.saveWorkoutPlanLocally()
                self.isWorkoutPlanAvailable = true
                completion()
                
            }
        }
    }
    
    //reworked function to save the workoutplan to the database
    func saveWorkoutPlanDB(){
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        let docID = "\(formattedDate)-Manual"
        
        let db = Firestore.firestore()
        
        let workoutPlanDoc = db
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(docID)
        
        
        var workoutData: [String: Any] = [
            "numberOfDays" : workoutDays.count
        ]
        
        for (index, day) in workoutDays.enumerated() {
            let key = "muscleGroupDay\(index + 1)"
            let muscleGroups = day.1.joined(separator: ", ")
            workoutData[key] = muscleGroups
        }
        
        
        workoutPlanDoc.setData(workoutData, merge: true) { error in
            if let error = error {
                print("Error saving workout metadata: \(error.localizedDescription)")
            } else {
                print("Workout metadata saved successfully.")
            }
        }
        
        
        self.workoutMetadata = workoutData
        
        //iterate through every exercise in the weekly plan
        for(dayIndex, exercises) in workoutPlan.enumerated(){
            let dayCollection = db
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
                    "isComplete": exercise.isComplete,
                    "sets": exercise.sets,
                    "reps": exercise.reps
                ]
                exerciseDocument.setData(data, merge: true) { error in
                    if error != nil{
                        print("Error updating Workout Document \(exercise.name).")
                    } else{
                        print("Updated Workout Document\(exercise.name).")
                    }
                }
            }
            
        }
    }
    
    
    //need to pull from database instead! rework this function?
    func loadWorkoutPlan() -> Bool {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: "workoutPlan"),
           let decodedData = try? decoder.decode([[Exercise]].self, from: savedData) {
            DispatchQueue.main.async{
                self.workoutPlan = decodedData
            }
            
            if let savedMetadata = UserDefaults.standard.dictionary(forKey: "workoutMetadata") {
                DispatchQueue.main.async {
                    self.workoutMetadata = savedMetadata
                }
                return true
            } else {
                print("No workout metadata found.")
            }
            return true
        }else{
            print("No saved exercises found.")
            return false
        }
    }
    
    
    //Updates weight the user recorded for the exercises
    func updateWeight(for exercise: Exercise, weight: Double) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        let db = Firestore.firestore()
        let exerciseRef = db.collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
            .collection("Day1")
            .document(exercise.name)
        
        exerciseRef.updateData(["weightUsed": weight]) { error in
            if let error = error {
                print("Error updating weight: \(error.localizedDescription)")
            } else {
                print("Weight updated successfully!")
            }
        }
    }
    
    func workoutPlanExists(completion: @escaping (Bool) -> Void) {
        // First Check UserDefaults
        if loadWorkoutPlan() {
            print("Workout plan found in UserDefaults.")
            completion(true)
            return
        }
        
        // Second Check Database
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in.")
            completion(false)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
        
        db.getDocument { (document, error) in
            if let error = error {
                print("Error checking Firestore: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let document = document, document.exists {
                print("Workout plan found in Firestore.")
                completion(true)
            } else {
                print("No workout plan found.")
                completion(false)
            }
        }
    }
    
    //Retrieves the weight that the user entered for the exercise.
    func getSavedWeight(for exercise: Exercise, completion: @escaping (Double?) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user ID found")
            completion(nil)
            return
        }
        
        let weightRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
            .collection("Day1")
            .document(exercise.name)
        
        weightRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching weight: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                if let weight = data?["weightUsed"] as? Double {
                    completion(weight)
                } else {
                    completion(nil)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    
    func saveExerciseCompletionStatus(exercise: Exercise) {
        let defaults = UserDefaults.standard
        let key = "exerciseCompleted_\(exercise.id)"
        defaults.set(exercise.isComplete, forKey: key)
        print("Exercise \(exercise.name) completion status saved: \(exercise.isComplete)")
    }
    
    func isExerciseCompleted(exercise: Exercise) -> Bool {
        let defaults = UserDefaults.standard
        let key = "exerciseCompleted_\(exercise.id)"
        return defaults.bool(forKey: key)
    }
    
    func loadCompletionStatuses() {
        for dayIndex in workoutPlan.indices {
            for exerciseIndex in workoutPlan[dayIndex].indices {
                let exercise = workoutPlan[dayIndex][exerciseIndex]
                workoutPlan[dayIndex][exerciseIndex].isComplete = isExerciseCompleted(exercise: exercise)
            }
        }
    }
    
    func updateExerciseCompletionInDB(exercise: Exercise, dayIndex: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        let db = Firestore.firestore()
        let exerciseRef = db.collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
            .collection("Day\(dayIndex + 1)")
            .document(exercise.name)
        
        exerciseRef.updateData(["isComplete": exercise.isComplete]) { error in
            if let error = error {
                print("Error updating exercise completion status: \(error.localizedDescription)")
            } else {
                print("Exercise \(exercise.name) completion status updated successfully in Firestore.")
            }
        }
    }
    
    func countCompletedAndTotalExercises(dayIndex: Int, completion: @escaping (Int, Int) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in.")
            completion(0, 0)
            return
        }
        
        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
            .collection("Day\(dayIndex)")
        
        db.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching exercises: \(error.localizedDescription)")
                completion(0, 0)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No exercises found for Day \(dayIndex)")
                completion(0, 0)
                return
            }
            
            let totalExercises = documents.count
            let completedCount = documents.filter { ($0.data()["isComplete"] as? Bool) == true }.count
            
            print("Day \(dayIndex+1): Completed \(completedCount) / \(totalExercises)")
            completion(completedCount, totalExercises)
        }
    }
    
    
    func clearAllExerciseCompletionData() {
        let defaults = UserDefaults.standard
        
        // Iterate over all the keys in UserDefaults and remove those that start with "exerciseCompleted_"
        for (key, _) in defaults.dictionaryRepresentation() {
            if key.hasPrefix("exerciseCompleted_") {
                defaults.removeObject(forKey: key)
            }
        }
        
        print("Cleared all exercise completion data.")
    }
    
    
    func toggleFavoriteStatus(for exercise: Exercise) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in.")
            return
        }
        
        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document("favorites")
            .collection("exercises")
        
        let docRef = db.document(exercise.id)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking if exercise is favorited: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                docRef.delete { error in
                    if let error = error {
                        print("Error removing exercise from favorites: \(error.localizedDescription)")
                    } else {
                        print("Exercise removed from favorites")
                    }
                }
            } else {
                docRef.setData([
                    "name": exercise.name,
                    "id": exercise.id
                ]) { error in
                    if let error = error {
                        print("Error adding exercise to favorites: \(error.localizedDescription)")
                    } else {
                        print("Exercise added to favorites")
                    }
                }
            }
        }
    }
    
    
    func isExerciseFavorited(exercise: Exercise, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in.")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document("favorites")
            .collection("exercises")
            .document(exercise.id)
        
        db.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func deleteWorkoutPlan() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-'W'W"
        let formattedDate = dateFormatter.string(from: now)
        
        let db = Firestore.firestore()
        let workoutPlanDocRef = db
            .collection("users")
            .document(userID)
            .collection("workoutplan")
            .document(formattedDate)
        
        let group = DispatchGroup()
        for i in 1...7 {
            group.enter()
            workoutPlanDocRef.collection("Day\(i)").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching Day\(i) for deletion: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                let batch = db.batch()
                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { error in
                    if let error = error {
                        print("Error deleting exercises in Day\(i): \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted Day\(i)")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            workoutPlanDocRef.delete { error in
                if let error = error {
                    print("Error deleting workout plan document: \(error.localizedDescription)")
                } else {
                    print("Workout plan document deleted successfully.")
                    
                    UserDefaults.standard.removeObject(forKey: "workoutPlan")
                    UserDefaults.standard.removeObject(forKey: "workoutMetadata")
                    
                    DispatchQueue.main.async {
                        self.workoutPlan = []
                        self.workoutMetadata = [:]
                        self.isWorkoutPlanAvailable = false
                    }
                    
                }
            }
        }
    }
    
    
    
    func saveManuallyEnteredWorkout(
                name: String,
                type: String,
                exercises: [[String: Any]] = []
            ) {
                guard let userID = Auth.auth().currentUser?.uid else {
                    print("No user ID")
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-yyyy-'W'W"
                let formattedDate = dateFormatter.string(from: now)
                
                
                let db = Firestore.firestore()
                
                let workoutRef = db
                    .collection("users")
                    .document(userID)
                    .collection("manualWorkouts")
                    .document("\(formattedDate)-manual")

                var workoutData: [String: Any] = [
                    "name": name,
                    "type": type,
                ]
                
                if type == "Strength" {
                    workoutData["exercises"] = exercises
                }
                
                workoutRef.setData(workoutData) { error in
                    if let error = error {
                        print("Error saving manual workout: \(error.localizedDescription)")
                    } else {
                        print("Manual workout saved successfully.")
                    }
                }
            }
}



