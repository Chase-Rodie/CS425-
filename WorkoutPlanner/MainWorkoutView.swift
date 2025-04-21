//
//  MainWorkoutView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 3/16/25.
//

import SwiftUI

struct MainWorkoutView: View {
    @StateObject private var viewModel = RetrieveWorkoutData()
    @State private var hasAppeared = false
    @State private var userGoal: Goal? = nil

    
    var body: some View {
        Group{
            if viewModel.isWorkoutPlanAvailable{
                WeeklyWorkoutView(workoutPlanModel: viewModel)
            } else {
                GetWorkoutPlanView(workoutPlanModel: viewModel)
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true

            viewModel.workoutPlanExists { exists in
                DispatchQueue.main.async {
                    viewModel.isWorkoutPlanAvailable = exists
                    if let goal = UserManager.shared.currentUser?.profile.goal {
                        self.userGoal = goal
                    }
                    if exists {
                        viewModel.fetchWorkoutPlan()
             
                    }
                }
            }
        }
    }
}


struct GetWorkoutPlanView: View {
    @ObservedObject var workoutPlanModel: RetrieveWorkoutData
    @State var days = 0
    let numDays = ["3", "4", "5"]
    @State var dur = 0
    let duration = ["30", "60"]
    @State var diff = 0
    let difficulty = ["Beginner", "Intermediate", "Expert"]
    
    var userAge: Int {
        return UserManager.shared.currentUser?.profile.age ?? 25
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.background, .lighter], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("You do not currently have a workout plan.")
                    .fontWeight(.semibold)
                Text("Please fill out the form below to get one!")
                    .fontWeight(.semibold)

                VStack {
                    Picker("Minutes", selection: $dur) {
                        ForEach(duration.indices, id: \.self) { i in
                            Text(self.duration[i])
                        }
                    }.pickerStyle(.segmented)

                    Picker("Days", selection: $days) {
                        ForEach(numDays.indices, id: \.self) { i in
                            Text(self.numDays[i])
                        }
                    }.pickerStyle(.segmented)

                    Picker("Difficulty", selection: $diff) {
                        ForEach(difficulty.indices, id: \.self) { i in
                            Text(self.difficulty[i])
                        }
                    }.pickerStyle(.segmented)

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: 200, height: 25)
                        
                        Button("Get Workout Plan") {
                            print("Generating Workout Plan")
                            
                            let goalString = workoutPlanModel.userGoal?.rawValue.lowercased() ?? "lose"
                            var passMax: Int = 0
                            
                            if dur == 0 {
                                passMax = (goalString == "gain") ? 5 : 3
                            } else {
                                passMax = (goalString == "gain") ? 7 : 5
                            }

                            if days == 0 {
                                print("3 days")
                                workoutPlanModel.queryExercises(
                                    days: [
                                        ("push", ["chest", "shoulders", "triceps"]),
                                        ("pull", ["back", "biceps", "abdominals"]),
                                        ("pull", ["glutes", "quadriceps", "calves", "hamstrings"])
                                    ],
                                    maxExercises: passMax,
                                    level: "beginner",
                                    goal: goalString,
                                    age: userAge 
                                ) {
                                    // Completion block if needed
                                }
                            } else if days == 1 {
                                print("4 days")
                                workoutPlanModel.queryExercises(
                                    days: [
                                        ("push", ["chest", "triceps"]),
                                        ("pull", ["back", "biceps"]),
                                        ("pull", ["glutes", "quadriceps", "calves", "hamstrings"]),
                                        ("pull", ["shoulders", "abdominals"])
                                    ],
                                    maxExercises: passMax,
                                    level: "beginner",
                                    goal: goalString,
                                    age: userAge
                                ) {
                                    // Completion block if needed
                                }
                            } else if days == 2 {
                                print("5 days")
                                workoutPlanModel.queryExercises(
                                    days: [
                                        ("push", ["chest", "shoulders", "triceps"]),
                                        ("pull", ["glutes", "quadriceps", "calves", "hamstrings"]),
                                        ("pull", ["back", "biceps", "abdominals"]),
                                        ("pull", ["calves", "hamstrings"]),
                                        ("pull", ["quadriceps", "shoulders", "hamstrings"])
                                    ],
                                    maxExercises: passMax,
                                    level: "beginner",
                                    goal: goalString,
                                    age: userAge
                                ) {
                                    workoutPlanModel.isWorkoutPlanAvailable = true
                                }
                            }
                        }
                        .foregroundColor(.black)

                    }
                }
                .padding()
            }
        }
    }
}



#Preview {
    MainWorkoutView()
}
