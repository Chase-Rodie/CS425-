//
//  FoodJournalView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 2/13/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct FoodJournalView: View {
    @StateObject private var viewModel = FoodJournalViewModel()
    //@FirestoreQuery var items: [Food]
    
  //  private let userId: String
    
    
//    init(userId: String){
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM-dd-yyyy"
//        let formattedDate = dateFormatter.string(from: now)
//        
//        //self.userId = userId
//        self._items = FirestoreQuery(collectionPath: "users/\(userId)/foodjournal/\(formattedDate)/breakfast")
//    }
//    
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
                            VStack(alignment: .leading){
                                HStack{
                                    Text("Breakfast:")
                                        .bold(true)
                                    Spacer()
                                    Button{
                                        viewModel.showingFoodJournalItemAddView = true
                                    } label:{
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                    }.sheet(isPresented: $viewModel.showingFoodJournalItemAddView){
                                        FoodJournalAddItemView(mealName: "lunch")
                                        
                                    }
                                }
                                Divider()
                                    .background(Color.black)
                                //Text("Entries Count: \(viewModel.foodEntries.count)")
                                ForEach(viewModel.breakfastFoodEntries){ food in
                                    FoodJournalItemView(item: food)
                                }

                            }
                            Spacer()
                            
                        }
                        .padding()
                        HStack{
                            VStack(alignment: .trailing){
                                HStack{
                                    Text("Lunch:")
                                        .bold(true)
                                    Spacer()
                                    Button{
                                        viewModel.showingFoodJournalItemAddView = true
                                    } label:{
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                    }.sheet(isPresented: $viewModel.showingFoodJournalItemAddView){
                                        FoodJournalAddItemView(mealName: "lunch")
                                        
                                    }
                                }
                                Divider()
                                    .background(Color.black)
                                //Text("Entries Count: \(viewModel.foodEntries.count)")
                                ForEach(viewModel.lunchFoodEntries){ food in
                                    FoodJournalItemView(item: food)
                                }

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
            .onAppear {
                //print("onAppear called - Fetching Food Entries")
                viewModel.fetchFoodEntries(mealName:"breakfast")
                //print("onAppear foodEntries: \(viewModel.foodEntries)")
            }
            
    }
    
    }




#Preview {
    FoodJournalView()
}
