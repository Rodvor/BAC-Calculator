//
//  MainView.swift
//  BAC Calculator
//
//  Created by Hugo Minkkinen on 27.6.2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    //Define constants
    let clock = ContinuousClock() //Clock for measuring the time between drinks
    let defaults = UserDefaults.standard
    
    let MALE: Int = 1 //Readability variable e.g. if sex == MALE {}
    
    @StateObject var BloodAlcohol: BloodAlcoholController
    @Environment(\.modelContext) private var context
    
    @State public var before: ContinuousClock.Instant //Define the before time. Has to be defined in BAC_Calculator.app where ContentView is called, hence public
    @State private var timer: Timer? // Timer variable

    //Textfield variables
    @State private var volume = "" // Volume text box is empty
    @State private var horsepower = "" // Horsepower text box is empty
    
    //Show additional content on screen booleans
    @State private var showSettings: Bool = false
    @State private var showInfo: Bool = false
    
    //Focus states for TextFields
    @FocusState private var volumeFocused: Bool //Whether or not user is actively writing in a box. Used to hide the keyboard
    @FocusState private var horsepowerFocused: Bool
    
    var body: some View {
        
        VStack {
            
            //Gauge and information
            
            ZStack {
                //Add Gauge and BAC
                BACGauge(progress: BloodAlcohol.getCurrentBAC()/3)
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
                        
                        Text(formatTime(BloodAlcohol.calculatePeakBAC()[1]))
                            .font(.system(size:12))
                        
                    }.foregroundColor(.gray)
                    
                }.scaleEffect(CGSize(width: keyboardVisible() ? 0.7 : 1.0, height: keyboardVisible() ? 0.7 : 1.0))
                .animation(.easeInOut(duration: 0.35), value: keyboardVisible())
                    
            }
                
            StomachGauge(volume: BloodAlcohol.stomachVolume, concentration: BloodAlcohol.stomachConcentration)
                .frame(width: 300, height: 25, alignment: .center)
                .padding(.bottom, 15)
            
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
                        TextField("Volume (ml)", text: $volume)
                            .keyboardType(.decimalPad)
                            .focused($volumeFocused)
                            .padding(.bottom, 5)
                        TextField("Horsepower (%)", text: $horsepower)
                            .keyboardType(.decimalPad)
                            .focused($horsepowerFocused)
                    }
                    
                }
                
            }.frame(width: 300, height: 50, alignment: .center)
                .padding(.bottom, 30)
            
            //Update Button
            Button(action: update_press) {
                // Liquid glass button if available
                if #available(iOS 26.0, *) {
                    Text("Update")
                        .font(.title3)
                        .bold(true)
                        .foregroundColor(.white)
                        .padding(5)
                        .padding(.horizontal, 10)
                        .glassEffect(.regular.tint(.blue).interactive())
                } else {
                    // Liquid glass unavailable
                    Text("Update")
                        .font(.title3)
                        .bold(true)
                        .foregroundColor(.white)
                        .padding(5)
                        .padding(.horizontal, 10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }.padding(.bottom, 25)
            
            
            
            
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        
    }
    
    func update_press() -> Void {
        
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
            
            // Save to drink to storage
            let newDrink = Drink(volume: drinkVolume, concentration: drinkConcentration)
            context.insert(newDrink)
            do {
                try context.save()
            } catch {
                print("Failed to save drink correctly: \(error)")
            }
            
        }
        
        //Reset text boxes
        volume = ""
        horsepower = ""
        
        //Hide keyboard
        hideKeyboard()
        
    }
    
    func hideKeyboard() -> Void {
        
        //Hides the keyboard
        volumeFocused = false
        horsepowerFocused = false
    }
    
    func keyboardVisible() -> Bool {
        
        //Returns bool whether or not a keyboard is currently visible
        
        return volumeFocused || horsepowerFocused
        
    }
    
    // Start the timer to update every 5 seconds
    func startTimer() {
        stopTimer() // Ensure no duplicate timers are running
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
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
        
        // Get delay
        let duration = clock.now - before
        let delay: Int64 = duration.components.seconds
        before = clock.now
        
        // Update blood alcohol
        BloodAlcohol.updateData(Float(delay))
    }
    
}

#Preview {
    MainView(BloodAlcohol: BloodAlcoholController(), before: ContinuousClock().now)
}
