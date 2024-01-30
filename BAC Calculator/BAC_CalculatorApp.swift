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
    var body: some Scene {
        WindowGroup {
            ContentView(before: clock.now)
        }
    }
}
