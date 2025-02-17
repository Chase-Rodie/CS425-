//
//  FoodJournalViewModel.swift
//  Fit Pantry
//
//  Created by Lexie Reddon
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


@MainActor class FoodJournalViewModel: ObservableObject {

    @Published var showingFoodJournalItemAddView = false
    
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


