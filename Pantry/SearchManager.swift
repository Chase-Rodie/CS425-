//
//  SearchManager.swift
//  Fit Pantry
//
//  Created by Zach Greenhill on 11/29/24.
//
   
import Foundation
import FirebaseFirestore
import Combine

class SearchManager: ObservableObject {
    
//    init() {
//        // Test the food initialization with decimal values
//        testFoodInitialization()
//    }
    
    private var db = Firestore.firestore()
    let dbName = "test" // Change later for production
    
    @Published var items: [Food] = []
    
    // Reserved keywords
    let CAL_KEY = "CALORIES"
    let FAT_KEY = "FAT"
    let CARB_KEY = "CARBS"
    let PROT_KEY = "PROTEIN"
    
    
//    func testFoodInitialization() {
//        // Example decimal values for testing
//        let calories = 45.6789
//        let fat = 9.8765
//        let carbohydrates = 23.4567
//        let protein = 12.3456
//        
//        // Initialize Food object manually with these values
//        let food = Food(
//            id: "test123",  // Unique ID
//            name: "Test Food",
//            foodGroup: "Test Group",
//            food_id: 12345,
//            calories: roundToTwoDecimalPlaces(calories),
//            fat: roundToTwoDecimalPlaces(fat),
//            carbohydrates: roundToTwoDecimalPlaces(carbohydrates),
//            protein: roundToTwoDecimalPlaces(protein),
//            suitableFor: ["Vegan"]
//        )
//        
//        // Log the values to see if rounding works
//        print("Food Initialized: \(food)")
//        
//        // Optionally, you can manually check if values are rounded correctly
//        assert(food.calories == 45.68, "Calories are not rounded correctly!")
//        assert(food.fat == 9.88, "Fat is not rounded correctly!")
//        assert(food.carbohydrates == 23.46, "Carbs are not rounded correctly!")
//        assert(food.protein == 12.35, "Protein is not rounded correctly!")
//        
//        print("Test passed if no assertions failed!")
//    }

