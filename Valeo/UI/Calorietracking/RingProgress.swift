//
//  RingProgress.swift
//  Valeo
//
//  Created by Laurenz Hill on 11.12.20.
//

import SwiftUI

/// Ring progres view of the calorietracker.
struct RingProgress: View {
    
    let width: CGFloat
    let height: CGFloat
    let colorArray = [Color("darkGreen"), Color("lightGreen"), Color("lightGreen"), Color("lightGreen"), Color("darkGreen")]
    
    @Binding var animation: Bool
    
    @Binding var text: String
    @Binding var loading: Bool
    @State var endAngle = Angle.zero
    
    var calorieGoal: Int
    
    @EnvironmentObject var daySummary: DaysummaryViewModel
    @EnvironmentObject var offsetManager: OffsetManager
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                
                ZStack {
                    
                    // Circle Shape
                    Circle()
                        .stroke(Color.black.opacity(0.5),
                                style: StrokeStyle(lineWidth: 10))
                    
                    // Loading circle
                    if calorieGoal > 0 {
                        Circle()
                            .trim(from: 0, to: self.animation ? CGFloat(Double(daySummary.totalCalories)/Double(calorieGoal)) : 0)
                            .stroke(Color.white,
                                    style: StrokeStyle(lineWidth: 10,
                                                       lineCap: .round,
                                                       lineJoin: .round,
                                                       miterLimit: .infinity,
                                                       dash: [20 , 0],
                                                       dashPhase: 0))
                            .rotationEffect(Angle(degrees: -90))
                            .shadow(color: .white, radius: 10)
                            .animation(self.offsetManager.hasPlayedCircleAnimation ? .none : .easeInOut(duration: Double(daySummary.totalCalories) / Double(calorieGoal)))
                            .onAppear(perform: {
                                if self.animation {
                                    self.offsetManager.hasPlayedCircleAnimation = true
                                } else {
                                    self.animation = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(daySummary.totalCalories) / Double(calorieGoal), execute: {
                                        self.offsetManager.hasPlayedCircleAnimation = true
                                    })
                                }

                            })

                        // Indicatorcircle
                        Circle()
                            .stroke(Color.black,
                                    style: StrokeStyle(lineWidth: 1))
                            .shadow(color: .white, radius: 2)
                            .foregroundColor(.white)
                            .frame(width: 10, height: 10)
                            .offset(x: ((height * 0.3 +
                                        (reader.frame(in: .global).minY >= 0 ? reader.frame(in: .global).minY : 0)) / 2) - 5)
                            .rotationEffect( animation ? Angle(degrees: 360.0 * (Double(daySummary.totalCalories) / Double(calorieGoal)) - 90) : Angle(degrees: -90))
                            .animation(self.offsetManager.hasPlayedCircleAnimation ? .none : .easeInOut(duration: Double(daySummary.totalCalories) / Double(calorieGoal)))
                    }
                    
                    Text(self.text)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .foregroundColor(.white)
                        .redacted(reason: loading ? .placeholder : [])
                        
                }
                .padding(.top, 10)
                .frame(width: width,
                       height: height * 0.3 +
                        (reader.frame(in: .global).minY >= 0 ? reader.frame(in: .global).minY : 0),
                       alignment: .bottom)
                .onChange(of: reader.frame(in: .global).minY, perform: { value in
                    self.offsetManager.hasPlayedCircleAnimation = true
                    if reader.frame(in: .global).minY > self.offsetManager.defaultOffset {
                        self.offsetManager.offset = self.offsetManager.defaultOffset
                    } else if reader.frame(in: .global).minY < -self.offsetManager.defaultOffset {
                        self.offsetManager.offset = -self.offsetManager.defaultOffset
                    }
                    else {
                        self.offsetManager.offset = reader.frame(in: .global).minY
                    }
                })
                .onAppear(perform: {
                    self.offsetManager.defaultOffset = reader.frame(in: .global).minY
                    self.offsetManager.offset = reader.frame(in: .global).minY
                })
                
            }
            .onChange(of: self.daySummary.totalCalories, perform: { value in
                self.endAngle = getEndAngle()
            })
        }
    }
    
    private func getStartAngle() -> Angle {

        if daySummary.totalCalories > calorieGoal {
            return Angle(degrees: 360 - (360.0 * (Double(self.daySummary.totalCalories) / Double(calorieGoal))))
        }
        return Angle.zero
    }

    private func getEndAngle() -> Angle {

        if daySummary.totalCalories > calorieGoal {
            return Angle(degrees: 360.0 * (Double(self.daySummary.totalCalories) / Double(calorieGoal)))
        }
        return Angle.zero
    }
    
}

struct RingProgress_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { g in
            ZStack {
                Color.red
                
                RingProgress(width: g.size.width, height: g.size.height, animation: .constant(false), text: .constant("bla"), loading: .constant(false), calorieGoal: 2000)
                    .environmentObject(DaysummaryViewModel())
                    .environmentObject(OffsetManager())
            }
        }
    }
}
