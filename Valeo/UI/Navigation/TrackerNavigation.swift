//
//  MainTabBar.swift
//  Valeo
//
//  Created by Laurenz Hill on 13.12.20.
//

import SwiftUI

/// Main View of the App.
struct TrackerNavigation: View {
    
    @StateObject var offsetManager: OffsetManager = OffsetManager()
    @EnvironmentObject var navigator: Navigator
    
    var tabs = ["Home","Restaurants","Orders","Rewards"]
    
    var body: some View {
        GeometryReader { geometry in
                        
            ZStack {

                MainTracker()
                    .environmentObject(self.offsetManager)
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                                withAnimation {
                                    navigator.setCurrentView(to: .settings)
                                }}) {
                            Image(systemName: "gear")
                                .font(.largeTitle)
                                .foregroundColor(navigator.currentView == .settings ? .red : .black)
                                .padding(.horizontal, 20)
                                .animation(.easeIn)
                                .scaleEffect(offsetManager.defaultOffset - offsetManager.offset < 50 ? 1.2 : 1.0)
                                .offset(x: 0, y: offsetManager.defaultOffset - offsetManager.offset < 50 ? 20 : 5)
                        }
                        
                        Spacer()
                        
                        Button(action: {withAnimation {
                            navigator.setCurrentView(to: .user)
                        }}) {
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(navigator.currentView == .user ? .red : .black)
                                .padding(.horizontal, 20)
                                .animation(.easeIn)
                                .scaleEffect(offsetManager.defaultOffset - offsetManager.offset < 50 ? 1.2 : 1.0)
                                .offset(x: 0, y: offsetManager.defaultOffset - offsetManager.offset < 50 ? 20 : 5)
                        }
                    }
                    .padding(.top, 30)
                    .frame(width: geometry.size.width, height: 85, alignment: .center)
                    .padding(.bottom, 10)
                    .background(offsetManager.defaultOffset - offsetManager.offset < 150 ? Color.clear : Color.white.opacity(0.6))
                    .animation(.easeIn)

                    Spacer()

                }
                .edgesIgnoringSafeArea(.all)

            }
            .offset(x: self.navigator.currentView == .user ? -geometry.size.width : 0)
            
        }
    }
}



struct TrackerNavigation_Preview: PreviewProvider {
    static var previews: some View {
        TrackerNavigation()
            .environmentObject(OffsetManager())
            .environmentObject(DaysummaryViewModel())
            .environmentObject(Navigator())
            .environmentObject(UserViewModel())
    }
}
