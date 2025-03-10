//
//  WorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/28/24.
//

import SwiftUI

struct WorkoutView: View {
    
    @StateObject var workoutPlanModel = RetrieveWorkoutData()
    @State private var hasWorkoutPlan: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView{
            
            if hasWorkoutPlan && !isLoading{
                ScrollView{
                    
                    Text("Weekly Summary")
                    HStack{
                        
                    }
                    VStack(alignment: .leading, spacing: 20){
                        Button("delete"){
                            UserDefaults.standard.removeObject(forKey: "workoutPlan")
                                print("Workout plan successfully removed.")
                            hasWorkoutPlan = false
                           // workoutPlanModel.workoutPlan = []
                            //workoutPlanModel.resetWorkoutPlan()
                           
                            
                            }

                        
                        
                        ForEach(0..<workoutPlanModel.workoutPlan.count, id: \.self){
                            typeIndex in
                            let dayWorkoutPlan = workoutPlanModel.workoutPlan[typeIndex]
                            Text("Day \(typeIndex + 1): ")
                            
                            
                            ForEach(dayWorkoutPlan){exercise in
                                ExerciseRowView(exercise: exercise, workoutPlanModel: workoutPlanModel)
                            }
                        }
                    }
                    
                }
                
    
            }  else{
                GenerateWorkoutPlanView(hasWorkoutPlan: $hasWorkoutPlan, isLoading: $isLoading)
               
                
            }
        }
        .onChange(of: hasWorkoutPlan) {
            print("finally it works ")
            if hasWorkoutPlan && workoutPlanModel.workoutPlan.isEmpty {
                workoutPlanModel.loadWorkoutPlan()
            }
        }
        
    }
    
    
    
    struct ExerciseRowView: View {
        let exercise: Exercise
        let workoutPlanModel: RetrieveWorkoutData

        var body: some View {
            HStack {
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
                Button(action: { workoutPlanModel.markComplete(for: exercise) }) {
                    Image(systemName: exercise.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(exercise.isComplete ? .green : .gray)
                }
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
    @Binding  var isLoading: Bool
    
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
                    isLoading = true
                    var passMax: Int = 0
                    
                    if dur == 0{
                        passMax = 3
                    }else{
                        passMax = 5
                    }
                    
                    
                    if days == 0 {
                        print("3 days")
                        makeWPModel.queryExercises(days: [
                            ("push", "chest"),
                            ("pull", "shoulders"),
                            ("pull", "glutes")
                        ], maxExercises: passMax, level: "beginner")
                        
                        DispatchQueue.main.async {
                                isLoading = false
                                hasWorkoutPlan = true
                            }
                        print("Generated Workout Plan: \(makeWPModel.workoutPlan)")
    
                    }else if days == 1 {
                        print("4 days")
                       
                        makeWPModel.queryExercises(days: [
                            ("push", "chest"),
                            ("pull", "glutes"),
                            ("pull", "biceps"),
                            ("push", "hamstrings")
                        ], maxExercises: passMax, level: "beginner")
                        
                        DispatchQueue.main.async {
                                isLoading = false
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
                        ], maxExercises: passMax, level: "beginner")
                        
                        DispatchQueue.main.async {
                                isLoading = false
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

