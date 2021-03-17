//
//  OnBoardingNavigator.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct OnBoardingNavigator: View {
    
    @EnvironmentObject var user: UserViewModel
    
    // Indices the current boarding view
    @State var currentBoardingView = 0
    
    @State var name = ""
    
    @State var birth = Date()
    
    @State var gender = Gender.male
    
    @State var weight = 0
    
    @State var size = 0
    
    @State var waist: Int? = nil
    
    @State var bodyFat: Int? = nil
    
    @State var creationError = false
        
    var calorieGoal = 0
    
    var bmi = 0
    
    let colors: [Color] = [
        Color(.sRGB, red: 214/255, green: 93/255, blue: 177/255, opacity: 1),
        Color(.sRGB, red: 132/255, green: 94/255, blue: 194/255, opacity: 1)
    ]
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .topTrailing, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if currentBoardingView == 0 {
                    BoardingName(name: self.$name)
                } else if currentBoardingView == 1 {
                    BoardingGender(gender: self.$gender)
                } else if currentBoardingView == 2 {
                    BoardingBirthday(birth: self.$birth)
                } else if currentBoardingView == 3 {
                    BoardingSize(size: self.$size)
                } else if currentBoardingView == 4 {
                    BoardingWeight(weight: self.$weight)
                } else {
                    Text("Nothing there")
                }
                
                HStack {
                    if self.currentBoardingView > 0 {
                        Button(action: navigateBoardingDown, label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.custom("", size: 50))
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding(.leading, 20)
                                .foregroundColor(.red)
                            
                        })
                    }
                    Spacer()
                    
                    if self.currentBoardingView < 4 {
                        Button(action: navigateBoardingUp, label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.custom("", size: 50))
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding(.trailing, 20)
                                .foregroundColor(.green)
                            
                        })
                    } else {
                        Button(action: saveUser, label: {
                            Text("      Fertig      ")
                                .padding()
                                .background(Color.white)
                                .clipShape(Capsule())
                                .padding(.trailing, 20)
                                .foregroundColor(.green)
                            
                        })
                        .disabled(self.name == "")
                    }
                }
            }
            
            if self.user.loading {
                ProgressView()
            }
        }
        .alert(isPresented: self.$creationError, content: {
            Alert(title: Text("Aktion fehlgeschlagen"),
                  message: Text("Dein Geburtsdatum entspricht nicht den akzeptierten Vorgaben (14-99)."),
                  dismissButton: .default(Text("Okay ich regel das")))
        })
    }
    
    
    private func navigateBoardingUp() {
        if currentBoardingView < 4 {
            self.currentBoardingView += 1
        }
    }
    
    private func navigateBoardingDown() {
        if currentBoardingView > 0 {
            self.currentBoardingView -= 1
        }
    }
    
    private func saveUser() {
        let result = self.user.createNewUser(name: self.name, birth: self.birth, gender: self.gender, weight: self.weight + 40, size: self.size + 60)
        if result == false {
            self.creationError = true
        }
    }
    
}

struct OnBoardingNavigator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnBoardingNavigator()
                .environmentObject(UserViewModel())
            
            OnBoardingNavigator()
                .environmentObject(UserViewModel())
                .environment(\.colorScheme, .dark)
        }
    }
}

