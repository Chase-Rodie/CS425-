//
//  ShoppingList.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 12/1/24.
//

import Foundation

class ShoppingList{
    var items: [String] = []
    
    func addItems(for mealPlan: [String]){
        for meal in mealPlan{
            switch meal{
            case "Breakfast":
                items.append("eggs")
                items.append("milk")
            case "Lunch":
                items.append("Grilled Cheese")
                items.append("Apples")
            case "Dinner":
                items.append("Chicken and Salad")
            default:
                break
            }
        }
    }
    
    func printShoppingList(){
        print("Shopping List: \(items)")
    }
}
