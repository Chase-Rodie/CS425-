//
//  MealDetailView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 02/28/2025
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MealDetailView: View {
    let meal: String
    let foodID: String
    @State private var foodDetails: [String: Any]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text(foodDetails?["name"] as? String ?? meal)
                .font(.largeTitle)
                .fontWeight(.bold)

            if let details = foodDetails {
                Text("Calories: \(details["calories"] as? Double ?? 0)")
                Text("Protein: \(details["protein"] as? Double ?? 0)g")
                Text("Carbs: \(details["carbohydrates"] as? Double ?? 0)g")
                Text("Fat: \(details["fat"] as? Double ?? 0)g")
                Text("Sugar: \(details["sugars"] as? Double ?? 0)g")

                if let name = details["name"] as? String {
                    Text("Name: \(name)")
                        .font(.headline)
                }
                if let foodGroup = details["food_group"] as? String {
                    Text("Food Group: \(foodGroup)")
                        .font(.headline)
                }
            } else {
                Text("Loading...")
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            FirestoreManager().fetchFoodDetails(for: foodID) { details in
                self.foodDetails = details
            }
        }
    }
}

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailView(meal: "Chicken and Rice", foodID: "168103")
    }
}
