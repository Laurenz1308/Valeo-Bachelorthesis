//
//  MainUser.swift
//  Valeo
//
//  Created by Laurenz Hill on 13.12.20.
//

import SwiftUI

/// Main user view.
/// Displays all interesting information of a user by using grafics etc.
struct MainUser: View {
    
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var user: UserViewModel
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        NavigationView{
            UserView()
                .navigationBarTitle(user.name + " \(user.age)")
                .navigationBarItems(leading: Button(action: { withAnimation {
                    navigator.setCurrentView(to: .main)
                }}, label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(self.scheme == .dark ? .white : .black)
                        .animation(.easeIn)
                        .padding(.trailing, 20)
                        .padding(.vertical, 10)
                }))
        }
    }
}

struct MainUser_Previews: PreviewProvider {
    static var previews: some View {
        MainUser()
            .environmentObject(Navigator())
            .environmentObject(UserViewModel())
    }
}
