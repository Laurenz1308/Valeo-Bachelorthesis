//
//  AgeSelector.swift
//  LifeCreator
//
//  Created by Lori Hill on 09.05.20.
//  Copyright © 2020 Laurenz Hill. All rights reserved.
//

import SwiftUI

struct NumberStepper: View {
    
    let typeToChange: TypeToChange
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var user: UserViewModel
    
    let text: String
    @ObservedObject var number = NumbersOnly(with: 0)
        
    var body: some View {
        
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundColor(Color.white.opacity(0.9))
                        
                        VStack(alignment: .center, spacing: 20){
                            
                            Text(text)
                                .font(.custom("Avenir", size: 20))
                                .foregroundColor(Color.black)
                                .padding(.vertical, 30)
                            
                            Spacer()
                            
                            CustomStepper(isCalories: self.text == "Kalorienziel" ?
                                            true : false,
                                          number: self.number)
                                .padding(.horizontal, 20)

                            Spacer()
                            
                            Button(action: self.save) {
                                SaveText(geometry: geometry.size)
                            }
                            
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.4)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear(perform: {self.getValueToModify()})
    }
    
    func getValueToModify() {
        switch typeToChange {
        case .weight:
            self.number.number = self.user.user?.weight ?? 0
            self.number.lowerBounds = 0
            self.number.upperBounds = 350
        case .size:
            self.number.number = self.user.user?.size ?? 0
            self.number.lowerBounds = 60
            self.number.upperBounds = 350
        case .calorieGoal:
            self.number.number = Int(self.user.user?.calorieGoal ?? 0)
            self.number.lowerBounds = 500
            self.number.upperBounds = 30000
        case .waist:
            self.number.number = self.user.user?.waist ?? 30
            self.number.lowerBounds = 0
            self.number.upperBounds = 300
        case .bodyfat:
            self.number.number = Int(self.user.user?.bodyFat ?? 20.0)
            self.number.lowerBounds = 0
            self.number.upperBounds = 100
        }
    }
    
    func save() {
        withAnimation(.easeOut(duration: 1)) {
            
            var weight: Int? = nil
            var size: Int? = nil
            var calorieGoal: Double? = nil
            var waist: Int? = nil
            var bodyFat: Double? = nil
            
            switch typeToChange {
            case .weight:
                weight = self.number.number
            case .size:
                size = self.number.number
            case .calorieGoal:
                calorieGoal = Double(self.number.number)
            case .waist:
                waist = self.number.number
            case .bodyfat:
                bodyFat = Double(self.number.number)
            }
            
            user.updateUser(weight: weight,
                             size: size,
                             waist: waist,
                             bodyFat: bodyFat,
                             calorieGoal: calorieGoal)
            
            self.navigator.showPopUpView = false
        }
    }
}

struct NumberStepper_Previews: PreviewProvider {
    static var previews: some View {
        NumberStepper(typeToChange: .weight, text: "Gewicht")

    }
}


enum TypeToChange {
    case weight
    case size
    case calorieGoal
    case waist
    case bodyfat
}
