//
//  MealPlanView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 02/28/2025
//

//import SwiftUI
//import Firebase
//
//struct Meal: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let foodID: String
//    let imageURL: String?
//}
//
//struct MealPlanView: View {
//    @State private var mealPlan = [Meal]()
//    @State private var isLoading = true
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading) {
//                Text("Meal Plan")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.leading)
//
//                if isLoading {
//                    VStack {
//                        ProgressView()
//                        Text("Loading meals...")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                } else if mealPlan.isEmpty {
//                    Text("No meals available.")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    List {
//                        ForEach(mealPlan) { meal in
//                            NavigationLink(destination: MealDetailView(meal: meal.name, foodID: meal.foodID)) {
//                                VStack(alignment: .leading) {
//                                    Text(meal.name)
//                                        .font(.title3)
//                                        .padding(.bottom, 2)
//                                    Text("Tap to view details")
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                }
//                                .padding()
//                            }
//                        }
//                    }
//                    .listStyle(PlainListStyle())
//                    .padding(.horizontal)
//                }
//
//                Spacer()
//            }
//            .background(Color("0daf6b"))
//            .onAppear {
//                Task {
//                    await fetchMealsAsync()
//                }
//            }
//        }
//    }
//
//    func fetchMealsAsync() async {
//        await withCheckedContinuation { continuation in
//            FirestoreManager().fetchMeals { meals in
//                mealPlan = Array(Set(meals))
//                isLoading = false
//                continuation.resume()
//            }
//        }
//    }
//}
//
//struct MealPlanView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            MealPlanView()
//                .previewDevice("iPhone 14")
//                .preferredColorScheme(.light)
//
//            MealPlanView()
//                .previewDevice("iPhone 14 Pro")
//                .preferredColorScheme(.dark)
//        }
//    }
//}

import SwiftUI
import Firebase
import FirebaseFirestore

struct MealPlanner: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let foodID: String
    let imageURL: String?
}

struct MealPlanView: View {
    @State private var mealPlan: [MealPlanner] = []
    @State private var isLoading = true
    @State private var isMenuOpen = false

    var body: some View {
        ZStack {
            NavigationView {
                VStack(alignment: .leading) {
                    Text("Meal Plan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)

                    if isLoading {
                        VStack {
                            ProgressView()
                            Text("Loading meals...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    } else if mealPlan.isEmpty {
                        Text("No meals available.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(mealPlan) { meal in
                                NavigationLink(destination: MealDetailView(meal: meal.name, foodID: meal.foodID)) {
                                    VStack(alignment: .leading) {
                                        Text(meal.name)
                                            .font(.title3)
                                            .padding(.bottom, 2)
                                        Text("Tap to view details")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .background(Color("0daf6b"))
                .onAppear {
                    Task {
                        await fetchMealsAsync()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        
            if isMenuOpen {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    isMenuOpen = false
                                }
                            }
                        
                        HamburgerMenuView()
                            .frame(width: geometry.size.width * 0.7)
                            .transition(.move(edge: .leading))
                    }
                }
            }
        }
    }

    func fetchMealsAsync() async {
        await withCheckedContinuation { continuation in
            FirestoreManager().fetchMeals { meals in
                mealPlan = Array(Set(meals))
                isLoading = false
                continuation.resume()
            }
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealPlanView()
                .previewDevice("iPhone 14")
                .preferredColorScheme(.light)

            MealPlanView()
                .previewDevice("iPhone 14 Pro")
                .preferredColorScheme(.dark)
        }
    }
}

