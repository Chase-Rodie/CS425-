//
//  MealPlanView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 02/28/2025
//

//import SwiftUI
//import Firebase
//import FirebaseFirestore
//
//enum MealCategory: String, CaseIterable, Identifiable {
//    case prepared = "Prepared"
//    case ingredient = "Ingredient"
//
//    var id: String { rawValue }
//}
//
//enum MealType: String, CaseIterable, Identifiable {
//    case breakfast = "Breakfast"
//    case lunch = "Lunch"
//    case dinner = "Dinner"
//
//    var id: String { rawValue }
//}
//
//struct MealPlanner: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let foodID: String
//    let imageURL: String?
//    let category: MealCategory
//}
//
//struct MealPlanView: View {
//    @State private var mealPlan: [MealPlanner] = []
//    @State private var isLoading = true
//    @State private var selectedCategory: MealCategory = .prepared
//    @State private var selectedMeals: Set<MealPlanner> = []
//    @State private var todayMeals: [MealType: [MealPlanner]] = [:]
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading) {
//                Text("Meal Plan")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.leading)
//
//                Picker("Meal Category", selection: $selectedCategory) {
//                    ForEach(MealCategory.allCases) { category in
//                        Text(category.rawValue).tag(category)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.horizontal)
//
//                HStack {
//                    ForEach(MealType.allCases) { type in
//                        NavigationLink(destination: TodayMealView(
//                            mealType: type,
//                            meals: Binding(
//                                get: { todayMeals[type] ?? [] },
//                                set: { todayMeals[type] = $0 }
//                            )
//                        )) {
//                            VStack {
//                                Image(systemName: "leaf")
//                                Text(type.rawValue)
//                            }
//                            .padding()
//                            .background(Color.green.opacity(0.2))
//                            .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding()
//
//                if isLoading {
//                    VStack {
//                        ProgressView()
//                        Text("Loading meals...")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                } else {
//                    let filteredMeals = mealPlan.filter { $0.category == selectedCategory }
//
//                    if filteredMeals.isEmpty {
//                        Text("No \(selectedCategory.rawValue.lowercased()) meals available.")
//                            .font(.headline)
//                            .foregroundColor(.gray)
//                            .padding()
//                    } else {
//                        List {
//                            ForEach(filteredMeals) { meal in
//                                HStack {
//                                    NavigationLink(destination: MealDetailView(meal: meal.name, foodID: meal.foodID)) {
//                                        VStack(alignment: .leading) {
//                                            Text(meal.name)
//                                                .font(.title3)
//                                                .padding(.bottom, 2)
//                                            Text("Tap to view details")
//                                                .font(.subheadline)
//                                                .foregroundColor(.gray)
//                                        }
//                                    }
//
//                                    Spacer()
//
//                                    Button(action: {
//                                        if selectedMeals.contains(meal) {
//                                            selectedMeals.remove(meal)
//                                        } else {
//                                            selectedMeals.insert(meal)
//                                        }
//                                    }) {
//                                        Image(systemName: selectedMeals.contains(meal) ? "checkmark.circle.fill" : "plus.circle")
//                                            .font(.title2)
//                                            .foregroundColor(selectedMeals.contains(meal) ? .green : .blue)
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    .contentShape(Rectangle())
//                                }
//                                .padding(.vertical, 5)
//                            }
//                        }
//                        .listStyle(PlainListStyle())
//                        .padding(.horizontal)
//                    }
//                }
//
//                if !selectedMeals.isEmpty {
//                    HStack {
//                        Text("Add selected to:")
//                        ForEach(MealType.allCases) { type in
//                            Button(type.rawValue) {
//                                addMealsToMealType(type)
//                            }
//                            .padding(6)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                        }
//                    }
//                    .padding()
//                }
//
//                Spacer()
//            }
//            .onAppear {
//                Task {
//                    await fetchMealsAsync()
//                }
//            }
//        }
//    }
//
//    func addMealsToMealType(_ type: MealType) {
//        for meal in selectedMeals {
//            todayMeals[type, default: []].append(meal)
//        }
//        selectedMeals.removeAll()
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
//struct TodayMealView: View {
//    let mealType: MealType
//    @Binding var meals: [MealPlanner]
//
//    var body: some View {
//        VStack {
//            Text("\(mealType.rawValue) Meals")
//                .font(.largeTitle)
//                .bold()
//                .padding()
//
//            if meals.isEmpty {
//                Text("No meals added yet.")
//                    .foregroundColor(.gray)
//            } else {
//                List {
//                    ForEach(meals) { meal in
//                        HStack {
//                            Text(meal.name)
//                            Spacer()
//                            Button(action: {
//                                meals.removeAll { $0.id == meal.id }
//                            }) {
//                                Image(systemName: "trash")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct MealPlanView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealPlanView()
//    }
//}

import SwiftUI
import Firebase
import FirebaseFirestore

enum MealCategory: String, CaseIterable, Identifiable {
    case prepared = "Prepared"
    case ingredient = "Ingredient"

    var id: String { rawValue }
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"

    var id: String { rawValue }
}

struct MealPlanner: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let foodID: String
    let imageURL: String?
    let category: MealCategory
    let quantity: Double
}

