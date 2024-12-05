//
//  MealPlanView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 12/1/24.
//

import SwiftUI

struct MealPlanView: View {
    // Data for the meal plan
    let mealPlan = ["Apples and Toast", "Chicken and Rice", "Oatmeal with Berries"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Meal Plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                List {
                    ForEach(mealPlan, id: \.self) { meal in
                        Text(meal)
                            .font(.title3)
                            .padding()
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(hex: "0daf6b"))
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealPlanView()
                .previewDevice("iPhone 14")
                .preferredColorScheme(.light)
            
            MealPlanView()
                .previewDevice("iPhone 14 Pro")
                .preferredColorScheme(.dark)
        }
    }
}


extension Color {
    init(hex: String) {
            let hexSanitized = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
            let scanner = Scanner(string: hexSanitized)
            scanner.currentIndex = hexSanitized.startIndex
            
            var rgbValue: UInt64 = 0
            scanner.scanHexInt64(&rgbValue)

            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0

            self.init(red: red, green: green, blue: blue)
        }
}
