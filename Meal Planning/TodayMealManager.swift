//
//  TodayMealManager.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/28/25.
//

import SwiftUI

class TodayMealManager: ObservableObject {
    @Published var mealsByDate: [String: [MealType: [MealPlanner]]] = [:]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func getMeals(for date: Date, type: MealType) -> [MealPlanner] {
        let dateString = dateFormatter.string(from: date)
        return mealsByDate[dateString]?[type] ?? []
    }

    func setMeals(for date: Date, type: MealType, meals: [MealPlanner]) {
        let dateString = dateFormatter.string(from: date)
        if mealsByDate[dateString] == nil {
            mealsByDate[dateString] = [:]
        }
        mealsByDate[dateString]?[type] = meals
    }

    func appendMeal(for date: Date, type: MealType, meal: MealPlanner) {
        let dateString = dateFormatter.string(from: date)
        if mealsByDate[dateString] == nil {
            mealsByDate[dateString] = [:]
        }
        mealsByDate[dateString]?[type, default: []].append(meal)
    }
}
