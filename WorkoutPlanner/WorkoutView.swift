//
//  WorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon
//  This will be the first view when the user selects "workout" on the navigation menu

import SwiftUI
import Foundation
import FirebaseFirestore



struct WorkoutView: View {
    @ObservedObject var exerciseModel = RetrieveWorkoutData()
    
    var body: some View {
    
//Horizontal stack for weekly list/view.
        VStack{
    
            if let exercise = exerciseModel.exercise{
                Text("Name: \(exercise.name)")
            } else {
                Text("Failed")
            }
            
            Button("hello"){
                print("test")
            }

            Text("Weekly Summary")
            HStack(alignment: .top){
                VStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    Text("Legs")
                }
                VStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    Text("Legs")
                }
                VStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    Text("Legs")
                }
                VStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    Text("Legs")
                }
                VStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    Text("Legs")
                }
                
            }
        }
        .padding()
    //Vertical stack for daily list/view.
        
        VStack(alignment: .leading){
            Text("Today's Workout ")
                .font(.title)
            
            Text("4 Exercises")
            HStack {
                
                Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                VStack(alignment: .leading) {
                    Text("Exercise 1")
                    Text("4 Sets, 12 Reps, 25 Lbs")
                }
                Spacer()
                    .frame(width: 50)
                Image(systemName: "checkmark.circle.fill")
                    .scaleEffect(2)
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.green)
                Spacer()
                    .frame(width: 40)
            }
            HStack {
                Image("workout")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                VStack(alignment: .leading) {
                    Text("Exercise 2")
                    Text("4 Sets, 12 Reps, 25 Lbs")
                }
                Spacer()
                    .frame(width: 50)
                Image(systemName: "checkmark.circle.fill")
                    .scaleEffect(2)
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.green)
                Spacer()
                    .frame(width: 40)
                
            }
            HStack {
                Image("workout")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                VStack(alignment: .leading) {
                    Text("Exercise 3")
                    Text("4 Sets, 12 Reps, 25 Lbs")
                }
                Spacer()
                    .frame(width: 100)
            }
            
        }
    }
    
    init(){
        exerciseModel.queryExercises()
    
    }
    
}

#Preview {
    WorkoutView()
}
