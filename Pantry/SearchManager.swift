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
        private var db = Firestore.firestore()
        let dbName = "test" // Change later for production
        
        @Published var items: [Food] = []
        
        // Reserved keywords
        let CAL_KEY = "CALORIES"
        let FAT_KEY = "FAT"
        let CARB_KEY = "CARBS"
        let PROT_KEY = "PROTEIN"
        
        // Function to fetch items based on a search query
        func fetchItems(searchQuery: String) {
            
            // Check to see if there is an equal operator
            let query = processSearchTerm(searchQuery)
            //print(query.self, String(query.after ?? "nil"), String(query.before ?? "nil"))
            
            // If there is an '=' & there is something before or after it
            if (query.before != nil && query.after != nil) {
                //print("Search by value")
                
                // See if there is a keyword before =
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
                
                // See if there is a < > after the =
                var operandFlag = false
                let operandCheck = parseFirstCharacter(from: query.after ?? "")
                if operandCheck.firstCharacter == "<" || operandCheck.firstCharacter == ">" {
                    operandFlag = true
                }
                
                // See if there is a number after everything else
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
                
                // Critera for advance search is met, search by specific value
                if (keywordFlag == true && valueFlag == true) {
                    
                    // Preform search for items greater than criteria
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
                    
                    // Preform search for items less than criteria
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
                
                // Critera for advance search is false, search by name
                else {
                    getItemByName(searchQuery: searchQuery) { result in
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
            
            // Search by name
            else {
                getItemByName(searchQuery: searchQuery) { result in
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
        
        // Function to fetch a list of items by name
        func getItemByName(searchQuery: String, completion: @escaping (Result<[Food], Error>) -> Void) {
            db.collection(dbName)
                //.whereField("name", isEqualTo: searchQuery) // Explicit name search
                .whereField("name", isGreaterThanOrEqualTo: searchQuery)
                .whereField("name", isLessThanOrEqualTo: searchQuery + "\u{f7ff}")
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // If search yeild nothing return an empty array
                    guard let snapshot = snapshot else {
                        completion(.success([]))
                        return
                    }
                    
                    // Return items from search
                    let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                        Food(
                            id: d.documentID,
                            name: d["name"] as? String ?? "",
                            foodGroup: d["Food Group"] as? String ?? "",
                            food_id: d["ID"] as? Int32 ?? 0,
                            calories: d["Calories"] as? Int32 ?? 0,
                            fat: d["Fat (g)"] as? Float32 ?? 0.0,
                            carbohydrates: d["Carbohydrate (g)"] as? Float32 ?? 0.0,
                            protein: d["Protein (g)"] as? Float32 ?? 0.0,
                            suitableFor: d["suitableFor"] as? [String] ?? []
                        )
                    }
                    
                    // Return statement
                    completion(.success(fetchedItems))
                }
        }
        
        // Get items by a value, exact match only
        func getItemByValue(field: String, searchQuery: Double, completion: @escaping (Result<[Food], Error>) -> Void) {
            db.collection(dbName)
                .whereField(field, isEqualTo: searchQuery) // Explicit name search
                //.whereField("name", isGreaterThanOrEqualTo: searchQuery)
                //.whereField("name", isLessThanOrEqualTo: searchQuery)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // If search yeild nothing return an empty array
                    guard let snapshot = snapshot else {
                        completion(.success([]))
                        return
                    }
                    
                    // Return items from search
                    let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                        Food(
                            id: d.documentID,
                            name: d["name"] as? String ?? "",
                            foodGroup: d["Food Group"] as? String ?? "",
                            food_id: d["ID"] as? Int32 ?? 0,
                            calories: d["Calories"] as? Int32 ?? 0,
                            fat: d["Fat (g)"] as? Float32 ?? 0.0,
                            carbohydrates: d["Carbohydrate (g)"] as? Float32 ?? 0.0,
                            protein: d["Protein (g)"] as? Float32 ?? 0.0,
                            suitableFor: d["suitableFor"] as? [String] ?? []
                        )
                    }
                    
                    // Return statement
                    completion(.success(fetchedItems))
                }
            
        }
        
        // Get all items greater than a value
        func getItemGreater(field: String, searchQuery: Double, completion: @escaping (Result<[Food], Error>) -> Void) {
            db.collection(dbName)
                //.whereField(field, isEqualTo: searchQuery) // Explicit name search
                .whereField(field, isGreaterThanOrEqualTo: searchQuery)
                //.whereField("name", isLessThanOrEqualTo: searchQuery)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // If search yeild nothing return an empty array
                    guard let snapshot = snapshot else {
                        completion(.success([]))
                        return
                    }
                    
                    // Return items from search
                    let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                        Food(
                            id: d.documentID,
                            name: d["name"] as? String ?? "",
                            foodGroup: d["Food Group"] as? String ?? "",
                            food_id: d["ID"] as? Int32 ?? 0,
                            calories: d["Calories"] as? Int32 ?? 0,
                            fat: d["Fat (g)"] as? Float32 ?? 0.0,
                            carbohydrates: d["Carbohydrate (g)"] as? Float32 ?? 0.0,
                            protein: d["Protein (g)"] as? Float32 ?? 0.0,
                            suitableFor: d["suitableFor"] as? [String] ?? []
                        )
                    }
                    
                    // Return statement
                    completion(.success(fetchedItems))
                }
        }
        
        // Get all items less than a value
        func getItemLess(field: String, searchQuery: Double, completion: @escaping (Result<[Food], Error>) -> Void) {
            db.collection(dbName)
                //.whereField(field, isEqualTo: searchQuery) // Explicit name search
                //.whereField(field, isGreaterThanOrEqualTo: searchQuery)
                .whereField(field, isLessThanOrEqualTo: searchQuery)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // If search yeild nothing return an empty array
                    guard let snapshot = snapshot else {
                        completion(.success([]))
                        return
                    }
                    
                    // Return items from search
                    let fetchedItems: [Food] = snapshot.documents.compactMap { d in
                        Food(
                            id: d.documentID,
                            name: d["name"] as? String ?? "",
                            foodGroup: d["Food Group"] as? String ?? "",
                            food_id: d["ID"] as? Int32 ?? 0,
                            calories: d["Calories"] as? Int32 ?? 0,
                            fat: d["Fat (g)"] as? Float32 ?? 0.0,
                            carbohydrates: d["Carbohydrate (g)"] as? Float32 ?? 0.0,
                            protein: d["Protein (g)"] as? Float32 ?? 0.0,
                            suitableFor: d["suitableFor"] as? [String] ?? []
                        )
                    }
                    
                    // Return statement
                    completion(.success(fetchedItems))
                }
        }
        
        
        // Break the search query into two parts if there is an '='
        func processSearchTerm(_ searchTerm: String) -> (before: String?, after: String?) {
            // Check if the search term contains '='
            guard let equalsIndex = searchTerm.firstIndex(of: "=") else {
                // Return nil for both if '=' is not found
                return (nil, nil)
            }
            
            // Extract the part before '='
            let before = searchTerm[..<equalsIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Extract the part after '='
            let afterStartIndex = searchTerm.index(after: equalsIndex)
            let after = searchTerm[afterStartIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            
            return (before.isEmpty ? nil : before, after.isEmpty ? nil : after)
        }
        
        func parseFirstCharacter(from input: String) -> (firstCharacter: Character?, remainingString: String) {
            // Check for empty string
            guard !input.isEmpty else {
                return (nil, input) // Return nil if the string is empty
            }
            
            // Get first character
            let firstCharacter = input.first // Get the first character
            
            // Remove first character and return remainder of string
            let remainingString = String(input.dropFirst())
            return (firstCharacter, remainingString)
        }
        
    }
