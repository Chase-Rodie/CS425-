//
//  TodayMealView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/28/25.
//

import SwiftUI

struct TodayMealView: View {
    let selectedDate: Date
    let mealType: MealType
    @Binding var meals: [MealPlanner]
    var onRemove: (MealPlanner) -> Void

    var body: some View {
        VStack {
            Text("\(mealType.rawValue) Meals")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("Date: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")

            if meals.isEmpty {
                Text("No meals added yet.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(meals) { meal in
                        HStack {
                            Text("\(meal.name) (\(meal.consumedAmount ?? 0, specifier: "%.1f"))")
                            Spacer()
                            Button(action: {
                                onRemove(meal)
                                meals.removeAll { $0.id == meal.id }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }

                Button("View Recipe") {
                    print("View Recipe tapped for \(mealType.rawValue)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BackgroundColor"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding([.horizontal, .bottom])
            }
        }
    }
}
