//
//  LoginAndSignupTabBar.swift
//  Valeo
//
//  Created by Lori Hill on 25.02.21.
//

import SwiftUI

struct LoginAndSignupTabBar: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    @State var selectedTab = "Login"
    var tabs = ["Login", "Signup"]
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            TabView(selection: self.$selectedTab) {
                Color.black
                    .tag("Login")
                
                Color.black
                    .tag("Signup")
            }
            
            // Custom Bar
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring()){
                                    self.selectedTab = tab
                                }
                            }, label: {
                                Text(tab)
                                    .font(.largeTitle)
                                    .foregroundColor(getTextColor(of: tab))
                                    .scaleEffect(tab == selectedTab ? 1.2 : 1)
                                    .frame(width: 150, height: 50, alignment: .center)
                                                            
                            })
                            
                            if tab != tabs.last{Spacer(minLength: 0).frame(height: 50)}
                            
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical)
                    .background(Color(.systemGray3)
                                    .clipShape(AuthenticationCurve(axisFactor:
                                                                    selectedTab == "Login" ?
                                                                        0 : (geometry.size.width / 2) + 50)))
                }
                .frame(height: 81)
                
                
                ZStack {
                    if self.selectedTab == tabs[0] {
                        LoginTabView(namespace: self.animation)
                            .matchedGeometryEffect(id: "auth", in: self.animation)
                    } else {
                        SignupTabView(namespace: self.animation)
                            .matchedGeometryEffect(id: "auth", in: self.animation)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray3))
            }
        }
        
    }
    
    private func getTextColor(of tab: String) -> Color {
        switch self.colorScheme {
        case .light:
            if tab == self.selectedTab {
                return Color.black
            } else {
                return Color.white
            }
        case.dark:
            if tab == self.selectedTab {
                return Color.white
            } else {
                return Color(.systemGray2)
            }
        default:
            return Color.white
        }
    }
    
}

struct LoginAndSignupTabBar_Previews: PreviewProvider {
    static var previews: some View {
        LoginAndSignupTabBar()
            .environmentObject(AuthenticationViewModel())
    }
}
