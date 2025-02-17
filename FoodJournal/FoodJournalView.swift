//
//  FoodJournalView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 2/13/25.
//

import SwiftUI

struct FoodJournalView: View {
    @StateObject private var viewModel = FoodJournalViewModel()
    
    let now = Date()
    
    var body: some View{
        ZStack{
          
            LinearGradient(colors:[.background, .lighter], startPoint:  .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView{
                VStack{
    
                        VStack{
                            Text("Today's Food Journal")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                            Text(now.formatted(date: .long, time: .omitted))
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
    
    }


#Preview {
    FoodJournalView()
}
