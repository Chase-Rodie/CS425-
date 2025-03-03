//
//  FoodJournalitemView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 2/16/25.
//

import SwiftUI

struct FoodJournalItemView: View {
    let item: Food
    let mealName: String
    
    @ObservedObject var viewModel: FoodJournalViewModel
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(item.name)
                    .bold()
                Text("Calories: "+item.calories.description)
            }
            Spacer()
            Button{
                viewModel.deleteFoodEntry(mealName: mealName, food: item)
            } label: {
                    Image(systemName: "trash")
                }
        }
    }
}

#Preview {
    FoodJournalItemView(item: Food(id: "1", name: "Banana", foodGroup: "Fruits", food_id: 101, calories: 100, fat: 0.3, carbohydrates: 27, protein: 1.3, suitableFor: ["Vegan", "Gluten-Free"]), mealName: "breakfast", viewModel: FoodJournalViewModel())
}
