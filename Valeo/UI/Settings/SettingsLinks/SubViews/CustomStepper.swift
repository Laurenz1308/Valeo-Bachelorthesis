//
//  CustomStepper.swift
//  LifeCreator
//
//  Created by Lori Hill on 24.06.20.
//  Copyright © 2020 Laurenz Hill. All rights reserved.
//

import SwiftUI

struct CustomStepper: View {
    
    var text = ""
    let isCalories: Bool
        
    @ObservedObject var number: NumbersOnly
    @State var scale = false
    @State var select = true
    @State var runningDown = false
    @State var runningUp = false
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Image(systemName: "minus.circle")
                .font(.custom("", size: 40))
                .foregroundColor(Color.black)
                .onTapGesture(perform: self.minusButtonPressed)
                .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            self.scale = true
                            self.runningDown = true
                        }
                        .onEnded { _ in
                            self.scale = false
                            self.runningDown = false
                        })
                    
            Spacer()
                
            if self.text == "" && !isCalories{
                Text(self.number.value)
                    .font(.custom("Avenir", size: 45))
                    .foregroundColor(Color.black)
                    .scaleEffect(self.scale ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.5))
                    .onReceive(self.timer) { t in
                        if self.runningDown {
                            self.minusButtonPressed()
                        } else if self.runningUp {
                            self.plusButtonPressed()
                        }
                    }
                    .onAppear {
                        print("\(self.number)")
                    }
            }
            else if isCalories {
                TextField("Gewicht", text: self.$number.value)
                    .font(.custom("Avenir", size: 45))
                    .foregroundColor(Color.black)
                    .scaleEffect(self.scale ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.5))
                    .onReceive(self.timer) { t in
                        if self.runningDown {
                            self.minusButtonPressed()
                        } else if self.runningUp {
                            self.plusButtonPressed()
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    .keyboardType(.decimalPad)
            }
            else {
                Text("\(self.number.value) \(self.text)")
                    .font(.custom("Avenir", size: 40))
                    .foregroundColor(Color.black)
                    .scaleEffect(self.scale ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.5))
                    .onReceive(self.timer) { t in
                        if self.runningDown {
                            self.minusButtonPressed()
                        } else if self.runningUp {
                            self.plusButtonPressed()
                        }
                    }
            }

                    
                    
            Spacer()
                    
            Image(systemName: "plus.circle")
                .font(.custom("", size: 40))
                .foregroundColor(Color.black)
                .onTapGesture(perform: self.plusButtonPressed)
                .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            self.scale = true
                            self.runningUp = true
                        }
                        .onEnded { _ in
                            self.scale = false
                            self.runningUp = false
                        })}
                .padding(.horizontal, 0)
    }
    
    
    func minusButtonPressed() {
        if self.number.number > self.number.lowerBounds {
            self.number.number -= 1
            self.scale = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.scale = false
            }
        }
    }
       
    func plusButtonPressed() {
        if self.number.number < self.number.upperBounds {
            self.number.number += 1
            self.scale = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.scale = false
            }
        }
    }
}

struct CustomStepper_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomStepper(isCalories: false, number: NumbersOnly(with: 16))
            CustomStepper(text: "years", isCalories: false, number: NumbersOnly(with: 15))
        }
    }
}

