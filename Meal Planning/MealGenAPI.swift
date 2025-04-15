//
//  MealGenAPI.swift
//  Fit Pantry
//
//  Created by Zachary Greenhill on 3/2/25.
//

import Foundation

struct RecipeRequest: Codable {
    let ingredients: [String]
}

struct RecipeResponse: Codable {
    let recipe: String
}

func generateRecipe(ingredients: [String], completion: @escaping (String?) -> Void) {
    let url = URL(string: "http://172.127.24.215:42647/generate_recipe/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestData = RecipeRequest(ingredients: ingredients)
    let jsonData = try? JSONEncoder().encode(requestData)
    request.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }

        if let recipeResponse = try? JSONDecoder().decode(RecipeResponse.self, from: data) {
            completion(recipeResponse.recipe)
        } else {
            completion(nil)
        }
    }

    task.resume()
}

// Example usage
/*
generateRecipe(ingredients: ["chicken breast", "rice", "soy sauce", "garlic"]) { response in
    if let recipe = response {
        print("Generated Recipe:\n\(recipe)")
    } else {
        print("Failed to fetch recipe")
    }
}
*/