    // Function to fetch items based on a search query
    func fetchItems(searchQuery: String) {
        
        // Check to see if there is an equal operator
        let query = processSearchTerm(searchQuery)
        
        // If there is an '=' & there is something before or after it
        if (query.before != nil && query.after != nil) {
            
            var keywordFlag = false
            var keyword = ""
            if (query.before?.uppercased() == CAL_KEY){
                keyword = "Calories"
                keywordFlag = true
            }
            else if (query.before?.uppercased() == FAT_KEY){
                keyword = "Fat (g)"
                keywordFlag = true
            }
            else if (query.before?.uppercased() == CARB_KEY){
                keyword = "Carbohydrate (g)"
                keywordFlag = true
            }
            else if (query.before?.uppercased() == PROT_KEY){
                keyword = "Protein (g)"
                keywordFlag = true
            }
            
            var operandFlag = false
            let operandCheck = parseFirstCharacter(from: query.after ?? "")
            if operandCheck.firstCharacter == "<" || operandCheck.firstCharacter == ">" {
                operandFlag = true
            }
            
            var valueFlag = false
            var value = 0.0
            if operandFlag == true {
                value = Double(operandCheck.remainingString) ?? -1
                if value >= 0 {
                    valueFlag = true
                }
            }
            else {
                value = Double(query.after ?? "") ?? -1
                if value >= 0 {
                    valueFlag = true
                }
            }
            
            if (keywordFlag == true && valueFlag == true) {
                
                // Perform search for items greater than criteria
                if operandCheck.firstCharacter == ">" {
                    getItemGreater(field: keyword, searchQuery: value) { result in
                        switch result {
                        case .success(let fetchedItems):
                            DispatchQueue.main.async {
                                self.items = fetchedItems
                            }
                        case .failure(let error):
                            print("Error fetching items: \(error.localizedDescription)")
                        }
                    }
                }
                
                // Perform search for items less than criteria
                else if operandCheck.firstCharacter == "<" {
                    getItemLess(field: keyword, searchQuery: value) { result in
                        switch result {
                        case .success(let fetchedItems):
                            DispatchQueue.main.async {
                                self.items = fetchedItems
                            }
                        case .failure(let error):
                            print("Error fetching items: \(error.localizedDescription)")
                        }
                    }
                }
                else {
                    getItemByValue(field: keyword, searchQuery: value) { result in
                        switch result {
                        case .success(let fetchedItems):
                            DispatchQueue.main.async {
                                self.items = fetchedItems
                            }
                        case .failure(let error):
                            print("Error fetching items: \(error.localizedDescription)")
                        }
                    }
                }
            }
            else {
                getItemByName(searchQuery: searchQuery) { result in
                    switch result {
                    case .success(let fetchedItems):
                        DispatchQueue.main.async {
                            // Filter the items locally after fetching all of them
                            self.items = self.filterItems(fetchedItems, withQuery: searchQuery)
                        }
                    case .failure(let error):
                        print("Error fetching items: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Search by name (if there's no '=' in query)
        else {
            getItemByName(searchQuery: searchQuery) { result in
                switch result {
                case .success(let fetchedItems):
                    DispatchQueue.main.async {
                        // Filter the items locally after fetching all of them
                        self.items = self.filterItems(fetchedItems, withQuery: searchQuery)
                    }
                case .failure(let error):
                    print("Error fetching items: \(error.localizedDescription)")
                }
            }
        }
    }

    
    // Function to filter items based on the search query (case-insensitive partial matching)
    func filterItems(_ items: [Food], withQuery query: String) -> [Food] {
        // Make the query case-insensitive
        let lowercasedQuery = query.lowercased()
        return items.filter { food in
            food.name.lowercased().contains(lowercasedQuery) ||
            food.foodGroup.lowercased().contains(lowercasedQuery) ||
            String(food.calories).contains(lowercasedQuery) ||
            String(food.fat).contains(lowercasedQuery) ||
            String(food.carbohydrates).contains(lowercasedQuery) ||
            String(food.protein).contains(lowercasedQuery)
        }
    }

    func getItemByName(searchQuery: String, completion: @escaping (Result<[Food], Error>) -> Void) {
        db.collection(dbName)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let snapshot = snapshot else {
                    completion(.success([]))
                    return
                }

                // Log the document data to ensure we have correct data
                snapshot.documents.forEach { document in
                    print("Fetched document data: \(document.data())")
                }

                // Map Firestore data to Food model with rounding
                let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                    // Fetch values and round them to 2 decimal places
                    let calories = (d["Calories"] as? Double ?? 0.0)
                    let fat = (d["Fat (g)"] as? Double ?? 0.0)
                    let carbohydrates = (d["Carbohydrate (g)"] as? Double ?? 0.0)
                    let protein = (d["Protein (g)"] as? Double ?? 0.0)
                    
                    let food = Food(
                        id: d.documentID,  // Firestore document ID
                        name: d["name"] as? String ?? "",  // Handle name
                        foodGroup: d["Food Group"] as? String ?? "",  // Handle Food Group
                        food_id: d["ID"] as? Int32 ?? 0,  // Handle food_id
                        calories: calories,  // Use rounded value
                        fat: fat,  // Use rounded value
                        carbohydrates: carbohydrates,  // Use rounded value
                        protein: protein,  // Use rounded value
                        suitableFor: d["suitableFor"] as? [String] ?? []  // Handle suitableFor as an array of strings
                    )
                    print("Mapped Food item: \(food)")  // Log mapped food to verify values
                    return food
                }

                // Return the successfully fetched items
                completion(.success(fetchedItems))
            }
    }
    
    func getItemGreater(field: String, searchQuery: Double, completion: @escaping (Result<[Food], Error>) -> Void) {
        db.collection(dbName)
            .whereField(field, isGreaterThan: searchQuery)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.success([]))
                    return
                }

                let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                    // Fetch values and round them to 2 decimal places
                    let calories = PantryManager.shared.roundToTwoDecimalPlaces((d["Calories"] as? Double ?? 0.0))
                    let fat = PantryManager.shared.roundToTwoDecimalPlaces((d["Fat (g)"] as? Double ?? 0.0))
                    let carbohydrates = PantryManager.shared.roundToTwoDecimalPlaces((d["Carbohydrate (g)"] as? Double ?? 0.0))
                    let protein = PantryManager.shared.roundToTwoDecimalPlaces((d["Protein (g)"] as? Double ?? 0.0))

                    return Food(
                        id: d.documentID,
                        name: d["name"] as? String ?? "",
                        foodGroup: d["Food Group"] as? String ?? "",
                        food_id: d["ID"] as? Int32 ?? 0,
                        calories: calories,
                        fat: fat,
                        carbohydrates: carbohydrates,
                        protein: protein,
                        suitableFor: d["suitableFor"] as? [String] ?? []
                    )
                }
                
                completion(.success(fetchedItems))
            }
    }
    
    func getItemLess(field: String, searchQuery: Double, completion: @escaping (Result<[Food], Error>) -> Void) {
        db.collection(dbName)
            .whereField(field, isLessThan: searchQuery)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.success([]))
                    return
                }

                let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                    // Fetch values and round them to 2 decimal places
                    let calories = PantryManager.shared.roundToTwoDecimalPlaces((d["Calories"] as? Double ?? 0.0))
                    let fat = PantryManager.shared.roundToTwoDecimalPlaces((d["Fat (g)"] as? Double ?? 0.0))
                    let carbohydrates = PantryManager.shared.roundToTwoDecimalPlaces((d["Carbohydrate (g)"] as? Double ?? 0.0))
                    let protein = PantryManager.shared.roundToTwoDecimalPlaces((d["Protein (g)"] as? Double ?? 0.0))

                    return Food(
                        id: d.documentID,
                        name: d["name"] as? String ?? "",
                        foodGroup: d["Food Group"] as? String ?? "",
                        food_id: d["ID"] as? Int32 ?? 0,
                        calories: calories,
                        fat: fat,
                        carbohydrates: carbohydrates,
                        protein: protein,
                        suitableFor: d["suitableFor"] as? [String] ?? []
                    )
                }
                
                completion(.success(fetchedItems))
            }
    }

    func getItemByValue(field: String, searchQuery: Double, completion: @escaping (Result<[Food], Error>) -> Void) {
        db.collection(dbName)
            .whereField(field, isEqualTo: searchQuery)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.success([]))
                    return
                }

                let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                    // Fetch values and round them to 2 decimal places
                    let calories = PantryManager.shared.roundToTwoDecimalPlaces((d["Calories"] as? Double ?? 0.0))
                    let fat = PantryManager.shared.roundToTwoDecimalPlaces((d["Fat (g)"] as? Double ?? 0.0))
                    let carbohydrates = PantryManager.shared.roundToTwoDecimalPlaces((d["Carbohydrate (g)"] as? Double ?? 0.0))
                    let protein = PantryManager.shared.roundToTwoDecimalPlaces((d["Protein (g)"] as? Double ?? 0.0))

                    return Food(
                        id: d.documentID,
                        name: d["name"] as? String ?? "",
                        foodGroup: d["Food Group"] as? String ?? "",
                        food_id: d["ID"] as? Int32 ?? 0,
                        calories: calories,
                        fat: fat,
                        carbohydrates: carbohydrates,
                        protein: protein,
                        suitableFor: d["suitableFor"] as? [String] ?? []
                    )
                }
                
                completion(.success(fetchedItems))
            }
    }
    
    // Helper function to process search term (split by '=')
    func processSearchTerm(_ searchTerm: String) -> (before: String?, after: String?) {
        let components = searchTerm.split(separator: "=").map { String($0).trimmingCharacters(in: .whitespaces) }
        if components.count == 2 {
            return (before: components[0], after: components[1])
        }
        return (before: nil, after: nil)
    }
    
    // Helper function to parse first character (for operands like < or >)
    func parseFirstCharacter(from string: String) -> (firstCharacter: String, remainingString: String) {
        let firstCharacter = String(string.prefix(1))
        let remainingString = String(string.dropFirst())
        return (firstCharacter, remainingString)
    }
}
