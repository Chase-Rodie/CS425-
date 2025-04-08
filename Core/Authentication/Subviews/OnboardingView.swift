//
//  OnboardingView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 3/27/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct OnboardingView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var currentStep: Int = 0
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String = ""
    @State private var fitnessLevel: String = ""
    @State private var goal: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @Binding var showSignInView: Bool
    @State private var onboardingComplete = false

    var body: some View {
        VStack {
            if currentStep == 0 {
                WelcomeStep()
            } else if currentStep == 1 {
                NameStep(name: $name)
            } else if currentStep == 2 {
                AgeStep(age: $age)
            } else if currentStep == 3 {
                GenderStep(gender: $gender)
            } else if currentStep == 4 {
                FitnessLevelStep(fitnessLevel: $fitnessLevel)
            } else if currentStep == 5 {
                GoalStep(goal: $goal)
            } else if currentStep == 6 {
                HeightStep(height: $height)
            } else if currentStep == 7 {
                WeightStep(weight: $weight)
            } else {
                CompletionStep()
            }
            
            Button(action: nextStep) {
                Text(currentStep < 8 ? "Next" : "Finish")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            print("OnboardingView Appeared")
            loadUserData()
        }
    }
    
    private func nextStep() {
        print("Next button tapped - currentStep: \(currentStep)")

        if currentStep < 7 {
            currentStep += 1
            print("Moved to step: \(currentStep)")
        } else if currentStep == 7 {
            currentStep += 1
            print("Moved to step: \(currentStep) - Showing CompletionStep")
        } else if currentStep == 8 {
            guard !onboardingComplete else { return }
            onboardingComplete = true

            print("Calling saveUserData()")
            Task {
                await saveUserData()
            }
        }
    }

    private func loadUserData() {
        if let user = userManager.currentUser {
            name = user.name ?? ""
            age = user.age.map { String($0) } ?? ""
            gender = user.gender ?? ""
            fitnessLevel = user.fitnessLevel ?? ""
            goal = user.goal ?? ""
            height = user.height ?? ""
            weight = user.weight ?? ""
        }
    }
    
    @MainActor
    func saveUserData() async {
        print("saveUserData() STARTED")

        for _ in 0..<3 {
            await userManager.fetchCurrentUser()
            if userManager.currentUser != nil { break }
            print("Retrying fetchCurrentUser...")
            try? await Task.sleep(nanoseconds: 900_000_000)
        }

        guard let currentUser = userManager.currentUser else {
            print("Still no currentUser after multiple fetch attempts")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.userId)
        let profileRef = userRef.collection("UserInformation").document("profile")

        let userData: [String: Any] = [
            "name": name.isEmpty ? currentUser.name ?? "" : name,
            "age": Int(age) ?? currentUser.age ?? 0,
            "gender": gender.isEmpty ? currentUser.gender ?? "" : gender,
            "fitnessLevel": fitnessLevel.isEmpty ? currentUser.fitnessLevel ?? "" : fitnessLevel,
            "goal": goal.isEmpty ? currentUser.goal ?? "" : goal,
            "height": height.isEmpty ? currentUser.height ?? "" : height,
            "weight": weight.isEmpty ? currentUser.weight ?? "" : weight,
            "dateCreated": currentUser.dateCreated ?? Timestamp(date: Date()),
            "isAnonymous": currentUser.isAnonymous ?? false,
            "email": currentUser.email ?? ""
        ]

        do {
            try await profileRef.setData(userData)
            print("User data successfully saved in subcollection")

            await MainActor.run {
                showSignInView = false
                onboardingComplete = true
            }
        } catch {
            print("Failed to save user data: \(error.localizedDescription)")
        }
    }


}

struct WelcomeStep: View {
    var body: some View {
        Text("Welcome to Fit Pantry! Let’s set up your profile.")
            .font(.title)
            .multilineTextAlignment(.center)
    }
}

struct NameStep: View {
    @Binding var name: String
    var body: some View {
        VStack {
            Text("Enter your name")
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct AgeStep: View {
    @Binding var age: String
    var body: some View {
        VStack {
            Text("Enter your age")
            TextField("Age", text: $age)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
        }
        .padding()
    }
}

struct GenderStep: View {
    @Binding var gender: String
    var body: some View {
        VStack {
            Text("Enter your gender")
            TextField("Gender", text: $gender)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct FitnessLevelStep: View {
    @Binding var fitnessLevel: String
    var body: some View {
        VStack {
            Text("Select your fitness level")
            Picker("Fitness Level", selection: $fitnessLevel) {
                Text("Beginner").tag("Beginner")
                Text("Intermediate").tag("Intermediate")
                Text("Advanced").tag("Advanced")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
    }
}

struct GoalStep: View {
    @Binding var goal: String
    var body: some View {
        VStack {
            Text("Enter your fitness goal")
            TextField("Goal", text: $goal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct HeightStep: View {
    @Binding var height: String
    var body: some View {
        VStack {
            Text("Enter your height")
            TextField("Height", text: $height)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct WeightStep: View {
    @Binding var weight: String
    var body: some View {
        VStack {
            Text("Enter your weight")
            TextField("Weight", text: $weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct CompletionStep: View {
    var body: some View {
        Text("You're all set! Enjoy Fit Pantry.")
            .font(.title)
            .multilineTextAlignment(.center)
    }
}

