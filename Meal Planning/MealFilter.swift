//
//  MealFilter.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 4/19/25.
//

import Foundation

struct MealFilter {
    static func filterMeals(
        meals: [MealPlanner],
        goal: Goal,
        dietaryPreferences: [String]
    ) -> [MealPlanner] {
        return meals.filter { meal in
            let matchesPreferences = dietaryPreferences.allSatisfy {
                meal.dietaryTags.contains($0)
            }
            let matchesGoal: Bool
            switch goal {
            case .loseWeight:
                matchesGoal = meal.calories <= 500 && meal.fat <= 20
            case .gainWeight:
                matchesGoal = meal.calories >= 600 && meal.protein >= 20
            case .maintainWeight:
                matchesGoal = (450...650).contains(meal.calories)
            }

            return matchesPreferences && matchesGoal
        }
    }
}
