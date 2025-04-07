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
    
    
    //may need to move to other view 
    var progress: Double = 0.7 // Progress value between 0.0 and 1.0
    var ringColor: Color = Color("LighterColor")
    var ringWidth: CGFloat = 10.0
    
    var body: some View {
        ZStack{
//            LinearGradient(colors:[.background, .lighter], startPoint:  .top, endPoint: .bottom)
//                .ignoresSafeArea()
            ScrollView{
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(Color("BackgroundColor"))
                        .frame(width: 350, height: 65)
                    
                    Text("Weekly Summary")
                        .foregroundColor(.white)
                        .font(.system(size: 36, weight: .bold))
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .leading){
                    Text("4 Working Days, 3 Rest Days")
                    Button("delete"){
                        UserDefaults.standard.removeObject(forKey: "workoutPlan")
                        print("Workout plan successfully removed.")
                        //  hasWorkoutPlan = false
                        // workoutPlanModel.workoutPlan = []
                        //workoutPlanModel.resetWorkoutPlan()
                        workoutPlanModel.isWorkoutPlanAvailable = false

                    }
                }
                VStack{
                    ForEach(0..<workoutPlanModel.workoutPlan.count, id: \.self){
                        typeIndex in
                        let dayWorkoutPlan = workoutPlanModel.workoutPlan[typeIndex]
                        VStack{
                            HStack{
                                VStack(alignment: .leading){
                                NavigationLink(destination: DailyWorkoutView(dayIndex: typeIndex, dayWorkoutPlan: dayWorkoutPlan, workoutPlanModel: workoutPlanModel)){
                                    Text("Day \(typeIndex + 1)")
                                        .font(.system(size: 30, weight: .bold))
                                        .fontWeight(.bold)
                                }
                                    
        
                                    Text("5 Exercises")
                                }
                                ZStack {
                                    // Background Circle (empty ring)
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: ringWidth)
                                    
                                    // Foreground Circle (progress)
                                    Circle()
                                        .trim(from: 0.0, to: progress)
                                        .stroke(ringColor, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                                        .rotationEffect(.degrees(-90)) // Start from the top
                                        .animation(.easeInOut, value: progress)
                                    
                                    // Text (shows progress as percentage)
                                    Text("\(Int(progress * 100))%")
                                        .font(.headline)
                                        .bold()
                                }
                                .frame(width: 100, height: 100)
                                
                               
                            } .padding()
                          
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    ReworkedWorkoutView()
}
