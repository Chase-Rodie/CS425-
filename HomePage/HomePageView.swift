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
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var progressValues: [Double] = Array(repeating: 1, count: 7)
    @State private var selectedDate: Date = Date()
    @Binding var showSignInView: Bool
    let dayIndex: Int = 1
    
    var body: some View {
        NavigationView {
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

                // 📌 Workout Progress starts here (below weight progress)
                ScrollView {
                    VStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 10) {
                            if let weightDiff = profileViewModel.weightDifference {
                                if weightDiff > 0 {
                                    Text("Weight Gained: \(weightDiff) lbs")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .padding(.leading, 15)
                                } else if weightDiff < 0 {
                                    Text("Weight Lost: \(-weightDiff) lbs")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .padding(.leading, 15)
                                } else {
                                    Text("Weight Stable")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 15)
                                }
                            } else {
                                Text("Weight Progress: -")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
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
                    .onAppear {
                        Task {
                           await profileViewModel.fetchUserProfile()
                            print("Debug: weightDifference is \(profileViewModel.weightDifference ?? 0)")

                        }
                        fetchAllDaysProgress()
                    }
                }
            }
            .accentColor(.background)
        }
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
        HomePageView(profileViewModel: ProfileViewModel(), showSignInView: .constant(false))
    }
}
