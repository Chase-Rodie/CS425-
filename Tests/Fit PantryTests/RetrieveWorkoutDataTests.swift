//
//  FoodJournalViewTests.swift
//  Fit PantryTests
//
//  Created by Lexie Reddon on 2/16/25.
//

import XCTest
@testable import Fit_Pantry

class RetrieveWorkoutDataTests: XCTestCase {
    
    var retrieveWorkoutData: RetrieveWorkoutData!

    override func setUp() {
        super.setUp()
        retrieveWorkoutData = RetrieveWorkoutData()
    }

    override func tearDown() {
        retrieveWorkoutData = nil
        super.tearDown()
    }

    func testCompletedExercises() {
        //Arrange
        let exercise1 = Exercise(category: "Strength", equipment: "Dumbbell", force: "Push",
                                 id: "1", imageURLs: [], instructions: [], level: "Beginner",
                                 mechanic: "Compound", name: "Bench Press",
                                 primaryMuscles: ["Chest"], secondaryMuscles: ["Triceps"],
                                 isComplete: true)
        let exercise2 = Exercise(category: "Strength", equipment: "Dumbbell", force: "Pull",
                                 id: "2", imageURLs: [], instructions: [], level: "Beginner",
                                 mechanic: "Compound", name: "Row",
                                 primaryMuscles: ["Back"], secondaryMuscles: ["Biceps"],
                                 isComplete: false)
        
        //Act
        retrieveWorkoutData.workoutPlan = [[exercise1, exercise2], [exercise1]]

        //retrieveWorkoutData.completedExercises()

        //Assert
        XCTAssertEqual(retrieveWorkoutData.completedExercisesCounts, [1, 1], "Completed exercises count is incorrect.")
    }

    func testMarkComplete() {
        
        //Arrange
        let exercise = Exercise(
                category: "Strength",
                equipment: "Dumbbell",
                force: "Push",
                id: "1",
                imageURLs: [],
                instructions: [],
                level: "Beginner",
                mechanic: "Compound",
                name: "Bench Press",
                primaryMuscles: ["Chest"],
                secondaryMuscles: ["Triceps"],
                isComplete: false
            )
        
        //Act
        retrieveWorkoutData.workoutPlan = [[exercise]]

        retrieveWorkoutData.markComplete(for: exercise)
        
        //Assert
        XCTAssertTrue(retrieveWorkoutData.workoutPlan[0][0].isComplete, "Exercise should be marked as complete.")
    }
}

