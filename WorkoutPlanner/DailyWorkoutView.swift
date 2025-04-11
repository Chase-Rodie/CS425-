//
//  DailyWorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 4/1/25.
//

import SwiftUI

struct DailyWorkoutView: View {
    //var for day
    //@State var exercise: Exercise
    let dayIndex: Int
    let dayWorkoutPlan: [Exercise]
    let workoutPlanModel: RetrieveWorkoutData
    @State private var manualWorkoutFormShowing = false

    var body: some View {
        ScrollView{
            VStack{
                Spacer()
                
                Text("Day \(dayIndex + 1) ")
                        .foregroundColor(.green)
                        .font(.system(size: 36, weight: .bold))
                        .fontWeight(.bold)
              
                let muscleGroupKey = "muscleGroupDay\(dayIndex + 1)"
                Text("Muscle Groups: \(workoutPlanModel.workoutMetadata[muscleGroupKey] as? String ?? "")")
                Divider()
                    .background(Color.black)
                    .frame(width: 350)
               
                Button(action: {
                    manualWorkoutFormShowing = true
                }) {
                    HStack {
                        Text("Add My Own Workout")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 180, height: 25)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                } .sheet(isPresented: $manualWorkoutFormShowing){
                    AddWorkoutForm()
                }
                VStack(alignment: .leading){
                    ForEach(dayWorkoutPlan){exercise in
                        ExerciseRowView(exercise: exercise, workoutPlanModel: workoutPlanModel)
                    }
                }.padding()
               
            }
        }.accentColor(.green)
    }
}



struct ExerciseRowView: View {
    @State var exercise: Exercise
    let workoutPlanModel: RetrieveWorkoutData

    var body: some View {
        
        HStack {
            if let firstImageURL = exercise.imageURLs.first, let url = URL(string: firstImageURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
            }
            VStack(alignment: .leading) {
                NavigationLink(exercise.name, destination: DetailedExercise(exercise: exercise, workoutPlanModel: workoutPlanModel))
                Text("4 sets of 8 reps")
                Text("Weight: 30 lbs")
            }
            
            Image(systemName: workoutPlanModel.isExerciseCompleted(exercise: exercise) ? "checkmark.square" : "square")
                                        .foregroundColor(.green)
                                        .font(.system(size: 30))
        }
    }
}


struct DetailedExercise: View {
    var exercise: Exercise
    @ObservedObject var workoutPlanModel: RetrieveWorkoutData
    @State private var isStarFilled = false
    @State private var isFavorited: Bool = false


    var body: some View{
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 16){
                    
                    if let firstImageURL = exercise.imageURLs.first, let url = URL(string: firstImageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: 250)
                                .clipped()
                                .padding(.horizontal, 12)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    VStack{
                        HStack{
                            Text(exercise.name)
                                .font(.title)
                                .bold()
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                workoutPlanModel.toggleFavoriteStatus(for: exercise)
                                self.isFavorited.toggle()
                                    }) {
                                        Image(systemName: self.isFavorited ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 30))

                                    }
                        }
                        ForEach(0..<exercise.sets, id:\.self){ setIndex in
                            weightEntryView(exercise: exercise, workoutPlanModel: workoutPlanModel, setIndex: setIndex + 1)
                            
                        }
                        
                        HStack{
                                Text("Exercise done: ")
                                Image(systemName: workoutPlanModel.isExerciseCompleted(exercise: exercise) ? "checkmark.square" : "square")
                                    .foregroundColor(.green)
                                    .font(.system(size: 30))
                        }
                        
                        Button(action: {
                                                    workoutPlanModel.markComplete(for: exercise)
                                                }) {
                                                    HStack {
                                                        Text("Complete Exercise")
                                                                .font(.headline)
                                                                .foregroundColor(.white)
                                                                .padding()
                                                                .frame(width: 200, height: 50)
                                                                .background(Color.green)
                                                                .cornerRadius(10)
                                                    }
                                                }
                                                .padding(.vertical)
                    
                        
                        
                        Text("Instructions:")
                            .font(.headline)
                        ForEach(exercise.instructions, id:\.self){ step in
                            HStack(alignment: .top, spacing: 8){
                                Text("•")
                                    .font(.body)
                                    .frame(width: 20, alignment: .leading)
                                Text(step)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            workoutPlanModel.isExerciseFavorited(exercise: exercise) { isFavorited in
                self.isFavorited = isFavorited
            }
        }
    }
}



struct weightEntryView: View{
    @State private var reps: Int?
    @State private var weight: Int?
    var exercise: Exercise
    var workoutPlanModel: RetrieveWorkoutData
    var setIndex: Int
    var body: some View {
        HStack{
            Text("\(setIndex)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.green)
                .clipShape(Circle())
            
            TextField("Reps", value: $reps, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            
            TextField("Weight in lbs", value: $weight, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Spacer()
        }
                .padding()
                
            }
}


struct AddWorkoutForm: View{
    
    @State var workoutType = 0
    let workoutTypes = ["Strength", "Cardio", "Flexibility"]
    @State var workoutName: String = ""
    
    //For strength type
    @State var exercises = 0
    let numExercises = ["1", "2", "3", "4", "5"]
    let numberOptions = Array(1...15)
    @State private var setsList = Array(repeating: 0, count: 5)
    @State private var repsList = Array(repeating: 0, count: 5)
    @State private var exerciseNamesList: [String] = Array(repeating: "", count: 5)
    
    //For cardio type
//    @State var durationCardio: Int?
//    @State var distance: Int?
    
    //For Flexibility type
//    @State var durationFlex: Int?
   
    var body: some View{
        Form{
            Section(header: Text("Workout Type")){
                Picker("Type", selection: $workoutType){
                    ForEach(workoutTypes.indices, id: \.self){i in
                        Text(self.workoutTypes[i])
                    }
                } .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Workout Name")){
                TextField("Workout Name", text: $workoutName)
            }
            
            if workoutType == 0 {
                Section(header: Text("Number of Exercises:")){
                    Picker("Exercises", selection: $exercises){
                        ForEach(numExercises.indices, id: \.self){i in
                            Text(self.numExercises[i])
                        }
                    }
            
                }
                ForEach(0..<exercises+1, id: \.self){ i in
                    Section(header: Text("Exercise")){
                        TextField("Exercise Name", text: $exerciseNamesList[i])
                        Picker("Sets", selection: $setsList[i]) {
                            ForEach(numberOptions, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        Picker("Reps", selection: $repsList[i]) {
                                ForEach(numberOptions, id: \.self) {
                                    Text("\($0)")
                                }
                        }
                    }
                }
            }else if workoutType == 1{
                
                
        
                
            }else if workoutType == 2{

            }
            
            Section(header: Text("Submit"))
            {
                Button("Submit"){
                    
                }
            }
        }
        
    }
    
    
}
