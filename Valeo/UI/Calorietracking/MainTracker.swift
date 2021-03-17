//
//  MainTracker.swift
//  Valeo
//
//  Created by Laurenz Hill on 10.12.20.
//

import SwiftUI
import UserNotifications

/// View of the Calorietracking. Displaying all relevant information of the current day.
struct MainTracker: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var offsetManager: OffsetManager
    
    @State var circleAnimation = false
    
    @State var trained = 0
    @State var bilanceText = ""
    
    @EnvironmentObject var daySummary: DaysummaryViewModel
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var navigator: Navigator
        
    var body: some View {
        ZStack {
            if self.daySummary.daysummary != nil {
                GeometryReader { geometry in
                    ZStack {
                        
                        LinearGradient(gradient: Gradient(colors: [Color("lightGreen"),
                            Color("darkGreen")]),
                                       startPoint: .topTrailing,
                                       endPoint: .bottomLeading)
                            .edgesIgnoringSafeArea(.all)
                        
                        Color.black.opacity(self.colorScheme == .light ? 0.2 : 0.5)
                                .edgesIgnoringSafeArea(.all)

                        
                        VStack(spacing: 0) {
                            ScrollView(.vertical, showsIndicators: false) {

                                HStack {
                                    RingProgress(width: geometry.size.width,
                                                 height: geometry.size.height,
                                                 animation: self.$circleAnimation,
                                                 text: $bilanceText,
                                                 loading: self.$daySummary.loading,
                                                 calorieGoal: Int(self.user.user?.calorieGoal ?? 0))
                                }
                                .frame(width: geometry.size.width,
                                       height: geometry.size.height * 0.3 +
                                        (self.offsetManager.offset >= -30 ? self.offsetManager.offset : -30),
                                       alignment: .bottom)
                                .padding(.top, 30)

                                VStack {
                                    HStack {
                                        Spacer()
                                        BigIndicator(emoji: "🍴",
                                                     text: self.daySummary.totalCalories)
                                            .frame(width: 100, height: 100, alignment: .center)
                                        Spacer(minLength: geometry.size.width * 0.3)
                                        BigIndicator(emoji: "🔥", text: self.trained)
                                            .frame(width: 100, height: 100, alignment: .center)
                                        Spacer()
                                    }
                                    
                                    DateSelector(height: 90, selectedDate: self.$daySummary.selectedDate)
                                        .padding(.horizontal, geometry.size.width * 0.05)
                                        .zIndex(5)

                                    DailyNutrientRow()
                                        .frame(width: geometry.size.width , height: 125, alignment: .center)
                                }
                                .padding(.bottom, 20)
                                
                                if user.showSurvey && user.surveyLink != "" {
                                    SurveyLink(text: user.surveyLink)
                                        .padding(.bottom, 20)
                                }

                                if !self.daySummary.loading {
                                    MealSummary(width: geometry.size.width,
                                                mealType: .breakfast)


                                    MealSummary(width: geometry.size.width,
                                                mealType: .lunch)

                                    MealSummary(width: geometry.size.width,
                                                mealType: .snack)

                                    MealSummary(width: geometry.size.width,
                                                mealType: .dinner)
                                }
                                
                                Button(action: { withAnimation { self.navigator.setCurrentView(to: .anamnesis)}}, label: {
                                    Text(self.daySummary.hasTodaysAnamnesis ? "Anamnese ✅" : "Anamnese")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Capsule()
                                                        .foregroundColor(self.daySummary.hasTodaysAnamnesis
                                                                            ? Color.black : Color.red))
                                        .padding(.horizontal, 15)
                                })
                                .disabled(self.daySummary.hasTodaysAnamnesis)

                                Spacer()
                                    .frame(height: geometry.size.height * 0.1, alignment: .trailing)

                            }
                        }
                    }
                }
                .onAppear {getText()}
                .onChange (of: self.daySummary.totalCalories, perform: { value in
                    getText()
                })

            } else {
                ZStack{
                    Color(self.colorScheme == .light ? "lightGreen" : "darkGreen")
                        .ignoresSafeArea()
                    Image("ValeoLogoLaunchScreen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.size.width,
                               alignment: .center)
                }
            }
        }
    }
    
    func getText() {
        
        if daySummary.totalCalories < Int(user.user?.calorieGoal ?? 0) {
            self.bilanceText = "\(Int(user.user?.calorieGoal ?? 0) - daySummary.totalCalories) kcal \n übrig"
        } else {
            self.bilanceText = "\(daySummary.totalCalories - Int(user.user?.calorieGoal ?? 0)) kcal \n zu viel"
        }
        
    }
    
}

struct MainTracker_Previews: PreviewProvider {
    static var previews: some View {
            MainTracker()
                .environmentObject(OffsetManager())
                .environmentObject(DaysummaryViewModel())
                .environmentObject(UserViewModel())
    }
}
