//
//  BACGauge.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 19.3.2025.
//

import SwiftUI
import Foundation

//The circular gauge for showing blood alcohol
struct BACGauge: View {
    
    var progress: Float
    var isLight: Bool
    let width: Double = 15.0
    
    var body: some View {
        
        ZStack {
            
            Circle() //Background
                .foregroundColor(Color.black)
                .opacity(isLight ? 0 : 0.8)
                .scaleEffect(1.10)
            
            Circle() // Entire background
                .opacity(isLight ? 0.1 : 0.1)
                .scaleEffect(1.10)
            
            Circle() //Gauge Background
                .trim(from: 0.0, to: 0.75)
                .stroke(style: StrokeStyle(lineWidth:width, lineCap: .round, lineJoin: .round))
                .opacity(0.20)
                .rotationEffect(Angle(degrees: 135))
            
            Circle() //Gauge
                .trim(from: 0.0, to: Double(min(self.progress * 0.75, 0.75)))
                .stroke(style: StrokeStyle(lineWidth:width, lineCap: .round, lineJoin: .round))
                .foregroundColor(colorGradient())
                .rotationEffect(Angle(degrees: 135))
            
        }.foregroundColor(colorGradient())
            .animation(.easeIn(duration: 0.5), value: self.progress)
    }
    
    func colorGradient() -> Color {
        
        //Calculate the color of the gauge
        
        if self.progress == 0 {
            return Color.gray
        }
        
        if self.progress >= 0.5 {
            
            return Color(red: 1.0, green: 1.0 - (Double(self.progress) - 0.5) * 2, blue: 0.0)
            
        } else {
            
            return Color(red: Double(self.progress) * 2, green: 1.0, blue: 0.0)
            
        }
    }
    
}
