//
//  MealSuggestionsTest.swift
//  MealSuggestionsTest
//
//  Created by Heather Amistani on 12/1/24.
//

import XCTest

@testable import Fit_Pantry

class MealPlanViewTest: XCTestCase{
    var mealPlanView: MealPlanView!
    
    override func setUp(){
        super.setUp()
        mealPlanView = MealPlanView()
        mealPlanView.loadViewIfNeeded()
    }
    
    func testMealPlanGeneration(){
        let generatedMealPlan = mealPlanView.generateMealPlan()
        
        XCTAssertEqual(generatedMealPlan.count, 3, "Meal Plan should contain 3 meals.")
        XCTAssertTrue(generatedMealPlan.contains("Apples and Toast"), "Meal plan should contain 'Apples and Toast'.")
        XCTAssertTrue(generatedMealPlan.contains("Chicken and Rice"), "Meal plan should contain 'Chicken and Rice'.")
        XCTAssertTrue(generatedMealPlan.contains("Oatmeal with berries"), "Meal plan should contain 'Oatmeal with berries'.")
    }
    
    func testMealPlanTableView() {
        mealPlanView.mealPlan = ["Breakfast", "Lunch", "Dinner"]
        
        let tableView = mealPlanView.mealPlanTableView!
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 3, "Table view should have 3 rows.")
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = mealPlanView.tableView(tableView, cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "Breakfast", "Cell should display 'Breakfast'.")
    }
}
