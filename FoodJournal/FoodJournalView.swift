//
//  FoodJournalView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 2/13/25.
//

import SwiftUI

struct FoodJournalView: View {
    @StateObject private var viewModel = FoodJournalViewModel()
    var body: some View{
        ScrollView{
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color("BackgroundColor"))
                        .frame(width: 370, height: 150)
                    
                    Text("Today's Food Journal")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                }
                VStack{
                    VStack(alignment: .leading){
                        Text("Breakfast:")
                            .font(.headline)
                    }
                    VStack(alignment: .leading){
                        Text("Lunch:")
                        .font(.headline)
                    }
                    VStack(alignment: .leading){
                        Text("Dinner:")
                        .font(.headline)
                    }
                    VStack(alignment: .leading){
                        Text("Snacks:")
                        .font(.headline)
                    }
                }
                
            }
        }
    }
    
    }


#Preview {
    FoodJournalView()
}
