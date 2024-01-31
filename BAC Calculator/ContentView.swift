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
    let MALE: Int = 1 //Readability variable e.g. if sex == MALE {}
    
    @State public var before: ContinuousClock.Instant //Define the before time. Has to be defined in BAC_Calculator.app where ContentView is called, hence public
    @State private var metabolismGrams: Float = 7.14 //Metabolism g/h of default 70kg male, is changed in code
    @State private var gramsOfAlcohol: Float = 0.0
    
    //Textfield variables
    @State private var volume = "" //Volume text box is empty
    @State private var horsepower = "" //Horsepower text box is empty
    
    //User adjustable settings
    @State private var sex: Int = 1
    @State private var weight: String = "70,0" //User's weight
    
    //Show additional content on screen booleans
    @State private var showSettings: Bool = false
    @State private var showInfo: Bool = false
    
    //Focus states for TextFields
    @FocusState private var volumeFocused:Bool //Whether or not user is actively writing in a box. Used to hide the keyboard
    @FocusState private var horsepowerFocused:Bool
    @FocusState private var weightFocused: Bool
    
    var body: some View {
        
        VStack {
            
            //HStack For top buttons
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
                
                //Spacer to place them in each corner
                Spacer()
                
                //Settings button
                Button(action: {
                    showSettings.toggle()
                    showInfo = false
                    hideKeyboard()
                    updateMetabolismGrams()
                }) {
                    Image(systemName: "gearshape")
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .padding(.trailing, 20)
                }

            }
            
            //Gauge and information
            
            ZStack {
                //Add Gauge and BAC
                BACGauge(progress: getBAC()/0.3)
                    .scaleEffect(CGSize(width: 0.7, height: 0.7))
                
                //Text/information VStack
                VStack {
  
                    Text("Blood Alcohol")
                        .font(.title).bold()
                    
                    Text("Concentration").font(.title2).bold()
                        .padding(.bottom, 10)
                        

                    Text(String(format: "%.2f", getBAC()*10)+"‰") //Multiply by 10 to show as promille
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
                    
                    //Icons
                    VStack {
                        Image(systemName: "waterbottle").padding(.bottom, 15)
                        Image(systemName: "percent")
                    }
                    
                    //TextFields for volume and horse power
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
            Button(action: {update()}) {
                
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
            
            
            
            //ZStack for bottom menu: settings or info
            ZStack {
                
                //Background
                if isBottomMenuVisible() {
                    
                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                        .foregroundColor(.gray)
                        .opacity(0.25)
                        .frame(width: 380, height: 220, alignment: .center)
                        .onTapGesture {
                            hideKeyboard()
                        }
                    
                }
                
                //If settings is shown, show settings on top of background
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
                            
                            Text("Sex:").padding(.leading, 50)
                            
                            Picker(selection: $sex, label: Text("Sex")) {
                                Text("Male").tag(1)
                                Text("Female").tag(2)
                            }
                                .foregroundColor(.white)
                            
                            Spacer()
                        }.padding(.bottom, 10)
                        
                        HStack {
                            Text("Adjusting settings will affect BAC")
                                .foregroundColor(.gray)
                                .padding(.leading, 50)
                            Spacer()
                        }.padding(.bottom, 20)
                        
                        
                        HStack {
                            
                            Button(action: {
                                
                                hideKeyboard()
                                showSettings = false
                                updateMetabolismGrams()
                                
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
                                gramsOfAlcohol = 0
                                updateMetabolismGrams()
                                
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
                    
                //If settings is shown, show settings on top of background
                } else if showInfo {
                    
                    //VStack for text
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
                            //Button style
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
        
        //When typing in a certain horsepower, getSweetSpot will return the amount of ml required to reach 1.0 BAC
        
        if getBAC() >= 0.1 {
            return " "
        }
        
        let drinkHorsepower = (Float(horsepower.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 0.0)/100.0
        let userWeight = Float(weight.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
        let sexConstant = (sex == MALE ? Float(0.68) : Float(0.55))
        
        if drinkHorsepower != 0.0 {
            
            let top = ((0.1-getBAC()) * 10 * (userWeight ?? 1.0) * sexConstant)
            let bottom = (alcoholDensity * drinkHorsepower)
            let moreVolume = top/bottom
            
            return "Sweet spot: " + String(format: "%.0f", moreVolume) + "ml"
        }
        
        return " "
        
    }
    
    func hideKeyboard() -> Void {
        
        //Hides the keyboard
        
        volumeFocused = false
        horsepowerFocused = false
        weightFocused = false
    }
    
    func keyboardVisible() -> Bool {
        
        //Returns bool whether or not a keyboard is currently visible
        
        return volumeFocused || horsepowerFocused || weightFocused
        
    }
    
    func isBottomMenuVisible() -> Bool {
        
        //Returns bool whether or not settings or info is currently visible
        
        return showSettings || showInfo
        
    }
    
    func getTimeUntilSober() -> String {
        
        //Returns the time taken to get sober, given in hours or minutes
        
        let timeUntilSober = gramsOfAlcohol / metabolismGrams
        
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
    
    func getBAC() -> Float {
        
        //Calculates BAC using weight, sex, and grams of alcohol in the the body, as well as updates the value for metabolismGrams
        
        let userWeight = Float(weight.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 1
        let sexConstant = (sex == MALE ? Float(0.68) : Float(0.55)) //Gender constant 0.68 for males and 0.55 for females
        
        let humanWeight = 1000 * userWeight * sexConstant
        
        let bac = gramsOfAlcohol/humanWeight * 100
        
        return bac
        
    }
    
    func update() -> Void {
        
        //Called from Update button. Performs the operations required to add a new drink and/or update the current grams of alcohol in blood
        
        //Check duration from last BAC check/drink
        let duration = clock.now - before
        let delay: Int64 = duration.components.seconds
        before = clock.now
        
        //Convert text into float, default value 0 replace e.g. "0,5" to 0.5
        let drinkVolume = Float(volume.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 0.0
        let drinkHorsepower = (Float(horsepower.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 0.0)/100.0
        
        updateMetabolismGrams()
        let liver = metabolismGrams * Float(delay)/3600
        
        
        gramsOfAlcohol += alcoholDensity * drinkVolume * drinkHorsepower - liver
        
        if gramsOfAlcohol <= 0 {
            gramsOfAlcohol = 0
        }
                
        
        //Reset text boxes
        volume = ""
        horsepower = ""
        
        //Hide keyboard
        hideKeyboard()
        
    }
    
    func updateMetabolismGrams() -> Void {
        let userWeight = Float(weight.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) ?? 1
        let sexConstant = (sex == MALE ? Float(0.68) : Float(0.55)) //Gender constant 0.68 for males and 0.55 for females
        let humanWeight = 1000 * userWeight * sexConstant
        metabolismGrams = metabolism/100 * humanWeight
    }
    
}


//The circular gauge for showing blood alcohol
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
    
    func speedColorGradient() -> Color {
        
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

//Preview for xcode

#Preview {
    ContentView(before: ContinuousClock().now)
}
