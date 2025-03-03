//
//  Exercise.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/26/24.
//

import Foundation

struct Exercise: Decodable,Encodable,Identifiable{
    var category: String
    var equipment: String
    var force: String
    var id: String
    var imageURLs: Array<String>
    var instructions: Array<String>
    var level: String
    var mechanic: String
    var name: String
    var primaryMuscles: Array<String>
    var secondaryMuscles: Array<String>
    var isComplete: Bool = false
    var weightUsed: Double?
}

