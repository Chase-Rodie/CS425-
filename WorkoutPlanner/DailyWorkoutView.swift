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
        
    var body: some View {
        ScrollView{
            VStack{
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(Color("BackgroundColor"))
                        .frame(width: 350, height: 65)
                    Text("Day \(dayIndex + 1) ")
                }
                Text("Muscle Groups: Chest, Back, Biceps")
                VStack(alignment: .leading){
                    ForEach(dayWorkoutPlan){exercise in
                        ExerciseRowView(exercise: exercise, workoutPlanModel: workoutPlanModel)
                    }
                }.padding()
            }
        }
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
    @State private var isStarFilled = false // State variable to track the star's filled/empty state
    @State private var isFavorited: Bool = false


    var body: some View{
        ZStack{
//            LinearGradient(colors:[.background, .lighter], startPoint:  .top, endPoint: .bottom)
//                .ignoresSafeArea()
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
                                                                .font(.headline) // You can set the font style
                                                                .foregroundColor(.white) // Set the text color
                                                                .padding() // Add padding inside the button
                                                                .frame(width: 200, height: 50) // Set the size of the button
                                                                .background(Color.green) // Set the background color
                                                                .cornerRadius(10) // Optional: rounded corners)
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
            // Get the favorited status when the view appears
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




//#Preview {
//    DailyWorkoutView()
//}