struct MealPlanView: View {
    @State private var mealPlan: [MealPlanner] = []
    @State private var isLoading = true
    @State private var selectedCategory: MealCategory = .prepared
    @State private var selectedMeals: Set<MealPlanner> = []
    @State private var todayMeals: [MealType: [MealPlanner]] = [:]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Meal Plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)

                Picker("Meal Category", selection: $selectedCategory) {
                    ForEach(MealCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                HStack {
                    ForEach(MealType.allCases) { type in
                        NavigationLink(destination: TodayMealView(
                            mealType: type,
                            meals: Binding(
                                get: { todayMeals[type] ?? [] },
                                set: { todayMeals[type] = $0 }
                            )
                        )) {
                            VStack {
                                Image(systemName: "leaf")
                                Text(type.rawValue)
                            }
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()

                if isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading meals...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    let filteredMeals = mealPlan.filter { $0.category == selectedCategory }

                    if filteredMeals.isEmpty {
                        Text("No \(selectedCategory.rawValue.lowercased()) meals available.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(filteredMeals) { meal in
                                HStack {
                                    NavigationLink(destination: MealDetailView(meal: meal.name, foodID: meal.foodID)) {
                                        VStack(alignment: .leading) {
                                            Text("\(meal.name) (\(meal.quantity, specifier: "%.1f"))")
                                                .font(.title3)
                                                .padding(.bottom, 2)
                                            Text("Tap to view details")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    Spacer()

                                    Button(action: {
                                        if selectedMeals.contains(meal) {
                                            selectedMeals.remove(meal)
                                        } else {
                                            selectedMeals.insert(meal)
                                        }
                                    }) {
                                        Image(systemName: selectedMeals.contains(meal) ? "checkmark.circle.fill" : "plus.circle")
                                            .font(.title2)
                                            .foregroundColor(selectedMeals.contains(meal) ? .green : .blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contentShape(Rectangle())
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .padding(.horizontal)
                    }
                }

                if !selectedMeals.isEmpty {
                    HStack {
                        Text("Add selected to:")
                        ForEach(MealType.allCases) { type in
                            Button(type.rawValue) {
                                addMealsToMealType(type)
                            }
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .onAppear {
                Task {
                    await fetchMealsAsync()
                }
            }
        }
    }

    func addMealsToMealType(_ type: MealType) {
        for meal in selectedMeals {
            todayMeals[type, default: []].append(meal)
        }
        selectedMeals.removeAll()
    }

    func fetchMealsAsync() async {
        await withCheckedContinuation { continuation in
            let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
            let db = Firestore.firestore()
                .collection("userData_test")
                .document(userID)
                .collection("pantry")

            db.getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch pantry items: \(error.localizedDescription)")
                    isLoading = false
                    continuation.resume()
                    return
                }

                guard let snapshot = snapshot else {
                    print("No pantry data found")
                    isLoading = false
                    continuation.resume()
                    return
                }

                self.mealPlan = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let foodID = data["id"] as? Int,
                        let name = data["name"] as? String,
                        let quantity = data["quantity"] as? Double
                    else {
                        return nil
                    }

                    let category: MealCategory = quantity > 1 ? .prepared : .ingredient

                    return MealPlanner(
                        name: name,
                        foodID: String(foodID),
                        imageURL: nil,
                        category: category,
                        quantity: quantity
                    )
                }

                isLoading = false
                continuation.resume()
            }
        }
    }
}

struct TodayMealView: View {
    let mealType: MealType
    @Binding var meals: [MealPlanner]

    var body: some View {
        VStack {
            Text("\(mealType.rawValue) Meals")
                .font(.largeTitle)
                .bold()
                .padding()

            if meals.isEmpty {
                Text("No meals added yet.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(meals) { meal in
                        HStack {
                            Text("\(meal.name) (\(meal.quantity, specifier: "%.1f"))")
                            Spacer()
                            Button(action: {
                                meals.removeAll { $0.id == meal.id }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView()
    }
}
