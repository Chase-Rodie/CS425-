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
    @FirestoreQuery var items: [Food]
    
  //  private let userId: String
    
    
    init(userId: String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let formattedDate = dateFormatter.string(from: now)
        
        //self.userId = userId
        self._items = FirestoreQuery(collectionPath: "userData_test/\(userId)/foodjournal/\(formattedDate)/breakfast")
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
                                List(items){ item in
                                    Text(item.name)
                                }
                                .listStyle(PlainListStyle())
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
    FoodJournalView(userId: "gwj5OvTOGmNA8GCfd7nkEzo3djA2")
}
