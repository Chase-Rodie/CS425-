//
//  Units.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 4/20/25.
//

import Foundation

//let Units: [String: Double] = [
//    "g": 1.0,
//    "mg": 0.001,
//    "oz": 28.35,
//    "cup": 240,
//    "tbsp": 15,
//    "tsp": 5,
//    "slice": 35,
//    "can": 340,
//    "loaf": 800,
//    "lbs": 453.59,
//    "kg": 1000,
//    "ml": 1.0,
//    "L": 1000,
//    "gal": 3785.41
//]

let Units: [String: Double] = [
    "g": 1.0,
    "mg": 0.001,
    "oz": 1.0,
    "lbs": 16.0, 
    "kg": 35.274,
    "cup": 8.0,
    "tbsp": 0.5,
    "tsp": 0.1667,
    "slice": 1.0,
    "can": 12.0,
    "loaf": 16.0,
    "ml": 0.0338,
    "L": 33.814,
    "gal": 128.0
]


struct UnitConverter {
    static func convert(amount: Double, from fromUnit: String, to toUnit: String) -> Double? {
        guard let fromFactor = Units[fromUnit], let toFactor = Units[toUnit] else {
            return nil
        }

        let amountInGrams = amount * fromFactor
        let convertedAmount = amountInGrams / toFactor
        
        return convertedAmount
    }
}

