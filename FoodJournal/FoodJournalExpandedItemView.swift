//
//  FoodJournalExpandedItemView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 3/8/25.
//

import SwiftUI

struct FoodJournalExpandedItemView: View {
    
    let item: Food
    let mealName: String
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(item.name)
                    .bold()
                Text("Calories: "+item.calories.description)
                Text("Carbohydrates: " + item.carbohydrates.description)
                Text("Protein: " + item.protein.description)
                Text("Fats: " + item.fat.description)
                Text("Show More")
            }
        }
    }
}

#Preview {
    FoodJournalExpandedItemView(item: Food(id: "1", name: "Banana", foodGroup: "Fruits", food_id: 101, calories: 100, fat: 0.3, carbohydrates: 27, protein: 1.3, suitableFor: ["Vegan", "Gluten-Free"]), mealName: "breakfast")
}
