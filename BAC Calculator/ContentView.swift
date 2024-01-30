//
//  ContentView.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 29.1.2024.
//

import SwiftUI

struct ContentView: View {
    
    //Define constants
    let clock = ContinuousClock() //Clock for measuring the time between drinks
    let alcoholDensity: Float = 0.79 //Alcohol's density g/ml
    let metabolism: Float = 0.015 //Metabolism BAC/h of alcohol cancelled by the liver
    let MALE: Int = 1
    
    @State public var before: ContinuousClock.Instant //Define the before time. Has to be defined in BAC_Calculator.app where ContentView is called, hence public
    @State private var weight: String = "70,0" //User's weight
    @State private var bac: Float = 0.0 //BAC initially 0
    @State private var volume = "" //Volume text box is empty
    @State private var horsepower = "" //Horsepower text box is empty
    @State private var showSettings: Bool = false
    @State private var showInfo: Bool = false
    @State private var gender: Int = 1
    @State private var timeUntilSober: Float = 0.0 //In Hours
    
    //Focus states for TextFields
    @FocusState private var volumeFocused:Bool //Whether or not user is actively writing in a box. Used to hide the keyboard
    @FocusState private var horsepowerFocused:Bool
    @FocusState private var weightFocused: Bool
    
    var body: some View {
        
        VStack {
            
            HStack {
                //Info button
                Button(action: {
                    showInfo.toggle()
                    showSettings = false
                    hideKeyboard()
                }) {
                    Image(systemName: "info.circle")
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .padding(.leading, 20)
                }
                
                Spacer()
                
                //Settings button
                Button(action: {
                    showSettings.toggle()
                    showInfo = false
                    hideKeyboard()
                }) {
                    Image(systemName: "gearshape")
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .padding(.trailing, 20)
                }

            }
            
            //Gauge and information
            
            ZStack {
                //Add Gauge and BAC
                BACGauge(progress: bac/0.3)
                    .scaleEffect(CGSize(width: 0.7, height: 0.7))
                
                VStack {
  
                    Text("Blood Alcohol")
                        .font(.title).bold()
                    
                    Text("Concentration").font(.title2).bold()
                        .padding(.bottom, 10)
                        

                    Text(String(format: "%.2f", bac*10)+"‰") //Multiply by 10 to show as promille
                        .font(.title2)
                    
                    Text(getTimeUntilSober())
                        .foregroundColor(.gray)
                    
                }.scaleEffect(CGSize(
                    width: keyboardVisible() ? (isBottomMenuVisible() ? 0.25 : 0.5) : (isBottomMenuVisible() ? 0.8 : 1.0),
                    height: keyboardVisible() ? (isBottomMenuVisible() ? 0.25 : 0.5) : (isBottomMenuVisible() ? 0.8 : 1.0)
                ))
                    .animation(.linear(duration: 0.1), value: keyboardVisible())
                    
                
            }.padding(.bottom, 30)
                .animation(.easeIn(duration: 0.2), value: isBottomMenuVisible())
                
            //Text input fields
            VStack {
                    
                HStack {
                    
                    VStack {
                        Image(systemName: "waterbottle").padding(.bottom, 15)
                        Image(systemName: "percent")
                    }
                    
                    VStack {
                        TextField("Volume (ml)", text: $volume).keyboardType(.decimalPad).focused($volumeFocused)
                            .padding(.bottom, 5)
                        TextField("Horsepower (%)", text: $horsepower).keyboardType(.decimalPad).focused($horsepowerFocused)
                    }
                    
                    
                }
                
            }.padding(.leading, 50)
                .padding(.bottom, 30)
                .animation(.easeIn(duration: 0.2), value: isBottomMenuVisible())
            
            //Update Button
            Button(action:{
                
                //Check duration from last BAC check/drink
                let duration = clock.now - before
                let delay: Int64 = duration.components.seconds
                before = clock.now
                
                //Convert text into float, default value 0 replace e.g. "0,5" to 0.5
                let drinkVolume = Float(volume.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 0.0
                let drinkHorsepower = (Float(horsepower.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 0.0)/100.0
                let userWeight = Float(weight.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 1
                let genderConstant = (gender == MALE ? Float(0.68) : Float(0.55)) //Gender constant 0.68 for males and 0.55 for females
                
                //Calculate BAC
                let alcoholWeight = alcoholDensity * drinkVolume * drinkHorsepower
                let humanWeight = 1000 * userWeight * genderConstant
                let addedBAC = alcoholWeight/humanWeight * 100
                let liver = metabolism * Float(delay)/3600
                
                if bac - liver <= 0 {
                    bac = addedBAC
                } else {
                    bac = bac + addedBAC - liver
                }
                
                timeUntilSober = bac / metabolism
                
                //Reset text boxes
                volume = ""
                horsepower = ""
                
                //Hide keyboard
                hideKeyboard()
                
                
            }) {
                //Button style: rounded rectangle
                ZStack {
                    
                    if !isBottomMenuVisible() {
                        
                        RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                            .frame(width: 100.0, height: 30.0, alignment: .center)
                        
                        Text("Update")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }.animation(.easeIn(duration: 0.2), value: isBottomMenuVisible())
                
                
            }
            
            Text(getSweetSpot())
                .padding(.top, 20)
                .foregroundColor(.gray)
            
            Spacer()
            
                
            ZStack {
                
                if isBottomMenuVisible() {
                    
                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                        .foregroundColor(.gray)
                        .opacity(0.25)
                        .frame(width: 380, height: 220, alignment: .center)
                        .onTapGesture {
                            hideKeyboard()
                        }
                    
                }
                
                if showSettings {
                    
                    VStack {
                        
                        Text("Settings").font(.title2)
                        
                        HStack {
                            
                            Text("Weight: ").padding(.leading, 50)
                            TextField("Weight (kg)", text: $weight)
                                .keyboardType(.decimalPad)
                                .focused($weightFocused)
                                .frame(width: 100, height: 20, alignment: .center)
                            Spacer()
                            
                        }
                        
                        HStack {
                            
                            Text("Gender:").padding(.leading, 50)
                            
                            Picker(selection: $gender, label: Text("Gender")) {
                                Text("Male").tag(1)
                                Text("Female").tag(2)
                            }
                                .foregroundColor(.white)
                            
                            Spacer()
                        }.padding(.bottom, 10)
                        
                        HStack {
                            Text("Adjust settings before logging")
                                .foregroundColor(.gray)
                                .padding(.leading, 50)
                            Spacer()
                        }.padding(.bottom, 20)
                        
                        
                        HStack {
                            
                            Button(action: {
                                
                                hideKeyboard()
                                showSettings = false
                                
                            }) {
                                ZStack {
                                    
                                    RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                        .frame(width: 85.0, height: 30.0, alignment: .center)
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                    
                                    Text("Close")
                                        .foregroundColor(.white)
                                }
                            }.padding(.leading,50)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                hideKeyboard()
                                showSettings = false
                                bac = 0
                                timeUntilSober = 0.0
                                
                            }) {
                                ZStack {
                                    
                                    RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                        .frame(width: 85.0, height: 30.0, alignment: .center)
                                        .foregroundColor(.red)
                                        .opacity(0.3)
                                    
                                    Text("Reset")
                                        .foregroundColor(.red)
                                }
                            }.padding(.trailing, 50)
                            
                        }
                        
                    }
                    
                } else if showInfo {
                    
                    VStack {
                        
                        Text("Info").font(.title)
                        Text("Warning: This application is not necessarily accurate and should not be relied on for your own safety. This app uses general formulae from the internet")
                            .frame(width: 350, height: 45, alignment: .center)
                            .padding(.bottom, 2)
                            .font(.system(size: 12))
                        Text("Use: When you drink, log the volume and horsepower into the fields and press update. The app will take metabolism into consideration, allowing you to track your current BAC")
                            .frame(width: 340, height: 50, alignment: .center)
                            .font(.system(size: 12))
                        
                        
                        Button(action: {
                            
                            hideKeyboard()
                            showInfo = false
                            
                        }) {
                            ZStack {
                                
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .frame(width: 85.0, height: 30.0, alignment: .center)
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                                
                                Text("Close")
                                    .foregroundColor(.white)
                            }
                        }
                        
                    }
                    
                }
                
            }.animation(.easeIn(duration: 0.2), value: isBottomMenuVisible())
        
        }.padding(.bottom, 20)
    }
    
    func getSweetSpot() -> String {
        
        if bac >= 0.1 {
            return " "
        }
        
        let drinkHorsepower = (Float(horsepower.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 0.0)/100.0
        let userWeight = Float(weight.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
        let genderConstant = (gender == MALE ? Float(0.68) : Float(0.55))
        
        if drinkHorsepower != 0.0 {
            
            let top = ((0.1-bac) * 10 * (userWeight ?? 1.0) * genderConstant)
            let bottom = (alcoholDensity * drinkHorsepower)
            let moreVolume = top/bottom
            
            return "Sweet spot: " + String(format: "%.0f", moreVolume) + "ml"
        }
        
        return " "
        
    }
    
    func hideKeyboard() -> Void {
        volumeFocused = false
        horsepowerFocused = false
        weightFocused = false
    }
    
    func keyboardVisible() -> Bool {
        
        if volumeFocused || horsepowerFocused || weightFocused {
            return true
        }
        
        return false
        
    }
    
    func isBottomMenuVisible() -> Bool {
        
        return showSettings || showInfo
        
    }
    
    func getTimeUntilSober() -> String {
        
        let totalMinutes = Int(String(format:"%.0f", timeUntilSober * 60)) ?? 0
        
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
    
}



struct BACGauge: View {
    
    var progress: Float
    let width: Double = 15.0
    
    var body: some View {
        
        ZStack {
            
            Circle() // Black background
                .foregroundColor(Color.black)
                .opacity(0.8)
                .scaleEffect(1.10)
            
            Circle() // Entire background
                .opacity(0.10)
                .scaleEffect(1.10)
            
            Circle() //Gauge Background
                .trim(from: 0.0, to: 0.75)
                .stroke(style: StrokeStyle(lineWidth:width, lineCap: .round, lineJoin: .round))
                .opacity(0.20)
                .rotationEffect(Angle(degrees: 135))
            
            Circle() //Gauge
                .trim(from: 0.0, to: Double(min(self.progress * 0.75, 0.75)))
                .stroke(style: StrokeStyle(lineWidth:width, lineCap: .round, lineJoin: .round))
                .foregroundColor(speedColorGradient())
                .rotationEffect(Angle(degrees: 135))
            
        }.foregroundColor(speedColorGradient())
            .animation(.easeIn(duration: 0.5), value: self.progress)
    }
    
    func speedColorGradient() -> Color{
        
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

#Preview {
    ContentView(before: ContinuousClock().now)
}