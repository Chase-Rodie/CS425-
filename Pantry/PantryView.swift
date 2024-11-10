//
//  PantryView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 10/31/24.
//

import Foundation
import SwiftUI
import FirebaseCore

struct ContentView: View {
    
    @ObservedObject var model = ViewModel()
    
    var body: some View {
        List (model.list) { item in
            Text(item.name)
        }
    }
    
    init() {
        model.getData()
    }
}

#Preview {
    ContentView()
}
