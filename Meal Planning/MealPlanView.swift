//
//  MealPlanView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 02/28/2025
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Foundation
import FirebaseAuth

struct MealPlanView: View {
    @EnvironmentObject var mealManager: TodayMealManager
    @State private var selectedDate = Date()
    @State private var mealPlan: [MealPlanner] = []
    @State private var isLoading = true
    @State private var selectedCategory: MealCategory = .prepared
    @State private var selectedMeals: Set<MealPlanner> = []
    @State private var showQuantityInput = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var inputQuantities: [UUID: String] = [:]
    @State private var quantityErrors: [UUID: String] = [:]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Meal Plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)

                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)

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
                            selectedDate: selectedDate,
                            mealType: type,
                            meals: Binding(
                                get: { mealManager.getMeals(for: selectedDate, type: type) },
                                set: { mealManager.setMeals(for: selectedDate, type: type, meals: $0) }
                            ),
                            onRemove: { removedMeal in
                                let amountToRestore = removedMeal.consumedAmount ?? 0
                                updatePantryQuantity(docID: removedMeal.pantryDocID, amount: amountToRestore)
                            }
                        )){
                            VStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(Color("Navy"))
                                Text(type.rawValue)
                                    .foregroundColor(Color("Navy"))
                            }
                            .padding()
                            .background(Color("BackgroundColor").opacity(0.5))
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
                    let filteredMeals = mealPlan.filter { meal in
                        return meal.category == selectedCategory && meal.quantity > 0
                    }
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
                                            .foregroundColor(
                                                selectedMeals.contains(meal) ? Color("Orange") : Color("BackgroundColor")
                                            )
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
                                selectedMealType = type
                                showQuantityInput = true
                            }
                            .padding(6)
                            .background(Color("Navy"))
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
            .sheet(isPresented: $showQuantityInput) {
                VStack {
                    Text("How much of each selected item was eaten?")
                        .font(.headline)
                        .padding()

                    ScrollView {
                        ForEach(Array(selectedMeals), id: \..self) { meal in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.name)
                                    .font(.subheadline)

                                TextField("Amount", text: Binding(
                                    get: { inputQuantities[meal.id] ?? "" },
                                    set: { inputQuantities[meal.id] = $0 }
                                ))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                                if let error = quantityErrors[meal.id] {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                        }
                    }

                    Button("Submit") {
                        quantityErrors = [:]
                        var isValid = true

                        for meal in selectedMeals {
                            guard let input = inputQuantities[meal.id], let eaten = Double(input) else {
                                quantityErrors[meal.id] = "Enter a valid number"
                                isValid = false
                                continue
                            }

                            if eaten > meal.quantity {
                                let formatted = String(format: "%.1f", meal.quantity)
                                quantityErrors[meal.id] = "You only have \(formatted)"
                                isValid = false
                            }
                        }

                        guard isValid else { return }

                        for meal in selectedMeals {
                            if let input = inputQuantities[meal.id], let eaten = Double(input) {
                                updatePantryQuantity(docID: meal.pantryDocID, amount: -eaten)
                                logMeal(for: meal, amount: eaten, type: selectedMealType)

                                var updatedMeal = meal
                                updatedMeal.consumedAmount = eaten
                                updatedMeal.quantity -= eaten
                                mealManager.appendMeal(for: selectedDate, type: selectedMealType, meal: updatedMeal)

                                if let index = mealPlan.firstIndex(where: { $0.id == meal.id }) {
                                    mealPlan[index].quantity -= eaten
                                }
                            }
                        }

                        selectedMeals.removeAll()
                        inputQuantities.removeAll()
                        showQuantityInput = false
                    }
                    .padding()
                }
            }
        }
        
        VStack(alignment: .leading) {
            Text("Daily Totals")
                .font(.headline)
            Text("Calories: \(totalDailyCalories(), specifier: "%.0f") kcal")
                .font(.subheadline)
            Text("Protein: \(totalDailyProtein(), specifier: "%.0f") g")
                .font(.subheadline)
            Text("Fat: \(totalDailyFat(), specifier: "%.0f") g")
                .font(.subheadline)
            Text("Carbs: \(totalDailyCarbs(), specifier: "%.0f") g")
                .font(.subheadline)
            
        }
        .padding(.horizontal)
    }

    func updatePantryQuantity(docID: String, amount: Double) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        let docRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("pantry")
            .document(docID)
        docRef.updateData(["quantity": FieldValue.increment(amount)])
    }

    func logMeal(for meal: MealPlanner, amount: Double, type: MealType) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: selectedDate)

        let logRef = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("mealLogs")
            .document(today)

        let mealData: [String: Any] = [
            "name": meal.name,
            "foodID": meal.foodID,
            "amount": amount
        ]

        logRef.setData([type.rawValue.lowercased(): FieldValue.arrayUnion([mealData])], merge: true)
    }
    
    func totalDailyCalories() -> Double {
        return MealType.allCases
            .flatMap { mealManager.getMeals(for: selectedDate, type: $0) }
            .reduce(0.0) { total, meal in
                let amount = meal.consumedAmount ?? 0
                return total + (meal.calories * amount)
            }
    }
    
    func totalDailyProtein() -> Double {
        return MealType.allCases
            .flatMap { mealManager.getMeals(for: selectedDate, type: $0) }
            .reduce(0.0) { total, meal in
                let amount = meal.consumedAmount ?? 0
                return total + (meal.protein * amount)
            }
    }
    
    func totalDailyFat() -> Double {
        return MealType.allCases
            .flatMap { mealManager.getMeals(for: selectedDate, type: $0) }
            .reduce(0.0) { total, meal in
                let amount = meal.consumedAmount ?? 0
                return total + (meal.fat * amount)
            }
    }
    
    func totalDailyCarbs() -> Double {
        return MealType.allCases
            .flatMap { mealManager.getMeals(for: selectedDate, type: $0) }
            .reduce(0.0) { total, meal in
                let amount = meal.consumedAmount ?? 0
                return total + (meal.carbohydrates * amount)
            }
    }

    func fetchMealsAsync() async {
        await withCheckedContinuation { continuation in
            guard let userID = Auth.auth().currentUser?.uid else {
                print("No authenticated user found.")
                self.isLoading = false
                continuation.resume()
                return
            }
            let pantryRef = Firestore.firestore()
                .collection("users")
                .document(userID)
                .collection("pantry")

            pantryRef.getDocuments { pantrySnapshot, error in
                guard let pantryDocs = pantrySnapshot?.documents else {
                    print("Error fetching pantry data: \(error?.localizedDescription ?? "Unknown error")")
                    self.isLoading = false
                    continuation.resume()
                    return
                }

                let pantryItems: [(foodID: Int, quantity: Double, pantryDocID: String)] = pantryDocs.compactMap { doc in
                    guard let id = doc.data()["id"] as? Int,
                          let quantity = doc.data()["quantity"] as? Double else { return nil }

                    return (Int(id), quantity, doc.documentID)
                }

                let foodIDs = pantryItems.map { $0.foodID }
                
                guard !foodIDs.isEmpty else {
                    print("No pantry items with valid food IDs. Skipping Food query.")
                    self.mealPlan = []
                    self.isLoading = false
                    continuation.resume()
                    return
                }
                
                let queryIDs = pantryItems.map { $0.foodID }
                Firestore.firestore().collection("Food")
                    .whereField("ID", in: queryIDs)
                    .getDocuments { foodSnapshot, error in
                        if let error = error {
                            continuation.resume()
                            return
                        }

                        guard let foodDocs = foodSnapshot?.documents else {
                            continuation.resume()
                            return
                        }

                        foodDocs.forEach { doc in
                        }

                        var fetchedMeals: [MealPlanner] = []
                        for doc in foodDocs {
                            let data = doc.data()

                            guard let id = data["ID"] as? Int,
                                  let name = data["name"] as? String,
                                  let calories = data["calories"] as? Double,
                                  let protein = data["protein"] as? Double,
                                  let fat = data["fat"] as? Double,
                                  let carbohydrates = data["carbohydrates"] as? Double else {
                                      print("Missing or invalid data in Food doc: \(doc.documentID). Data: \(data)")
                                      continue
                            }

                            if let quantityInfo = pantryItems.first(where: { $0.foodID == id }) {
                                let quantity = quantityInfo.quantity
                                let pantryDocID = quantityInfo.pantryDocID

                                if quantity > 0 {
                                    let categoryStr = (data["category"] as? String)?.capitalized ?? "Prepared"
                                    let category = MealCategory(rawValue: categoryStr) ?? .prepared

                                    let meal = MealPlanner(
                                        pantryDocID: pantryDocID,
                                        name: name,
                                        foodID: String(id),
                                        imageURL: nil,
                                        category: category,
                                        quantity: quantity,
                                        calories: calories,
                                        protein: protein,
                                        fat: fat,
                                        carbohydrates: carbohydrates
                                    )

                                    fetchedMeals.append(meal)
                                }
                            }
                        }
                        self.mealPlan = fetchedMeals
                        self.isLoading = false
                        continuation.resume()
                    }
            }
        }
    }


}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}


struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView().environmentObject(TodayMealManager())
    }
}
