//
//  MealCategoryMenuBar.swift
//  Valeo
//
//  Created by Lori Hill on 26.02.21.
//

import SwiftUI

struct MealCategoryMenuBar: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigator: Navigator
    @Binding var isExtended: Bool
    @Binding var isToday: Bool
    let mealType: MealType
    
    var body: some View {
        HStack {
            Text(self.mealType.rawValue)
                .font(.title)
                .foregroundColor(self.colorScheme == .light ?
                                    Color.black : Color.white)
                .padding(.leading, 20)
            
            Spacer()
            
            Button(action: self.addNewNutrient) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(isToday ? Color.green :
                                        (self.colorScheme == .light ?
                                                                Color.black : Color.white))
                    .padding(.trailing, 20)
            }
            .disabled(!self.isToday)
        }
        .padding()
        .onTapGesture {
            withAnimation(.easeOut) {
                isExtended.toggle()
            }
        }
        .background(RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(self.colorScheme == .light ?
                                            Color(.systemGray) : Color.black)
                        .onTapGesture {
                            withAnimation(.easeOut) {
                                isExtended.toggle()
                            }
                    })
    }
    
    private func addNewNutrient() {
        withAnimation {
            self.navigator.curentMealType = self.mealType
            self.navigator.currentView = .searchbar
        }
    }
}

struct MealCategoryMenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MealCategoryMenuBar(isExtended: .constant(false), isToday: .constant(true), mealType: .breakfast)
            .environmentObject(Navigator())
    }
}
