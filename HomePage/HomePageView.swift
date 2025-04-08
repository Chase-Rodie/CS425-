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
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var retrieveworkoutdata = RetrieveWorkoutData()
    @State private var progressValues: [Double] = Array(repeating: 1, count: 7)
    @State private var selectedDate: Date = Date()
    @Binding var showSignInView: Bool
    let dayIndex: Int = 1
    
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Text("Fit Pantry")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    
                    NavigationLink(destination: ProfileView(showSignInView: $showSignInView)) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                ScrollView {
                    VStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.getWeightChange())
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("Workout Progress")
                                .font(.largeTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 10) {
                                    ForEach(1..<7, id: \.self) { dayIndex in
                                        VStack(spacing: 10) {
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
                                }
                                .padding(.leading, 20)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Meals")
                                .font(.largeTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 10) {
                                    NavigationLink(destination: ProgressView()) {
                                        Image("Breakfast")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150, height: 150)
                                    }
                                    NavigationLink(destination: ProgressView()) {
                                        Image("Lunch")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150, height: 150)
                                    }
                                    NavigationLink(destination: ProgressView()) {
                                        Image("Dinner")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150, height: 150)
                                    }
                                }
                            }
                        }

                        NavigationLink("Progress Calendar", destination: ProgressTrackerView())
                            .font(.largeTitle)
                    }
                    .navigationBarBackButtonHidden(true)
                    .onAppear {
                        fetchAllDaysProgress()
                    }
                }
            }
            .accentColor(.background)
        }

    private func fetchAllDaysProgress() {
        for dayIndex in 1..<7 {
            retrieveworkoutdata.countCompletedAndTotalExercises(for: selectedDate, dayIndex: dayIndex) { completed, total in
                let progress = total > 0 ? Double(completed) / Double(total) : 0.0
                
                DispatchQueue.main.async {
                    self.progressValues[dayIndex] = progress
                    print("Updated Progress for Day \(dayIndex): \(progress * 100)%")
                }
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(showSignInView: .constant(false))
    }
}
