//
//  DataController.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 6.2.2024.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "data")
    
    init() {
        
        container.loadPersistentStores {description, error in
            
            if let error = error {
                
                print("Core Data failed to load: \(error.localizedDescription)")
                
            }
            
        }
        
    }
    
    func save(context: NSManagedObjectContext) {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Failed to save data: \(error.localizedDescription)")
            
        }
        
    }
}
