//
//  ContentView.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 29.1.2024.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    //Define constants
    let clock = ContinuousClock() //Clock for measuring the time between drinks
    let defaults = UserDefaults.standard
    
    let MALE: Int = 1 //Readability variable e.g. if sex == MALE {}
    
    @StateObject var BloodAlcohol = BloodAlcoholController()
    
    @State public var before: ContinuousClock.Instant //Define the before time. Has to be defined in BAC_Calculator.app where ContentView is called, hence public
    @State private var timer: Timer? // Timer variable
    
    //Textfield variables
    @State private var volume = "" //Volume text box is empty
    @State private var horsepower = "" //Horsepower text box is empty
    
    //User adjustable settings
    @State var sex: Int
    @State var mode: Int
    @State var weight: String //User's weight
    
    //Show additional content on screen booleans
    @State private var showSettings: Bool = false
    @State private var showInfo: Bool = false
    
    //Focus states for TextFields
    @FocusState private var volumeFocused: Bool //Whether or not user is actively writing in a box. Used to hide the keyboard
    @FocusState private var horsepowerFocused: Bool
    @FocusState private var weightFocused: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack {
            
            //HStack For top buttons
            HStack {
                
                //Info button
                Button(action: {
                    showInfo.toggle()
                    showSettings = false
                    hideKeyboard()
                    BloodAlcohol.setBody(newWeight: formatToFloat(weight), newIsMale: sex == MALE)
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
                }) {
                    Image(systemName: "gearshape")
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .padding(.trailing, 20)
                }

            }
            
            //Gauge and information
            
            ZStack {
                //Add Gauge and BAC
                BACGauge(progress: BloodAlcohol.getCurrentBAC()/3, isLight: isLight())
                    .scaleEffect(CGSize(width: 0.7, height: 0.7))
                
                //Text/information VStack
                VStack {
  
                    Text("Blood Alcohol")
                        .font(.title).bold()
                    
                    Text("Content").font(.title).bold()
                        .padding(.bottom, 10)
                        

                    Text(String(format: "%.2f", BloodAlcohol.getCurrentBAC())+"‰") //Multiply by 10 to show as promille
                        .font(.title)
                    
                    
                    VStack {
                        
                        HStack {
                            
                            if BloodAlcohol.timeUntilZero() > 0 {
                                Image(systemName: "clock")
                                    .scaleEffect(CGSize(width: 0.7, height: 0.7))
                            }
                            
                            Text(
                                formatTime(BloodAlcohol.timeUntilZero())
                            )
                            .font(.system(size:12))
                        }
                        
                        HStack {
                            
                            Image(systemName: "exclamationmark.triangle")
                            
                            Text(
                                String(format: "%.2f", BloodAlcohol.calculatePeakBAC()[0])+"‰"
                            )
                            .font(.system(size:18))
                        }
                        
                        
                        Text(
                            formatTime(BloodAlcohol.calculatePeakBAC()[1])
                        ).font(.system(size:12))
                        
                        
                    }.foregroundColor(.gray)
                    
                    
                    
                }.scaleEffect(CGSize(
                    width: keyboardVisible() ? (isBottomMenuVisible() ? 0.25 : 0.5) : (isBottomMenuVisible() ? 0.8 : 1.0),
                    height: keyboardVisible() ? (isBottomMenuVisible() ? 0.25 : 0.5) : (isBottomMenuVisible() ? 0.8 : 1.0)
                ))
                    .animation(.linear(duration: 0.1), value: keyboardVisible())
                    
                
            }.animation(.easeIn(duration: 0.2), value: isBottomMenuVisible())
                
            StomachGauge(volume: BloodAlcohol.stomachVolume, concentration: BloodAlcohol.stomachConcentration)
                .padding(.bottom, 15)
                .animation(.easeIn(duration: 0.2), value: isBottomMenuVisible())
            
            //Text input fields
            VStack {
                
                HStack {
                    
                    //Icons
                    VStack {
                        Image(systemName: "wineglass").padding(.bottom, 15)
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
            Button(action: {
                
                // Get input
                let drinkVolume: Float = formatToFloat(volume)
                let drinkConcentration: Float = formatToFloat(horsepower) / 100.0
                
                // Update current situation and then consume drink
                
                let duration = clock.now - before
                let delay: Int64 = duration.components.seconds
                before = clock.now
                
                BloodAlcohol.updateData(Float(delay))
                
                // Drink if there is something to drink...
                if volume != "" && horsepower != "" {
                    BloodAlcohol.drink(volume: drinkVolume, concentration: drinkConcentration)
                }
                
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
            
            
            
            
            Spacer()
            
            
            
            //ZStack for bottom menu: settings or info
            ZStack {
                
                //Background
                if isBottomMenuVisible() {
                    
                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                        .foregroundColor(.gray)
                        .opacity(isLight() ? 0.15 : 0.25)
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
                            
                            Spacer()
                            
                        }
                        
                        HStack {
                            
                            Text("Appearance:").padding(.leading, 50)
                            
                            Picker(selection: $mode, label: Text("Sex")) {
                                Text("Automatic").tag(1)
                                Text("Light").tag(2)
                                Text("Dark").tag(3)
                            }
                            
                            Spacer()
                        }.padding(.bottom, 20)
                        
                        
                        HStack {
                            
                            Button(action: {
                                
                                hideKeyboard()
                                showSettings = false
                                BloodAlcohol.setBody(newWeight: formatToFloat(weight), newIsMale: sex == MALE)
                                
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
                            
                            Button(action:{
                                
                                let hkController = HKController()

                                hkController.getUserBodyMass { bodyMass in
                                    if let bodyMass = bodyMass {
                                        print("User body mass: \(bodyMass) kg")
                                        weight = String(format: "%.2f", bodyMass)
                                    } else {
                                        print("Could not retrieve user body mass")
                                    }
                                }

                                hkController.getUserBiologicalSex { biologicalSex in
                                    if let biologicalSex = biologicalSex {
                                        print("User biological sex: \(biologicalSex)")
                                        sex = biologicalSex
                                    } else {
                                        print("Could not retrieve user biological sex")
                                    }
                                }
                                
                            }){
                                ZStack {
                                    
                                    RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                        .frame(width: 85.0, height: 30.0, alignment: .center)
                                        .foregroundColor(.blue)
                                        .opacity(isLight() ? 0.5 : 0.3)
                                    
                                    Text("Import")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                
                                hideKeyboard()
                                BloodAlcohol.alcohol = 0
                                BloodAlcohol.stomachVolume = 0
                                BloodAlcohol.stomachConcentration = 0
                                BloodAlcohol.setBody(newWeight: formatToFloat(weight), newIsMale: sex == MALE)
                                
                            }) {
                                ZStack {
                                    
                                    RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                        .frame(width: 85.0, height: 30.0, alignment: .center)
                                        .foregroundColor(.red)
                                        .opacity(isLight() ? 0.5 : 0.3)
                                    
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
                        
                        Text("Info").font(.title2)
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
            .environment(\.colorScheme, isLight() ? .light : .dark)
            .background(
            
                Rectangle()
                    .frame(width: 800, height: 1600, alignment: .center)
                    .foregroundColor(isLight() ? .white : .black)
            
            )
            .animation(.easeInOut(duration: 0.2), value: isLight())
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            
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
    
    func isLight() -> Bool {
        if mode == 1 {
            return colorScheme == .light
        }
        
        return mode == 2
    }
    
    // Start the timer to update every 5 seconds
    func startTimer() {
        stopTimer() // Ensure no duplicate timers are running
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            update()
        }
    }
    
    // Stop the timer when the view disappears
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Function to update BAC with time delay
    func update() {
        
        // Update defaults
        defaults.set(sex, forKey: "sex")
        defaults.set(weight, forKey: "weight")
        defaults.set(mode, forKey: "mode")
        
        if BloodAlcohol.alcohol == 0 {
            return
        }
        
        if BloodAlcohol.stomachVolume == 0 {
            return
        }
        
        let duration = clock.now - before
        let delay: Int64 = duration.components.seconds
        before = clock.now
        BloodAlcohol.updateData(Float(delay))
    }
    
}


//Preview for xcode

#Preview {
    ContentView(before: ContinuousClock().now, sex: 1, mode: 1, weight: "70,0")
}
