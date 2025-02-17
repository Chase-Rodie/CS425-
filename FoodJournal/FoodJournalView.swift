//
//  FoodJournalView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 2/13/25.
//

import SwiftUI

struct FoodJournalView: View {
    @StateObject private var viewModel = FoodJournalViewModel()
    private let userId: String
    
    init(userId: String){
        self.userId = userId
    }
    
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
                            Text(now.formatted(date: .long, time: .omitted))
                                .fontWeight(.semibold)
                    }
                    VStack{
                        HStack{
                            VStack(alignment: .trailing){
                                Text("Breakfast:")
                                    .font(.headline)
                                Text("Food1")
                            }
                            Spacer()
                            Button{
                                viewModel.showingFoodJournalItemAddView = true
                            } label:{
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                            }.sheet(isPresented: $viewModel.showingFoodJournalItemAddView){
                                FoodJournalAddItemView()
                                
                            }.foregroundColor(.black)
                            
                        }
                        .padding()
                        HStack{
                            VStack(alignment: .trailing){
                                Text("Lunch:")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding()
                        HStack{
                            VStack(alignment: .trailing){
                                Text("Dinner:")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding()
                        HStack{
                            VStack(alignment: .trailing){
                                Text("Snacks:")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding()
                        
                    }
                    
                }
            }
        }.foregroundColor(.white)
    }
    
    }




#Preview {
    FoodJournalView(userId: "")
}
