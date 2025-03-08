//
//  ReworkedWorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 3/8/25.
//

import SwiftUI

struct ReworkedWorkoutView: View {
    
    @StateObject var workoutPlanModel = RetrieveWorkoutData()
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView{
            Text("Weekly Summary")
            Text("4 Working Days, 3 Rest Days")
            VStack{
                HStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    VStack(alignment: .leading){
                        Text("Day 1")
                        Text("Target Muscle Groups: Chest, Back, Biceps")
                        Text("5 Exercises")
                    }
                } .padding()
                HStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    VStack(alignment: .leading){
                        Text("Day 1")
                        Text("Target Muscle Groups: Chest, Back, Biceps")
                        Text("5 Exercises")
                    }
                } .padding()
                HStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    VStack(alignment: .leading){
                        Text("Day 1")
                        Text("Target Muscle Groups: Chest, Back, Biceps")
                        Text("5 Exercises")
                    }
                } .padding()
                HStack{
                    Image("workout")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    VStack(alignment: .leading){
                        Text("Day 1")
                        Text("Target Muscle Groups: Chest, Back, Biceps")
                        Text("5 Exercises")
                    }
                } .padding()
            }
        }
    }
}

#Preview {
    ReworkedWorkoutView()
}
