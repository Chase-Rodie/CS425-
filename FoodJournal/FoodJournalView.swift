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
    @State private var selectedMeal: Meal?
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
//        ProgressView(value: 0.5, total: 1.0)
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
                                    Button {
                                        selectedMeal = Meal(name: "breakfast")
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                    }.sheet(item: $selectedMeal) { meal in
                                        FoodJournalAddItemView(mealName: meal.name, viewModel: viewModel)
                                    }
                                }
                                Divider()
                                    .background(Color.black)
                                //Text("Entries Count: \(viewModel.foodEntries.count)")
                                ForEach(viewModel.breakfastFoodEntries){ food in
                                    FoodJournalItemView(item: food, mealName: "breakfast", viewModel: viewModel)
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
                                    Button {
                                        selectedMeal = Meal(name: "lunch")
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                    }.sheet(item: $selectedMeal) { meal in
                                        FoodJournalAddItemView(mealName: meal.name, viewModel: viewModel)
                                    }

                                }
                                Divider()
                                    .background(Color.black)
                                //Text("Entries Count: \(viewModel.foodEntries.count)")
                                ForEach(viewModel.lunchFoodEntries){ food in
                                    FoodJournalItemView(item: food, mealName: "lunch", viewModel: viewModel)
                                }

                            }
                            Spacer()
                        }
                        .padding()
                        HStack{
                            VStack(alignment: .trailing){
                                HStack{
                                    Text("Dinner:")
                                        .bold(true)
                                    Spacer()
                                    Button {
                                        selectedMeal = Meal(name: "dinner")
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                    }.sheet(item: $selectedMeal) { meal in
                                        FoodJournalAddItemView(mealName: meal.name, viewModel: viewModel)
                                    }

                                }
                                Divider()
                                    .background(Color.black)
                                //Text("Entries Count: \(viewModel.foodEntries.count)")
                                ForEach(viewModel.dinnerFoodEntries){ food in
                                    FoodJournalItemView(item: food, mealName: "dinner", viewModel: viewModel)
                                }

                            }
                            Spacer()
                        }
                        .padding()
                        
                    }
                    
                }
            }
        }.foregroundColor(.white)
            .onAppear {
                viewModel.fetchFoodEntries(mealName:"breakfast")
                viewModel.fetchFoodEntries(mealName:"lunch")
                viewModel.fetchFoodEntries(mealName:"dinner")
            }
            
    }
    
    }


struct Meal: Identifiable {
    let id = UUID()  // Conforming to Identifiable
    let name: String
}


#Preview {
    FoodJournalView()
}
