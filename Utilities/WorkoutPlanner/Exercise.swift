//
//  Exercise.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/26/24.
//

import Foundation

struct Exercise: Decodable,Encodable,Identifiable{
    var id: String
    var category: String
    var equipment: String
    var force: String
    var instructions: Array<String>
    var level: String
    var mechanic: String
    var name: String
    var primaryMuscles: Array<String>
    var secondaryMuscles: Array<String>
    var isComplete: Bool = false
}

