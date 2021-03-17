//
//  Navigator.swift
//  Valeo
//
//  Created by Laurenz Hill on 18.12.20.
//

import Foundation
import SwiftUI

/// Navigator is managing the views and sharing data between unconnected views.
class Navigator: ObservableObject {
    
    @Published var currentView: Pages = .main
    
    @Published var showPopUpView = false
    @Published var popUpView: PopUpViewContainer = PopUpViewContainer(content: NumberStepper(typeToChange: .weight, text: ""))
    
    @Published var curentMealType: MealType = .breakfast
    @Published var isNewNutrient = false
    @Published var showedIntroduction: Bool
    
    init() {
        let defaults = UserDefaults().bool(forKey: "showedIntroduction")
        self.showedIntroduction = defaults
    }
    
    public func setCurrentView(to view: Pages){
        if self.currentView != view {
            self.currentView = view
        }
    }
    
}

public enum Pages {
    case main
    case user
    case settings
    case searchbar
    case anamnesis
}

struct PopUpViewContainer<Content: View> : View {
    
    @EnvironmentObject var navigator: Navigator
    let content: Content
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        self.navigator.showPopUpView = false
                    }
                }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    content
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
}
