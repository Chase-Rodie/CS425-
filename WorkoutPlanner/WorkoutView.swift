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
                    VStack(alignment: .leading, spacing: 20){
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("BackgroundColor"))
                                .frame(width: 370, height: 150)
                            
                            Text("Let's Workout!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                        }
                        
                        Button("delete"){
                            UserDefaults.standard.removeObject(forKey: "workoutPlan")
                                print("Workout plan successfully removed.")
                            hasWorkoutPlan = false
                           // workoutPlanModel.workoutPlan = []
                            //workoutPlanModel.resetWorkoutPlan()
                        }
                        
//                        Button("testing"){
//                            let testItem = Exercise(id: UUID().uuidString,
//                                                    category: "Strength",
//                                                    equipment: "Dumbbell",
//                                                    force: "Push",
//                                                    instructions: [
//                                                        "Stand upright with a dumbbell in each hand.",
//                                                        "Press the dumbbells overhead until your arms are fully extended.",
//                                                        "Lower the dumbbells back to shoulder level and repeat."
//                                                    ],
//                                                    level: "Beginner",
//                                                    mechanic: "Compound",
//                                                    name: "Dumbbell Shoulder Press",
//                                                    primaryMuscles: ["Deltoids"],
//                                                    secondaryMuscles: ["Triceps", "Upper Chest"])
//                            workoutPlanModel.saveWorkoutPlanDB(item: testItem)
//                            
//                            }

                        ZStack{
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("BackgroundColor"))
                                .frame(width: 370, height: 50)
                            
                            Text("Weekly Summary")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
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
                
    
            } else if isLoading {
                // Show loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                // Show GenerateWorkoutPlanView
                GenerateWorkoutPlanView(workoutPlanModel: workoutPlanModel, hasWorkoutPlan: $hasWorkoutPlan, isLoading: $isLoading)
            }
        }
        .onChange(of: hasWorkoutPlan) {
//            print("finally it works ")
//            if hasWorkoutPlan{
//                workoutPlanModel.loadWorkoutPlan()
//            }
        }
        
    }
    
    
    
    struct ExerciseRowView: View {
        let exercise: Exercise
        let workoutPlanModel: RetrieveWorkoutData

        var body: some View {
            HStack {
                if let firstImageURL = exercise.imageURLs.first, let url = URL(string: firstImageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                }
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
                    
                    weightEntryView()
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct GenerateWorkoutPlanView: View {
    //@ObservedObject var makeWPModel = RetrieveWorkoutData()
    @ObservedObject var workoutPlanModel: RetrieveWorkoutData
    @Binding var hasWorkoutPlan: Bool
    @Binding  var isLoading: Bool
    
    @State var days = 0
    let numDays = ["3", "4", "5"]
    
    
    @State var dur = 0
    let duration = ["30", "60"]
    
    @State var diff = 0
    let difficulty = ["Beginner", "Intermediate", "Expert"]
    
    
    
    
    var body: some View {
        
    
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("BackgroundColor"))
                    .frame(width: 370, height: 150)
                
                VStack {
                    Text("Good morning.")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    Text("You do not currently have a workout plan.")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    Text("Please fill out the form below to get one!")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                }
            }
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
                            workoutPlanModel.queryExercises(days: [
                                ("push", "chest"),
                                ("pull", "shoulders"),
                                ("pull", "glutes")
                            ], maxExercises: passMax, level: "beginner"){
                                
                                DispatchQueue.main.async {
                                    isLoading = false
                                    hasWorkoutPlan = true
                                }
                                print("Generated Workout Plan: \(workoutPlanModel.workoutPlan)")
                            }
                        }else if days == 1 {
                            print("4 days")
                            
                            workoutPlanModel.queryExercises(days: [
                                ("push", "chest"),
                                ("pull", "glutes"),
                                ("pull", "biceps"),
                                //had to change this temporarily!
                                ("pull", "biceps")
                            ], maxExercises: passMax, level: "beginner"){
                                
                                DispatchQueue.main.async {
                                    isLoading = false
                                    hasWorkoutPlan = true
                                }
                                print("Generated Workout Plan: \(workoutPlanModel.workoutPlan)")
                            }
                        }else if days == 2 {
                            print("5 days")
                            
                            workoutPlanModel.queryExercises(days: [
                                ("push", "chest"),
                                ("pull", "glutes"),
                                ("pull", "biceps"),
                                //had to change this temproarily!
                                ("pull", "biceps"),
                                ("push", "abdominals")
                            ], maxExercises: passMax, level: "beginner"){
                                
                                DispatchQueue.main.async {
                                    isLoading = false
                                    hasWorkoutPlan = true
                                }
                                print("Generated Workout Plan: \(workoutPlanModel.workoutPlan)")
                            }
                        }
                        
                        
                    }
                }
                
            }
        }
        
    
    }
}

struct weightEntryView: View{
    @State private var weight: String = ""
    var body: some View {
        VStack {
                    Text("Enter the weight used:")
                        .font(.headline)
                    
                    TextField("Weight in lbs", text: $weight)
                        .keyboardType(.decimalPad) // Use a numeric keyboard for weight input
                        .padding()
                        .background(Color(.systemGray6)) // Background style for the text field
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Text("You entered: \(weight) lbs")
                        .padding()
                    
                    Spacer()
                }
                .padding()
        
    }
}


struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
