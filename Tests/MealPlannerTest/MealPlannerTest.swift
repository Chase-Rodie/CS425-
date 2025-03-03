//
//  MealPlannerTest.swift
//  Fit PantryTests
//
//  Created by Heather Amistani on 11/11/24.
//  Edited by Heather Amistani 03/03/2024
//

import XCTest
@testable import Fit_Pantry

class MealPlannerTest: XCTestCase {

    // MARK: - Happy Path Tests

    //MARK: - Test Calculate Daily Calories
    func testCalculateDailyCalories() {
        // Input values
        let age = 25
        let weightInLbs = 150.0
        let heightInFeet = 5
        let heightInInches = 10
        let gender = "male"
        let goal = "lose"
        let activityLevel = "Active"
        
        // Expected calories for these inputs
        let expectedCalories = 2072
        
        // Test function
        let calculatedCalories = calculateDailyCalories(
            age: age,
            weightInLbs: weightInLbs,
            heightInFeet: heightInFeet,
            heightInInches: heightInInches,
            gender: gender,
            goal: goal,
            activityLevel: activityLevel
        )
        
        // Assert
        XCTAssertEqual(calculatedCalories, expectedCalories, "Calories calculation is incorrect.")
    }
    
    //MARK: - Test Calculate BMI
    func testCalculateBMI() {
        //Input Values
        let weightInLbs = 150.0
        let heightInFeet = 5
        let heightInInches = 10
        let expectedBMI = 21.5
        
        guard let calculatedBMI = calculateBMI(weightInLbs: weightInLbs, heightInFeet: heightInFeet, heightInInches: heightInInches) else {
            XCTFail("BMI calculation returned nil for valid input.")
            return
        }
        
        XCTAssertEqual(calculatedBMI, expectedBMI, accuracy: 0.1, "BMI calculation is incorrect.")
    }

    
    //MARK: - Test Health Tip
    func testHealthTip() {
        // Input BMI
        let bmi = 30.0
        
        // Expected health tip
        let expectedTip = "According to your BMI you are obese."
        
        // Test function
        let healthTipResult = healthTip(for: bmi)
        
        // Assert
        XCTAssertEqual(healthTipResult, expectedTip, "Health tip generation is incorrect.")
    }
    
    //MARK: - Test Food Suggestions
    func testSuggestFoods() {
        // Create a test user
        let testUser = UserMeal(
            age: 30,
            weightInLbs: 160.0,
            heightInFeet: 5,
            heightInInches: 9,
            gender: "female",
            dietaryRestrictions: ["nut-free"],
            goal: "maintain",
            onMedications: nil,
            hormoneTherapy: nil,
            activityLevel: "Lightly Active",
            mealPreferences: ["High Protein"],
            allergies: nil
        )
        
        // Test function
        let suggestedFoods = suggestFoods(for: testUser)
        
        // Check that restricted foods are not included
        XCTAssertFalse(
            suggestedFoods.contains { food in food.name == "Chicken Breast" || food.name == "Eggs" },
            "Suggested foods should not contain restricted items."
        )
    }
    
    //MARK: - Test Format User Data
    func testFormatUserData() {
        // Create a test user
        let testUser = UserMeal(
            age: 25,
            weightInLbs: 150.0,
            heightInFeet: 5,
            heightInInches: 10,
            gender: "male",
            dietaryRestrictions: ["vegetarian"],
            goal: "gain",
            onMedications: ["Vitamin D"],
            hormoneTherapy: nil,
            activityLevel: "Lightly Active",
            mealPreferences: ["Fruit"],
            allergies: ["Gluten"]
        )
        
        // Test function
        let formattedData = formatUserData(user: testUser)
        
        // Expected output
        let expectedOutput = """
        Age: 25
        Weight: 150.0 lbs
        Height: 5 ft 10 in
        Gender: male
        Goal: gain
        Activity Level: Lightly Active
        """
        
        // Assert
        XCTAssertEqual(formattedData, expectedOutput, "User data formatting is incorrect.")
    }
    
    // MARK: - Unhappy Path Tests

    
//    //MARK: - Test Invalid Dietary Restrictions Input
//    func testInvalidDietaryRestriction() {
//        let invalidRestriction = ""
//        let result = saveDietaryRestrictions(restriction: invalidRestriction)
//        XCTAssertFalse(result.success)
//        XCTAssertEqual(result.errorMessage, "Please enter a valid dietary restriction.")
//    }

    //MARK: - Test Invalid BMI Data Entry
    func testInvalidBMIDataEntry() {
        let invalidWeight = -150.0
        let heightInFeet = 5
        let heightInInches = 10
        
        let result = calculateBMI(weightInLbs: invalidWeight, heightInFeet: heightInFeet, heightInInches: heightInInches)
        
        // Check if the result is nil for invalid input
        XCTAssertNil(result, "BMI calculation should fail for invalid input.")
    }
    
    
//    //MARK: - Test Empty Meal Plan Generation
//    func testEmptyMealPlanGeneration() {
//        let incompleteUser = UserMeal(
//            age: 0,
//            weightInLbs: 0,
//            heightInFeet: 0,
//            heightInInches: 0,
//            gender: "",
//            dietaryRestrictions: [],
//            goal: "",
//            activityLevel: "",
//            mealPreferences: []
//        )
//        
//        let result = generateMealPlan(for: incompleteUser)
//        XCTAssertEqual(result.errorMessage, "Complete your profile to generate a meal plan.")
//    }
    
    
//    //MARK: - Test API Call Failure for Food Suggestions
//    func testAPICallFailureForFoodSuggestions() {
//        // Simulate API failure
//        let apiResult = fetchFoodSuggestions(success: false)
//        
//        XCTAssertEqual(apiResult.errorMessage, "Unable to fetch suggestions. Please try again later.")
//    }
    
}
