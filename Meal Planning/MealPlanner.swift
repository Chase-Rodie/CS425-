
//
//  MealPlanner.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/29/25.
//

import Foundation

enum MealCategory: String, CaseIterable, Identifiable {
    case prepared = "prepared"
    case ingredient = "ingredient"
    var id: String { rawValue }
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    var id: String { rawValue }
}

struct MealPlanner: Identifiable, Hashable, Equatable {
    let id = UUID()
    let pantryDocID: String
    let name: String
    let foodID: String
    let imageURL: String?
    let category: MealCategory
    var quantity: Double
    var consumedAmount: Double? = nil
    var dietaryTags: [String] = []
    var calories: Int = 0
    var protein: Double = 0.0
    var carbs: Double = 0.0
    var fat: Double = 0.0
    var unit: String?
    var consumedUnit: String? = nil
    
    static func == (lhs: MealPlanner, rhs: MealPlanner) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FoodAlias: Identifiable {
    var id: String  // foodID
    var alias: String
    var name: String
}

struct ParsedRecipe {
    let ingredients: [String]
    let instructions: [String]
}


func parseRecipe(_ recipe: String) -> ParsedRecipe {
    var ingredients = [String]()
    var instructions = [String]()

    // If it's returned as a list with one string, unwrap it
    let cleaned = recipe
        .trimmingCharacters(in: CharacterSet(charactersIn: "[\"]")) // remove brackets and quotes
        .replacingOccurrences(of: "\\n", with: "\n") // handle escaped newlines if any

    // Split into Ingredients and Instructions
    let parts = cleaned.components(separatedBy: "Instructions:")

    if parts.count == 2 {
        let ingredientPart = parts[0]
        let instructionPart = parts[1]

        // Parse ingredients
        if let ingredientsRange = ingredientPart.range(of: "Ingredients:") {
            let rawIngredients = ingredientPart[ingredientsRange.upperBound...]
            ingredients = rawIngredients
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        // Parse instructions (remove brackets/quotes)
        var rawInstructions = instructionPart
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "'", with: "")

        instructions = rawInstructions
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    return ParsedRecipe(ingredients: ingredients, instructions: instructions)
}
