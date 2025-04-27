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
                                            let restoredAmountInPantryUnits = removedMeal.actualConsumedPantryAmount ?? 0.0

                                            print("Restoring \(restoredAmountInPantryUnits) \(removedMeal.unit ?? "g") for \(removedMeal.name) (saved consumed pantry amount)")

                                            if !removedMeal.pantryDocID.isEmpty {
                                                updatePantryQuantity(docID: removedMeal.pantryDocID, amount: restoredAmountInPantryUnits)
                                            } else {
                                                print("⚠️ pantryDocID is empty for meal: \(removedMeal.name)")
                                            }

                                            removeMealFromFirestore(removedMeal, for: selectedDate, type: type) {
                                                Task {
                                                    await mealManager.restoreMeals(for: selectedDate) {
                                                        print("Meals refreshed after deletion")
                                                    }
                                                }
                                            }
                                        }
                                    )
                                        .environmentObject(mealManager)
                                    ) {
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
//                    .onAppear {
//                        fetchAllDaysProgress()
//                        HealthKitManager.shared.fetchStepCount(for: Date()) { steps in
//                            if let steps = steps {
//                                DispatchQueue.main.async {
//                                    self.stepCount = Int(steps)
//                                }
//                            }
//                        }
//                    }
                    .onAppear {
                        fetchAllDaysProgress()

                        HealthKitManager.shared.requestAuthorization { success in
                            if success {
                                print("HealthKit authorized")
                                HealthKitManager.shared.fetchStepCount(for: Date()) { steps in
                                    if let steps = steps {
                                        DispatchQueue.main.async {
                                            self.stepCount = Int(steps)
                                            print("Step count fetched: \(steps)")
                                        }
                                    } else {
                                        print("Failed to fetch step count")
                                    }
                                }
                            } else {
                                print("Failed to authorize HealthKit")
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
    
    private func removeMealFromFirestore(_ meal: MealPlanner, for date: Date, type: MealType, completion: @escaping () -> Void){
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let logRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("mealLogs")
            .document(dateString)

        logRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  var array = data[type.rawValue.lowercased()] as? [[String: Any]] else {
                print("Could not get array to update or data is missing")
                return
            }

            array.removeAll {
                ($0["foodID"] as? String == meal.foodID) &&
                ($0["name"] as? String == meal.name)
            }

            logRef.updateData([
                type.rawValue.lowercased(): array
            ]) { error in
                if let error = error {
                    print("Error updating Firestore: \(error.localizedDescription)")
                } else {
                    print("Removed from Firestore successfully")
                }
                completion()
            }
        }
    }
}
