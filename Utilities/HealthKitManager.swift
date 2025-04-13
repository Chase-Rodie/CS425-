//
//  HealthKitManager.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 4/12/25.
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device")
            completion(false)
            return
        }

        guard
            let energy = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed),
            let protein = HKObjectType.quantityType(forIdentifier: .dietaryProtein),
            let fat = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal),
            let carbs = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
        else {
            print("One or more HealthKit data types are unavailable.")
            completion(false)
            return
        }

        let typesToShare: Set = [energy, protein, fat, carbs]
        let typesToRead: Set = [energy, protein, fat, carbs]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization successful")
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "unknown error")")
            }
            completion(success)
        }
    }

    func logMealToHealthKit(calories: Double, protein: Double, carbs: Double, fat: Double) {
        let now = Date()

        func createSample(typeIdentifier: HKQuantityTypeIdentifier, value: Double, unit: HKUnit) -> HKQuantitySample? {
            guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
                print("Could not create sample for: \(typeIdentifier.rawValue)")
                return nil
            }
            let quantity = HKQuantity(unit: unit, doubleValue: value)
            return HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now)
        }

        let samples = [
            createSample(typeIdentifier: .dietaryEnergyConsumed, value: calories, unit: .kilocalorie()),
            createSample(typeIdentifier: .dietaryProtein, value: protein, unit: .gram()),
            createSample(typeIdentifier: .dietaryCarbohydrates, value: carbs, unit: .gram()),
            createSample(typeIdentifier: .dietaryFatTotal, value: fat, unit: .gram())
        ].compactMap { $0 } // Remove nils safely

        guard !samples.isEmpty else {
            print("No valid samples to save to HealthKit.")
            return
        }

        healthStore.save(samples) { success, error in
            if success {
                print("Successfully logged meal to HealthKit")
            } else {
                print("Error saving to HealthKit: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
