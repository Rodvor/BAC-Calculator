//
//  ContentView.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 29.1.2024.
//

import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    
    @StateObject var BloodAlcohol = BloodAlcoholController()
    @Environment(\.modelContext) private var context
    
    let clock = ContinuousClock() //Clock for measuring the time between drinks
    let defaults = UserDefaults.standard
    
    var body: some View {
            
        TabView {
            MainView(BloodAlcohol: BloodAlcohol, before: clock.now)
                .modelContext(context)
                .tabItem {
                    Label("BAC", systemImage: "wineglass")
            }
            
            
            HistoryView()
                .modelContext(context)
                .tabItem {
                    Label("History", systemImage: "list.bullet")
            }

            SettingsView(BloodAlcohol: BloodAlcohol, sex: defaults.integer(forKey: "sex"), weight: defaults.string(forKey: "weight") ?? "10,0")
                .modelContext(context)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Drink.self, inMemory: true)
}
