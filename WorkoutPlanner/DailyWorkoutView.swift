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
               // NavigationLink(exercise.name, destination: DetailedExercise(exercise: exercise, workoutPlanModel: workoutPlanModel))
                 //   .font(.subheadline)
                Text(exercise.name)
                Text("4 sets of 8 reps")
                Text("Weight: 30 lbs")
            }
            Button(action: {
                workoutPlanModel.markComplete(for: exercise)
                exercise.isComplete.toggle()
            }) {
                Image(systemName: exercise.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(exercise.isComplete ? .green : .gray)
            }
        }
    }
}


//#Preview {
//    DailyWorkoutView()
//}
