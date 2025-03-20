//
//  Utilities.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 19.3.2025.
//
import Foundation

func formatTime(_ time: Float) -> String {
    
    if time.isNaN {
        return ""
    }
    
    let totalMinutes = Int((time / 60.0).rounded())
            
    let minutes = totalMinutes % 60
    let hours = Int(String(format:"%.0f", floor(Double((totalMinutes - minutes))/60))) ?? 0
    
    
    if hours == 0 && minutes == 0 {
        return ""
    }
    
    if minutes == 0 {
        return String(hours) + "h"
    }
    
    if hours == 0 {
        return String(minutes) + "min"
    }
    
    return String(hours) + "h " + String(minutes) + "min"
    
}

func formatToFloat(_ string: String) -> Float {
    return Float(string.replacingOccurrences(of: ",", with: ".")) ?? -1.0    
}
