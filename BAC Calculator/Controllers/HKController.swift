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
    
    // Define the weight type
    let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    
    
    func getAuthorization() -> Void {
        
        let readTypes: Set<HKObjectType> = [bacType, weightType, HKObjectType.characteristicType(forIdentifier: .biologicalSex)!]
                let shareTypes: Set<HKSampleType> = [bacType]
                
                healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
                    if success {
                        print("Authorization granted for BAC, weight, and biological sex")
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
    
    // Function to retrieve user's weight (now named `userBodyMass`)
        func getUserBodyMass(completion: @escaping (Double?) -> Void) {
            guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
                print("Body mass data type is not available")
                completion(nil)
                return
            }

            let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (_, results, error) in
                guard let sample = results?.first as? HKQuantitySample else {
                    print("No body mass data available or error: \(String(describing: error))")
                    completion(nil)
                    return
                }
                
                let bodyMassKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                completion(bodyMassKg)
            }
            
            healthStore.execute(query)
        }

        // Function to retrieve user's biological sex (now named `userBiologicalSex`)
        func getUserBiologicalSex(completion: @escaping (Int?) -> Void) {
            do {
                let sexObject = try healthStore.biologicalSex()
                let biologicalSex: Int? = {
                    switch sexObject.biologicalSex {
                    case .male:
                        return 1
                    case .female:
                        return 2
                    default:
                        return 1
                    }
                }()
                completion(biologicalSex)
            } catch {
                print("Error retrieving biological sex: \(error)")
                completion(nil)
            }
        }
    
    
    
    
}
