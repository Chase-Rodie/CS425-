//
//  MealPlanner.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/29/25.
//

import Foundation

enum MealCategory: String, CaseIterable, Identifiable {
    case prepared = "Prepared"
    case ingredient = "Ingredient"
    var id: String { rawValue }
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    var id: String { rawValue }
}

struct MealPlanner: Identifiable, Hashable {
    let id = UUID()
    let pantryDocID: String
    let name: String
    let foodID: String
    let imageURL: String?
    let category: MealCategory
    var quantity: Double
    var consumedAmount: Double? = nil
    var calories: Double
    var protein: Double
    var fat: Double
    var carbohydrates: Double
}
