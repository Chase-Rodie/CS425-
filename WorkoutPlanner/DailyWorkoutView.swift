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


struct DetailedExercise: View {
    var exercise: Exercise
    @ObservedObject var workoutPlanModel: RetrieveWorkoutData

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
                
                weightEntryView(exercise: exercise, workoutPlanModel: workoutPlanModel)
            }
            .padding(.horizontal, 16)
        }
    }
}


//#Preview {
//    DailyWorkoutView()
//}
