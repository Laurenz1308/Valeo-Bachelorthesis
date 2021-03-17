//
//  NavigationView.swift
//  Valeo
//
//  Created by Laurenz Hill on 18.12.20.
//

import SwiftUI

/// Manages the main navigation of the UI.
/// Contains all state object needed across the app lifecycle.
struct MainNavigationView: View {
            
    @StateObject var navigator = Navigator()
    @StateObject var user = UserViewModel()
    @StateObject var daySummary = DaysummaryViewModel()
        
    var body: some View {
        ZStack {
            
            if navigator.currentView == .main {
                TrackerNavigation()
                    .environmentObject(navigator)
                    .environmentObject(user)
                    .environmentObject(daySummary)
                    .zIndex(1)
            }
            if navigator.currentView == .settings {
                MainSettingsView()
                    .environmentObject(navigator)
                    .environmentObject(user)
                    .environmentObject(daySummary)
                    .transition(.move(edge: .trailing))
                    .animation(.easeIn(duration: 0.3))
                    .zIndex(2)
            }
            if navigator.currentView == .user {
                MainUser()
                    .environmentObject(navigator)
                    .environmentObject(user)
                    .environmentObject(daySummary)
                    .transition(.move(edge: .trailing))
                    .animation(.easeIn(duration: 0.3))
                    .zIndex(2)
            }
            if navigator.currentView == .searchbar {
                MainSearchbarView()
                    .environmentObject(navigator)
                    .environmentObject(user)
                    .environmentObject(daySummary)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)

            }
            if navigator.currentView == .anamnesis {
                MainAnamnesisView()
                    .environmentObject(navigator)
                    .environmentObject(user)
                    .environmentObject(daySummary)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
            
            // All possible overlays on top of main application
            ZStack {
                if self.navigator.showPopUpView {
                    self.navigator.popUpView
                        .environmentObject(user)
                        .environmentObject(navigator)
                        .zIndex(1)
                }
                
                if !self.user.hasAcceptedPrivacyPolicy {
                    ZStack {
                        Color
                            .black
                            .opacity(0.7)
                            .ignoresSafeArea()

                        AcceptPrivacyPolicy()
                            .environmentObject(user)
                            .frame(width: UIScreen.main.bounds.size.width * 0.8,
                                   height: UIScreen.main.bounds.size.height * 0.7,
                                   alignment: .center)
                    }
                    .zIndex(5)
                }
                
                if !self.navigator.showedIntroduction {
                    IntroductionViewManager()
                        .environmentObject(user)
                        .environmentObject(navigator)
                        .zIndex(3)
                }

                if self.user.noUserFound {
                    OnBoardingNavigator()
                        .environmentObject(navigator)
                        .environmentObject(user)
                        .environmentObject(daySummary)
                        .zIndex(4)
                }
            }
            .zIndex(5)
            
        }
    }
    
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
