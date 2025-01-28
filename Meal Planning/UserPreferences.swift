//
//  UserPreferences.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 12/1/24.
//

import Foundation

class UserPreferences{
    var dietaryRestrictions: [String]
    var activityLevel: String
    var mealPreferences:[String]
    
    init(dietaryRestrictions: [String], activityLevel: String, mealPreferences: [String]){
        self.dietaryRestrictions = dietaryRestrictions
        self.activityLevel = activityLevel
        self.mealPreferences = mealPreferences
    }
    
    func updatePreferences(dietaryRestrictions: [String], activityLevel: String, mealPreferences: [String]){
        self.dietaryRestrictions = dietaryRestrictions
        self.activityLevel = activityLevel
        self.mealPreferences = mealPreferences
    }
    
    func printPreferences(){
        print("Dietary Restrictions: \(dietaryRestrictions)")
        print("Activity Level: \(activityLevel)")
        print("Meal Preferences: \(mealPreferences)")
    }
}
