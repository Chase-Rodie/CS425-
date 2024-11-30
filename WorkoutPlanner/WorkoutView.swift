//
//  WorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/28/24.
//

import SwiftUI

struct WorkoutView: View {
    
    @ObservedObject var workoutPlanModel = RetrieveWorkoutData()
    @State private var hasWorkoutPlan: Bool = false
    
    var body: some View {
        NavigationView{
            if hasWorkoutPlan{
                ScrollView{
                    Text("Weekly Summary")
                    HStack{
                        
                    }
                    VStack(alignment: .leading, spacing: 20){
                        Button("delete"){
                            UserDefaults.standard.removeObject(forKey: "workoutPlan")
                            print("Workout Plan Deleted.")
                            hasWorkoutPlan = workoutPlanModel.loadWorkoutPlan()
                            }

                        
                        
                        ForEach(0..<workoutPlanModel.workoutPlan.count, id: \.self){
                            typeIndex in
                            let dayWorkoutPlan = workoutPlanModel.workoutPlan[typeIndex]
                            Text("Day \(typeIndex + 1): ")
                            
                            
                            ForEach(dayWorkoutPlan){exercise in
                                HStack{
                                    Image("workout")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                    VStack(alignment: .leading) {
                                        NavigationLink(exercise.name, destination: DetailedExercise(exercise: exercise))
                                            .font(.subheadline)
                                        Text("Primary Muscles: \(exercise.primaryMuscles.joined(separator: ", "))")
                                            .font(.footnote)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                }
                
    
            }  else{
                GenerateWorkoutPlanView(hasWorkoutPlan: $hasWorkoutPlan)
               
                
            }
        }
        .onAppear(){
            
            if workoutPlanModel.loadWorkoutPlan(){
                hasWorkoutPlan = true;
            }
               
        }
    }
      
    
    struct DetailedExercise: View {
        var exercise: Exercise
        var body: some View{
            ScrollView{
                VStack(alignment: .leading, spacing: 16){
                    Text(exercise.name)
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 8)
                    Text("Instructions:")
                        .font(.headline)
                    ForEach(exercise.instructions, id:\.self){ step in
                        HStack(alignment: .top){
                            Text("-")
                            Text(step)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

struct GenerateWorkoutPlanView: View {
    @ObservedObject var makeWPModel = RetrieveWorkoutData()
    @Binding var hasWorkoutPlan: Bool
    
    @State var days = 0
    let numDays = ["3", "4", "5"]
    
    
    @State var dur = 0
    let duration = ["30", "60"]
    
    @State var diff = 0
    let difficulty = ["Beginner", "Intermediate", "Expert"]
    
    
    
    
    var body: some View {
    
        Form{
            Section(header: Text("Workout Duration In Minutes")){
                Picker("Minutes", selection: $dur){
                    ForEach(duration.indices, id:\.self){i in                        Text(self.duration[i])
                    }
                }
            }
            Section(header: Text("Days Per Week")){
                Picker("Days", selection: $days){
                    ForEach(numDays.indices, id:\.self){i in                        Text(self.numDays[i])
                    }
                }
            }
            Section(header: Text("Difficulty")){
                Picker("Difficulty", selection: $diff){
                    ForEach(difficulty.indices, id:\.self){i in                        Text(self.difficulty[i])
                    }
                }
            }
            
            Section(header: Text("Get Workout Plan")){
                Button("Get Workout Plan"){
                    print("Generating Workout Plan")
//                    makeWPModel.queryExercises(days: [
//                        ("push", "chest"),
//                        ("pull", "shoulders"),
//                        ("pull", "chest")
//                    ], maxExercises: 5, level: "beginner")
//                    
//                    DispatchQueue.main.async {
//                            hasWorkoutPlan = true
//                        }
                    
                    //makeWPModel.queryExercises()
                    //need to have parameters of types, days, and difficulty & amount
                    //if time is 30: 3 exercises, 60: 4
                   // var queryDays: Int
//                    print(days)
                    
                    //0 in index is 3 days
                    if days == 0 {
                        print("3 days")
                        makeWPModel.queryExercises(days: [
                            ("push", "chest"),
                            ("pull", "shoulders"),
                            ("pull", "glutes")
                        ], maxExercises: 5, level: "beginner")
                        
                        DispatchQueue.main.async {
                                hasWorkoutPlan = true
                            }
    
                    }else if days == 1 {
                        print("4 days")
                        makeWPModel.queryExercises(days: [
                            ("push", "chest"),
                            ("pull", "glutes"),
                            ("pull", "biceps"),
                            ("push", "hamstrings")
                        ], maxExercises: 5, level: "beginner")
                        
                        DispatchQueue.main.async {
                                hasWorkoutPlan = true
                            }
                    }else if days == 2 {
                        print("5 days")
                        makeWPModel.queryExercises(days: [
                            ("push", "chest"),
                            ("pull", "glutes"),
                            ("pull", "biceps"),
                            ("push", "hamstrings"),
                            ("push", "abdominals")
                        ], maxExercises: 5, level: "beginner")
                        
                        DispatchQueue.main.async {
                                hasWorkoutPlan = true
                            }
                    }
                    

                }
            }
            
        }
        
    
    }
}



#Preview {
   WorkoutView()
}

