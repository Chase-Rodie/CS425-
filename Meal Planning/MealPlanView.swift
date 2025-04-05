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
                    let filteredMeals = mealPlan.filter { $0.category == selectedCategory && $0.quantity > 0 }
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
    }

    func updatePantryQuantity(docID: String, amount: Double) {
        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
        let docRef = Firestore.firestore()
            .collection("userData_test")
            .document(userID)
            .collection("pantry")
            .document(docID)
        docRef.updateData(["quantity": FieldValue.increment(amount)])
    }

    func logMeal(for meal: MealPlanner, amount: Double, type: MealType) {
        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: selectedDate)

        let logRef = Firestore.firestore()
            .collection("userData_test")
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
                    guard let foodID = data["id"] as? Int,
                          let name = data["name"] as? String,
                          let quantity = data["quantity"] as? Double,
                          quantity > 0 else {
                        return nil
                    }

                    let category: MealCategory = quantity > 1 ? .prepared : .ingredient

                    return MealPlanner(
                        pantryDocID: doc.documentID,
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

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView().environmentObject(TodayMealManager())
    }
}
