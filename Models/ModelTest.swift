//
//  Models.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/23/24.
//

import Foundation

struct FoodTest: Identifiable {
    var id: String
    var name: String
    var foodGroup: String
    var food_id: Int32
    var calories: Int32
    var fat: Float32
    var carbohydrates: Float32
    var protein: Float32
}