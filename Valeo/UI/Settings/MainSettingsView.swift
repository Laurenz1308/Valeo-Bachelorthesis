//
//  MainSettingsView.swift
//  Valeo
//
//  Created by Lori Hill on 09.01.21.
//

import SwiftUI

/// Settings navigation view.
struct MainSettingsView: View {
    @EnvironmentObject var navigator: Navigator
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        NavigationView {
            Settings()
                .navigationBarTitle("Einstellungen")
                .navigationBarItems(leading: Button(action: { withAnimation {
                    navigator.currentView = .main
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

struct MainSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MainSettingsView()
            .environmentObject(Navigator())
            .environment(\.colorScheme, .dark)
    }
}
