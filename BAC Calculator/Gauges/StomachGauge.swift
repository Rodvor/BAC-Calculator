//
//  StomachGauge.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 19.3.2025.
//

import Foundation
import SwiftUI

struct StomachGauge: View {
    
    // Define Gauge size
    let width: Float = 275
    let thickness: Float = 10
    
    // Define max_gauge values
    let max_concentration: Float = 0.3
    let max_volume: Float = 3000
    
    // Variables
    let volume: Float
    let concentration: Float
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "drop.halffull")
                .frame()
            
            ZStack {
                
                // Bottom gray "background"
                RoundedRectangle(cornerRadius: CGFloat(thickness))
                    .frame(width: CGFloat(width), height: CGFloat(thickness))
                    .foregroundColor(.gray)
                    .opacity(0.3)
                
                // Gauge
                RoundedRectangle(cornerRadius: CGFloat(thickness))
                    .frame(width: CGFloat(volume/max_volume * width), height: CGFloat(thickness))
                    .foregroundColor(colorGradient())
                    .offset(x: CGFloat((-width*(1-volume/max_volume)/2)), y:0)
                    .opacity(0.8)
                
            }
        }.animation(.bouncy(duration: 0.5, extraBounce: 0.3), value: self.volume)
            .animation(.easeInOut(duration: 0.5), value: self.concentration)
    }
    
    func colorGradient() -> Color {
        
        //Calculate the color of the gauge
        
        let progress = concentration / max_concentration
        
        if progress >= 0.5 {
            
            return Color(red: 1.0, green: 0.0, blue: 1.0 - (Double(progress) - 0.5) * 2)
            
        } else {
            
            return Color(red: Double(progress) * 2, green: 0.5, blue: 1.0)
            
        }
    }
}
