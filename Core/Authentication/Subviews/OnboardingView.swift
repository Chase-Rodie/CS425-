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
                    .background(Color.background)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func nextStep() {

        if currentStep < 7 {
            currentStep += 1
        } else if currentStep == 7 {
            currentStep += 1
        } else if currentStep == 8 {
            guard !onboardingComplete else { return }
            onboardingComplete = true

            Task {
                await saveUserData()
            }
        }
    }

    private func loadUserData() {
        if let user = userManager.currentUser {
            name = user.profile.name ?? ""
            age = user.profile.age.map { String($0) } ?? ""
            gender = user.profile.gender?.rawValue ?? ""
            fitnessLevel = user.profile.fitnessLevel?.rawValue ?? ""
            goal = user.profile.goal?.rawValue ?? ""
            height = user.profile.height ?? ""
            weight = user.profile.weight ?? ""
        }
    }
    
    @MainActor
    func saveUserData() async {

        guard let authUser = Auth.auth().currentUser else {
            print("No Firebase user found")
            return
        }

        guard let parsedAge = Int(age) else {
            print("Invalid age entered")
            return
        }

        let parsedGender = Gender(rawValue: gender)
        let parsedFitnessLevel = FitnessLevel(rawValue: fitnessLevel)
        let parsedGoal = Goal(rawValue: goal)

        let metadata = UserMetadata(
            userId: authUser.uid,
            email: authUser.email,
            isAnonymous: authUser.isAnonymous,
            photoUrl: authUser.photoURL?.absoluteString,
            dateCreated: Date()
        )

        let profile = UserProfile(
            name: name,
            age: parsedAge,
            gender: parsedGender,
            fitnessLevel: parsedFitnessLevel,
            goal: parsedGoal,
            height: height,
            weight: weight,
            profileImagePath: nil,
            profileImagePathUrl: nil
        )

        let newUser = DBUser(metadata: metadata, profile: profile)
                
        do {
            try await userManager.createNewUser(user: newUser)
            await userManager.fetchCurrentUser()
        } catch {
            print("Error creating new user: \(error)")
        }

        await MainActor.run {
            showSignInView = false
            onboardingComplete = true
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
            Picker("Fitness Goal", selection: $goal) {
                Text("Lose Weight").tag("LoseWeight")
                Text("Gain Weight").tag("GainWeight")
                Text("Maintain Weight").tag("MaintainWeight")
            }
            .pickerStyle(SegmentedPickerStyle())
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

