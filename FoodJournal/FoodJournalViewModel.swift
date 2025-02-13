//
//  FoodJournalViewModel.swift
//  Fit Pantry
//
//  Created by Lexie Reddon
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore


class FoodJournalViewModel: ObservableObject {
    @Published var foodEntries: [Food] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "foodEntries"
    
    
    func fetchFoodEntries(){
        
    }
    
    
    func addFoodEntry(){
        
    }
    
    func deleteFoodEntry(){
        
    }
}


