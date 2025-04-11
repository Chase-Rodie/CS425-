//
//  GoalsView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 3/7/25.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    var user: UserMeal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Daily Goals")
                .font(.title)
                .bold()
            
            if let targets = viewModel.dailyTargets {
                goalRow(title: "Calories", value: "\(targets.calories) kcal")
                goalRow(title: "Protein", value: "\(targets.protein) g")
                goalRow(title: "Fats", value: "\(targets.fats) g")
                goalRow(title: "Carbs", value: "\(targets.carbs) g")
            } else {
                Text("Loading your targets...")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.updateDailyTargets(for: user)
    }
}
    
    func goalRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    GoalsView(user: UserMeal(
        age: 24,
        weightInLbs: 160,
        heightInFeet: 5,
        heightInInches: 10,
        gender: "Male",
        dietaryRestrictions: [],
        goal: "Gain Weight",
        activityLevel: "Active",
        mealPreferences: []
    ))
}
