//
//  DailyWorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 12/5/24.
//This view will show one day of exercises. This view should be called by the weekly summary view

import SwiftUI

struct DailyWorkoutView: View {
    @StateObject var workoutPlanModel = RetrieveWorkoutData()
    
    var body: some View {
        ForEach(0..<workoutPlanModel.workoutPlan.count, id: \.self){
            typeIndex in
            let dayWorkoutPlan = workoutPlanModel.workoutPlan[typeIndex]
            Text("Day \(typeIndex + 1): ")
            
            
            ForEach(dayWorkoutPlan){exercise in
                HStack {
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        NavigationLink(exercise.name, destination: IndividualExercise(exercise: exercise))
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
    }
    
    struct IndividualExercise: View {
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
    


struct DailyWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        DailyWorkoutView()
    }
}
