//
//  HistoryView.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 27.6.2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Drink.date, order: .reverse)]) private var drinks: [Drink]
    
    private var calendar: Calendar { Calendar.current }
    
    // Drinks consumed today
    private var todayDrinks: [Drink] {
        drinks.filter { calendar.isDateInToday($0.date) }
    }
    
    // Drinks consumed yesterday
    private var yesterdayDrinks: [Drink] {
        drinks.filter { calendar.isDateInYesterday($0.date) }
    }
    
    // Drinks before yesterday, grouped by day
    private var olderDrinksGrouped: [(day: Date, drinks: [Drink])] {
        let filtered = drinks.filter {
            !calendar.isDateInToday($0.date) && !calendar.isDateInYesterday($0.date)
        }
        let grouped = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
        return grouped
            .sorted { $0.key > $1.key } // newest first
            .map { ($0.key, $0.value.sorted { $0.date > $1.date }) }
    }
    
    var body: some View {
        
        NavigationStack {
                
            List {
                
                if todayDrinks.isEmpty && yesterdayDrinks.isEmpty {
                    VStack {
                        
                        Image(systemName: "wineglass")
                            .font(.system(size: 96))
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Text(olderDrinksGrouped.isEmpty ? "No Drinks Logged" : "No Recent Drinks")
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                        
                    }.listRowBackground(Color.clear)
                        .frame(width: 400, height: 150, alignment: .center)
                        .padding(.top, 50)
                        .padding(.bottom, 50)
                }
                
                if !todayDrinks.isEmpty {
                    Section("Today") {
                        ForEach(todayDrinks) { d in
                            drinkRow(d)
                        }
                    }
                }
                
                if !yesterdayDrinks.isEmpty {
                    Section("Yesterday") {
                        ForEach(yesterdayDrinks) { d in
                            drinkRow(d)
                        }
                    }
                }
                
                Section {
                    ForEach(olderDrinksGrouped, id: \.day) { dayGroup in
                        NavigationLink {
                            DayDetailView(date: dayGroup.day, drinks: dayGroup.drinks)
                        } label: {
                            Text(dayGroup.day, style: .date)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    
    @ViewBuilder
    private func drinkRow(_ d: Drink) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(d.volume, specifier: "%.0f") ml")
                Spacer()
                Text("\(d.date.formatted(date: .numeric, time: .shortened))")
                    .foregroundColor(.gray)
            }
            Text("\(d.concentration*100, specifier: "%.1f") %")
        }
    }
}

struct DayDetailView: View {
    let date: Date
    let drinks: [Drink]
    
    var body: some View {
        List(drinks) { d in
            VStack(alignment: .leading) {
                HStack {
                    Text("\(d.volume, specifier: "%.0f") ml")
                    Spacer()
                    Text("\(d.date.formatted(date: .numeric, time: .shortened))")
                        .foregroundColor(.gray)
                }
                Text("\(d.concentration*100, specifier: "%.1f") %")
            }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
}

#Preview {
    HistoryView()
}

