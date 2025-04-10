//
//  HomePageView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/29/24.
//

//Views:
//HomePageView
//ProgressView
//LogProgressView?


import SwiftUI

struct HomePageView: View {
    
    @ObservedObject var retrieveworkoutdata = RetrieveWorkoutData()
    @Binding var showMenu: Bool
    //@State private var currentProgress: Double = 0.5
    //@State private var currentProgress: Double = 0.0
    @State private var progressValues: [Double] = Array(repeating: 1, count: 7)
    @State private var selectedDate: Date = Date()
    let dayIndex: Int = 1
    
    
    var body: some View {
        
        NavigationView{
            ScrollView{
                VStack(alignment: .leading, spacing: 80){
                    
                    HStack{
                        Button(action: {
                            withAnimation{
                                self.showMenu = true
                            }
                        }){
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                            
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                }
                VStack(alignment: .center, spacing: 20){
                    ZStack{
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("BackgroundColor"))
                            .frame(width: 370, height: 150)
                        
                        Text("Welcome to Fit Pantry!")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                    }
                    
                    Text("Workout Progress")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    HStack{
                        ScrollView(.horizontal){
                            HStack {
                                ForEach(1..<7, id: \.self) { dayIndex in
                                    VStack(spacing: 20) {
                                        NavigationLink(destination: ProgressView()) {
                                            ProgressRingView(progress: progressValues[dayIndex], ringWidth: 15)
                                                .padding()
                                                .background(Color("BackgroundColor"))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        Text("Day \(dayIndex)")
                                                                }
                                                            }
                            }.padding(.leading, 20)
                        }
                    }
                        
                        Text("Today's Meals")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        ScrollView(.horizontal){
                            HStack{
                                NavigationLink(destination: ProgressView()){
                                    Image("Breakfast")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                }
                                NavigationLink(destination: ProgressView()){
                                    Image("Lunch")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                }
                                NavigationLink(destination: ProgressView()){
                                    Image("Dinner")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                }
                            }
                        }
                        NavigationLink("Progress Calendar", destination: ProgressTrackerView())
                            .font(.largeTitle)
                    }
                .onAppear {
                    fetchAllDaysProgress()
                }
                }
                
            }.accentColor(.background)
            
        }
    private func fetchAllDaysProgress() {
        for dayIndex in 1..<7 { // Loop through all days
            retrieveworkoutdata.countCompletedAndTotalExercises(dayIndex: dayIndex) { completed, total in
                let progress = total > 0 ? Double(completed) / Double(total) : 0.0
                
                DispatchQueue.main.async {
                    // Update only the specific index in the array
                    self.progressValues[dayIndex] = progress
                    print("Updated Progress for Day \(dayIndex): \(progress * 100)%")
                }
            }
        }
    }
   
    }
    
    
//    
//    struct ProgressView: View {
//        var body: some View {
//            VStack{
//                Text("Progress View")
//            }
//            
//        }
//    }
//
