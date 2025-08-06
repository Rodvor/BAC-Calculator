//
//  SettingsView.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 27.6.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @StateObject var BloodAlcohol: BloodAlcoholController
    let defaults = UserDefaults.standard
    
    @Environment(\.modelContext) private var context
    @Query private var drinks: [Drink]
    
    //User adjustable settings
    @State var sex: Int       // User's biological sex
    @State var weight: String // User's weight
    
    let MALE: Int = 1 //Readability variable e.g. if sex == MALE {}
    
    @FocusState private var weightFocused: Bool
    
    var body: some View {
            
        NavigationStack {
            Form {
                Section(header: Text("Body Details")) {
                    HStack {
                        Text("Weight: ")
                        Spacer()
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($weightFocused)
                            .frame(width: 100, height: 20, alignment: .center)
                    }.onSubmit {
                        updateSettings()
                    }
                    
                    HStack {
                        Picker(selection: $sex, label: Text("Sex")) {
                            Text("Male").tag(1)
                            Text("Female").tag(2)
                        }.onChange(of: sex) {
                            updateSettings()
                        }
                    }
                    
                    Button(action:retrieveBodydata) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Import from Health")
                        }
                    }
                }
                
                Section() {
                    Button(action: {
                        updateSettings()
                        weightFocused = false
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section() {
                    Button(role: .destructive, action: reset) {
                        Text("Reset Alcohol Data")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            
            .navigationTitle("Settings")
        }
    }
    
    func reset() -> Void {
        hideKeyboard()
        BloodAlcohol.alcohol = 0
        BloodAlcohol.stomachVolume = 0
        BloodAlcohol.stomachConcentration = 0
        BloodAlcohol.setBody(newWeight: formatToFloat(weight), newIsMale: sex == MALE)
        
        // Remove drinks from history
        for drink in drinks {
            context.delete(drink)
        }
        
        // Save history
        do {
            try context.save()
        } catch {
            print("Failed to delete all drinks: \(error)")
        }
    }
    
    func updateSettings() -> Void {
        
        // Update defaults
        defaults.set(sex, forKey: "sex")
        defaults.set(weight, forKey: "weight")
        
        BloodAlcohol.setBody(newWeight: formatToFloat(weight), newIsMale: sex == MALE)
    }
    
    func retrieveBodydata() -> Void {
        
        // Retrieve user sex and weight from HealthKit
        let hkController = HKController()

        hkController.getUserBodyMass { bodyMass in
            if let bodyMass = bodyMass {
                print("User body mass: \(bodyMass) kg")
                weight = String(format: "%.2f", bodyMass)
                updateSettings()
            } else {
                print("Could not retrieve user body mass")
            }
        }

        hkController.getUserBiologicalSex { biologicalSex in
            if let biologicalSex = biologicalSex {
                print("User biological sex: \(biologicalSex)")
                sex = biologicalSex
                updateSettings()
            } else {
                print("Could not retrieve user biological sex")
            }
        }
    }
    
    func hideKeyboard() -> Void {
        
        weightFocused = false
    }
}

#Preview {
    SettingsView(BloodAlcohol: BloodAlcoholController(), sex: 1, weight: "70,0")
}
