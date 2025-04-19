//
//  MealPlanView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 02/28/2025
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
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
    
    @State private var showMealGen = false

    @State private var generatedRecipe: String = ""
    @State private var isRecipeLoading = false


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
                    VStack{
                        if selectedCategory == .ingredient {
                            HStack {
                                Button("Generate Recipie") {
                                    showMealGen = true
                                }
                                .padding(6)
                                .background(Color("BackgroundColor"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        
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
            //.sheet(isPresented: $showMealGen){}
            .sheet(isPresented: $showMealGen) {
                MealGenerationView(selectedMeals: selectedMeals)
            }

        }
    }
    
    func updatePantryQuantity(docID: String, amount: Double) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
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
            print("User not authenticated")
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
    
    func fetchMealsAsync() async {
        await withCheckedContinuation { continuation in
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                isLoading = false
                continuation.resume()
                return
            }
            let db = Firestore.firestore()
                .collection("users")
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

                let group = DispatchGroup()
                var fetchedMeals: [MealPlanner] = []

                for doc in snapshot.documents {
                    let data = doc.data()
                    guard let foodID = data["id"] as? Int,
                          let name = data["name"] as? String,
                          let quantity = data["quantity"] as? Double,
                          quantity > 0 else {
                        continue
                    }

                    group.enter()
                    Firestore.firestore().collection("Food").document(String(foodID)).getDocument { foodSnapshot, error in
                        defer { group.leave() }

                        var mealCategory: MealCategory = .prepared  // Default to .prepared

                        if let foodData = foodSnapshot?.data(),
                           let categoryString = foodData["category"] as? String,
                           let parsedCategory = MealCategory(rawValue: categoryString) {
                            mealCategory = parsedCategory
                        } else {
                            print("Could not find category for foodID \(foodID), defaulting to .prepared")
                        }

                        let meal = MealPlanner(
                            pantryDocID: doc.documentID,
                            name: name,
                            foodID: String(foodID),
                            imageURL: nil,
                            category: mealCategory,
                            quantity: quantity
                        )

                        fetchedMeals.append(meal)
                    }
                }

                group.notify(queue: .main) {
                    self.mealPlan = fetchedMeals
                    isLoading = false
                    continuation.resume()
                }
            }
        }
    }

}

struct MealGenerationView: View {
    var selectedMeals: Set<MealPlanner>
    @Environment(\.dismiss) var dismiss
    @State private var foodAliases: [FoodAlias] = []
    @State private var recipe: String = "Generating your recipe..."

    var body: some View {
        NavigationView {
                ZStack {
                    // Background scrollable content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Recipe currently displayed as plain text from AI
                            Text(recipe)
 
                            Text("⚠️ Disclaimer ⚠️")
                                .font(.headline)
                                .padding(.top)
                            Text("These recipes are generated using AI and are for informational purposes only. Please use your best judgment when preparing and consuming meals. Always ensure ingredients are safe to eat, properly cooked, and that any allergies or dietary restrictions are considered. Fit Pantry is not responsible for any adverse effects resulting from the use of AI-generated content.")
                            // Makes space above the fixed button
                            Spacer(minLength: 80)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }

                    // Fixed bottom buttons with solid background
                    VStack(spacing: 0) {
                        Spacer()

                        ZStack {
                            // Background layer (solid white)
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 80)
                                .shadow(radius: 5)

                            // Button row
                            HStack(spacing: 16) {
                                Button(action: {
                                    saveRecipe()
                                }) {
                                    Text("Save Recipe")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.navy)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }

                                Button(action: {
                                    generate()
                                }) {
                                    Text("Regenerate")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color("BackgroundColor"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                }
            
            .navigationTitle("Generated Recipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fetchAliasesAndGenerate()
            }
        }
    }

    func fetchAliasesAndGenerate() {
        let db = Firestore.firestore()
        let foodIDs = selectedMeals.map { $0.foodID }
        var fetchedAliases: [FoodAlias] = []
        let group = DispatchGroup()

        for id in foodIDs {
            group.enter()
            db.collection("Food").document(id).getDocument { docSnapshot, error in
                defer { group.leave() }

                if let doc = docSnapshot, let data = doc.data() {
                    let alias = data["alias"] as? String ?? "Unknown Alias"
                    let name = data["name"] as? String ?? "Unknown Name"
                    let food = FoodAlias(id: id, alias: alias, name: name)
                    if !(alias == "prepared_na") {
                        fetchedAliases.append(food)
                    }
                } else {
                    let food = FoodAlias(id: id, alias: "Unknown Alias", name: "Unknown Name")
                    fetchedAliases.append(food)
                }
            }
        }

        group.notify(queue: .main) {
            self.foodAliases = fetchedAliases
            generate()
        }
    }

    func generate() {
        recipe = "Generating your recipe..."
        //let ingredients = foodAliases.map { $0.alias }
        let ingredients = foodAliases.map { $0.name }

        Fit_Pantry.generateRecipeWithOpenAI(ingredients: ingredients) { result in
            DispatchQueue.main.async {
                if let result = result {
                    recipe = result
                    print(recipe)
                } else {
                    recipe = "Failed to generate recipe. Please try again."
                }
            }
        }
    }
    
    
    func saveRecipe() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userID)
            .collection("SavedRecipes")
            .document()
        
        // Get title from recipe
        let title = recipe.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Untitled Recipe"
        
        // Remove the title line and trim whitespace/newlines
        let lines = recipe.components(separatedBy: .newlines)
        let cleanedRecipeText = lines
            .dropFirst() // drops the first line regardless
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let recipeData: [String: Any] = [
            "title": title,
            "recipeText": cleanedRecipeText,
            "ingredients": foodAliases.map { $0.name },
            "timestamp": Timestamp(date: Date())
        ]

        docRef.setData(recipeData) { error in
            if let error = error {
                print("Error saving recipe: \(error.localizedDescription)")
            } else {
                print("Recipe saved successfully!")
            }
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView().environmentObject(TodayMealManager())
    }
}
