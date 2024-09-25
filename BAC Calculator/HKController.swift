//
//  HKController.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 25.9.2024.
//

import HealthKit

struct HKController {
    
    // Initialize the HealthStore
    let healthStore = HKHealthStore()

    // Define the BAC data type
    let bacType = HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!
    
    
    func getAuthorization() -> Void {
        
        // Request authorization to read and write BAC
        healthStore.requestAuthorization(toShare: [bacType], read: [bacType]) { (success, error) in
            if success {
                print("Authorization granted for BAC")
            } else {
                print("Authorization denied or error occurred: \(String(describing: error))")
            }
        }
    }
    
    func saveBloodAlcoholContent(bacValue: Double, date: Date) {
        // Ensure HealthKit is available on the device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device")
            return
        }

        // Define the BAC type
        guard let bacType = HKQuantityType.quantityType(forIdentifier: .bloodAlcoholContent) else {
            print("Blood Alcohol Content type is not available in HealthKit")
            return
        }

        // Create a quantity with the given BAC value (Unit: Percent)
        let bacQuantity = HKQuantity(unit: HKUnit.percent(), doubleValue: bacValue)

        // Create a sample for the BAC at the given date
        let bacSample = HKQuantitySample(type: bacType, quantity: bacQuantity, start: date, end: date)

        // Save the sample to HealthKit
        healthStore.save(bacSample) { (success, error) in
            if success {
                print("Successfully saved BAC sample")
            } else {
                print("Error saving BAC sample: \(String(describing: error))")
            }
        }
    }
    
    
    
    
}
