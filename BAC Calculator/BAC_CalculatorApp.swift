//
//  BAC_CalculatorApp.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 29.1.2024.
//

import SwiftUI

@main
struct BAC_CalculatorApp: App {
    let clock = ContinuousClock()
    let defaults = UserDefaults.standard
    
    init() {
        let defaults: [String: Any] = [
            "weight": "70,0",
            "sex": 1,
            "mode": 1
        ]

        UserDefaults.standard.register(defaults: defaults)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(before: clock.now, sex: defaults.integer(forKey: "sex"), mode: defaults.integer(forKey: "mode"), weight: defaults.string(forKey: "weight") ?? "10,0")
        }
    }
}
