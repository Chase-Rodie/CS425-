//
//  HomePageView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/29/24.
//  Edited by Heather Amistani on 03/29/2025
//

//Views:
//HomePageView
//ProgressView
//LogProgressView?

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct HomePageView: View {
    @EnvironmentObject var mealManager: TodayMealManager
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var retrieveworkoutdata = RetrieveWorkoutData()
    @State private var progressValues: [Double] = Array(repeating: 1, count: 7)
    @State private var selectedDate: Date = Date()
    @State private var stepCount: Int = 0
    @State private var stepGoal: Int = 10000
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
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        StepCountBar(steps: stepCount, goal: stepGoal)
                            .padding(.top, 20)
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        Text("Workout Progress")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(1..<7, id: \ .self) { dayIndex in
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
                        
                        Text("Today's Meals")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(MealType.allCases, id: \.self) { type in
                                    NavigationLink(destination: TodayMealView(
                                        selectedDate: selectedDate,
                                        mealType: type,
                                        meals: Binding(
                                            get: { mealManager.getMeals(for: selectedDate, type: type) },
                                            set: { mealManager.setMeals(for: selectedDate, type: type, meals: $0) }
                                        ),
                                        onRemove: { removedMeal in
                                            let amount = removedMeal.consumedAmount ?? 0
                                            updatePantryQuantity(docID: removedMeal.pantryDocID, amount: amount)
                                        }
                                    )) {
                                        VStack {
                                            Image(type.rawValue)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 150, height: 150)
                                            Text(type.rawValue)
                                                .foregroundColor(.black)                                        }
                                    }
                                }
                            }.padding(.horizontal)
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .onAppear {
                        fetchAllDaysProgress()
                        HealthKitManager.shared.fetchStepCount(for: Date()) { steps in
                            if let steps = steps {
                                DispatchQueue.main.async {
                                    self.stepCount = Int(steps)
                                }
                            }
                        }
                    }
                }
            }
            .accentColor(.background)
        }
    }

    private func updatePantryQuantity(docID: String, amount: Double) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No auth user found.")
            return
        }
        let docRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("pantry")
            .document(docID)

        docRef.updateData(["quantity": FieldValue.increment(amount)])
    }

    private func fetchAllDaysProgress() {
        for dayIndex in 0..<7 {
            retrieveworkoutdata.countCompletedAndTotalExercises(dayIndex: dayIndex) { completed, total in
                let progress = total > 0 ? Double(completed) / Double(total) : 0.0
                
                DispatchQueue.main.async {
                    
                    progressValues[dayIndex] = progress
                   // print("Updated Progress for Day \(dayIndex): \(progress * 100)%")
                }
            }
        }
    }
}
