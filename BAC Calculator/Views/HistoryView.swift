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
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if drinks.isEmpty {
                    
                    Text("No drinks logged yet.")
                        .foregroundColor(.gray)
                    
                } else {
                    
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
                }
            }
                .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}
