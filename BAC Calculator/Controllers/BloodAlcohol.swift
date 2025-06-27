//
//  BloodAlcohol.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 19.3.2025.
//

import Foundation
import SwiftData

class BloodAlcoholController: ObservableObject {
    
    // We assume no alcohol and 70kg male
    
    @Published var alcohol: Float = 0.0  // Grams of alcohol in the blood
    @Published var stomachVolume: Float = 0.0   // Milliliters of volume in stomach
    var stomachConcentration: Float = 0.0  // % of alcohol in stomach (ml alco / total ml)
    
    var weight: Float = 70.0  // Human weight kg
    var sexConstant: Float = 0.71 * 0.9   // Sex constant 0.71 L/kg for men and 0.58 L/kg for women
    var metabolism: Float = 7.455    // Grams of alcohol per hour metabolised
    
    let alcoholDensity: Float = 0.789 // g/ml
    let k: Float = 7.0 // 1/h. Absorption constant
    
    let BACController = HKController()
    
    let debug: Bool = false
    
    init() {}
    
    // Calculate grams of alcohol after time t [s] has passed
    func calculateAlcohol(_ t: Float) -> Float {
        
        let ts = t / 3600.0
        
        let absorptionData: [Float] = calculateAbsorption(t) // USE t
        let alcoholAbsorbed: Float = absorptionData[0]
        
        if debug {
            print("\(alcoholAbsorbed)g of alcohol was absorbed and used in calculation")
        }
        
        // Calculate alcohols :)
        let totalAlcohol: Float = alcohol + alcoholAbsorbed
        let metabolisedAlcohol: Float = metabolism * ts
        let remainingAlcohol: Float = totalAlcohol - metabolisedAlcohol
        
        // Debug prints
        if debug {
            print("Metabolised Alcohol: \(metabolisedAlcohol)")
        }
        
        // We don't do negatives
        if remainingAlcohol > 0 {
            return remainingAlcohol
        }
        
        
        
        return 0.0
    }
    
    // Calculate the volume absorbed by stomach after time t [s]
    // [grams of alcohol, ml absorbed from stomach]
    func calculateAbsorption(_ t: Float) -> [Float] {
        
        // Define constants
        let ts = t / 3600.0
        
        // Calculate the total volume absorbed by stomach
        var volumeAbsorbed: Float = stomachVolume * (1 - exp(-k*ts))
        
        // If 95% of volume is consumed -> assume everything is consumed
        if volumeAbsorbed > stomachVolume * 0.90 || stomachVolume < 20 {
            volumeAbsorbed = stomachVolume
        }
        // Calculate the amount of alcohol [g] that was absorbed
        let alcoholAbsorbed: Float = volumeAbsorbed * stomachConcentration * alcoholDensity
        
        // Debug prints
        if debug {
            print("Alcohol absorbed: \(alcoholAbsorbed)g")
            print("Volume absorbed: \(volumeAbsorbed)ml")
        }
            
            
        return [alcoholAbsorbed, volumeAbsorbed]
        
    }
    
    
    // Returns current blood alcohol content
    func getCurrentBAC() -> Float {
        
        // Blood Alcohol Content is grams of alcohol divided by volume of distribution
        let volumeDistribution: Float = sexConstant * weight
        let currentBac: Float = alcohol / volumeDistribution
        
        // Return BAC in promille
        return currentBac
        
    }
    
    // Returns time until alcohol in body has reached 0
    func timeUntilZero() -> Float {
        
        // This could be optimized by setting rough estimates to
        // the for loop ranges depending on BAC
        
        let minimum: Int = Int(((stomachVolume * stomachConcentration * alcoholDensity)*0.85 + alcohol)/metabolism * 3600)
        
        if debug {
            print("Assumed minimum time:  " + formatTime(Float(minimum)) + " or \(minimum)s")
        }
        
        for i in minimum...minimum + 3600*4 {
            
            let time = Float(i)
            
            if calculateAlcohol(time) == 0 {
                return time
            }
        }
        
        return 0.0
        
    }
    
    
    // Calculate the peak BAC [peak BAC, time until in s]
    func calculatePeakBAC() -> [Float] {
        
        if alcohol == 0 && stomachConcentration == 0 {
            return [0.0, 0.0]
        }
        
        // Calculate peak time using derivate 0
        var peakTime = -log(metabolism / (stomachVolume*stomachConcentration*alcoholDensity*k)) / k * 3600
        
        if peakTime <= 0 {
            peakTime = 0.0
        }
        
        // Calcuate peak BAC at time t
        let peakAlcohol = calculateAlcohol(peakTime)
        
        // Blood Alcohol Content is grams of alcohol divided by volume of distribution
        let volumeDistribution: Float = sexConstant * weight
        let peakBAC: Float = peakAlcohol / volumeDistribution
        
        return [peakBAC, peakTime]
        
    }
    
    func drink(volume: Float, concentration: Float) -> Void {
        
        if volume == 0 {
            return
        }
        
        // Get current amount of alcohol in stomach in milliliters
        let currentStomachAlcohol = stomachVolume * stomachConcentration
        // Get milliliters of alcohol in drink
        let newStomachAlcohol = currentStomachAlcohol + volume * concentration
        
        // Add volume to stomach
        stomachVolume += volume
        // Calculate new concentration
        stomachConcentration = newStomachAlcohol / stomachVolume
        
        if debug {
            print("Stomach alcohol: \(newStomachAlcohol)ml or \(newStomachAlcohol*0.79)g")
        }
        
    }
    
    // Update data after time t
    func updateData(_ t: Float) -> Void {
        
        let ts = t / 3600.0
        
        // Debug prints
        if debug {
            print("Updating Data: \(ts)")
        }
        
        // Get absorption data for stomach
        let absorptionData: [Float] = calculateAbsorption(t)
        
        // Update grams of alcohol in blood (USE t)
        alcohol = calculateAlcohol(t)
        
        // Update stomach here
        stomachVolume -= absorptionData[1]
        if stomachVolume <= 0 {
            stomachVolume = 0
        }
        
        // Save to health app
        BACController.getAuthorization()
        let bacValue = getCurrentBAC()/1000 // Divide by 1000 cuz HealthKit converts decimal to percent
        let currentDate = Date()
        print("Saving: \(Double(bacValue))")
        BACController.saveBloodAlcoholContent(bacValue: Double(bacValue), date: currentDate)
        
    }
    
    
    func setBody(newWeight: Float, newIsMale: Bool) {
        setSex(isMale: newIsMale)
        setWeight(newWeight)
        setMetabolism()
    }
    
    
    // Method for setting the sex of user,
    private func setSex(isMale: Bool) -> Void {
        
        // We use a multiplier because these values are used when
        // alcohol is assumed to be consumed immediately
        let multiplier: Float = 0.9
        
        // Adjust sexConstant
        if isMale {
            sexConstant = 0.71 * multiplier
        } else {
            sexConstant = 0.58 * multiplier
        }

        
    }
    
    // Method for setting weight
    private func setWeight(_ newWeight: Float) -> Void {
        weight = newWeight  
    }
    
    // Method for adjusting metabolism,
    private func setMetabolism() -> Void {
        
        let metabolismConstant: Float = 0.15 // g/L/h
        let volumeDistribution: Float = 0.71 * weight
        
        // Set new metabolism g/h of alcohol metabolised in set body
        metabolism = metabolismConstant * volumeDistribution
    }
    
    
}


@Model
class Drink {
    
    var volume: Float
    var concentration: Float
    var date: Date
    
    init(volume: Float, concentration: Float) {
        self.volume = volume
        self.concentration = concentration
        self.date = Date()
    }
    
}
