//
//  PantryView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 10/31/24.
//

import Foundation
import SwiftUI
import FirebaseCore

struct FoodView: View {
    
    @ObservedObject var model = GetData()
    // var food: FoodTest
    
    var body: some View {
        /*
        VStack {
            Text(food.id)
        }
         */
        List (model.list) { item in
            //Text(item.name)
            Text(item.name)
            Text("ID: \(item.food_id)")
            Text("")
        }
    }
    
    init() {
        model.query()
        //food = model.list.first!
        //food = model.list[0]
    }
}

#Preview {
    FoodView()
}
