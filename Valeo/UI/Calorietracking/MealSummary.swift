//
//  MealSummary.swift
//  Valeo
//
//  Created by Laurenz Hill on 12.12.20.
//

import SwiftUI

/// View to sum all consumed nutrients of a meal.
struct MealSummary: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var daySummary: DaysummaryViewModel
    
    let width: CGFloat
    @State var isExtended = true
    let mealType: MealType
            
    var body: some View {
        ZStack {
            // List of nutrients of displayed meal
            VStack(spacing: 0) {
                Spacer()
                    .frame(width: width, height: 75, alignment: .center)
                
                if self.isExtended {
                    ForEach(getConsumptionArray(of: self.daySummary)) { x in
                        if x.consumption != nil {
                            NutrientCell(consumption: x, deleteItem: self.delete(_:), showsToday: self.$daySummary.showsToday)
                                .frame(width: width - 50)
                        }
                    }
                }
            }
                .padding(.bottom, 20)
                .zIndex(0)
                .frame(width: width - 50,
                       height: self.isExtended ? getHeight() : 0,
                       alignment: .center)
                .background(RoundedRectangle(cornerRadius: 25.0)
                                .foregroundColor(self.colorScheme == .light ? Color.white : Color(.systemGray4)))
    //                    .offset(x: 0, y: -75)
            .animation(.easeInOut)
            
            VStack(spacing: 0) {
                MealCategoryMenuBar(isExtended: $isExtended, isToday: self.$daySummary.showsToday, mealType: mealType)
                    .frame(width: width - 30, height: 75, alignment: .center)
                    .offset(y: -5)
                
                
                Spacer()
                    .frame(width: width - 40 ,
                           height: self.isExtended ? getHeight() - 75 : 0,
                           alignment: .center)
            }
            .zIndex(1)
            .animation(.easeInOut)
            
            
            }
        .padding(.bottom, self.isExtended ? 20 : 0)
    }
    
    private func addNewNutrient() {
        withAnimation {
            self.navigator.curentMealType = self.mealType
            self.navigator.currentView = .searchbar
        }
    }
    
    private func delete(_ consumption: ConsumptionViewModel) {
        guard let id = consumption.consumption?.consumptionId else {
            return
        }
        self.daySummary.deleteConsumption(by: id)
    }
    
    private func getConsumptionArray(of summary: DaysummaryViewModel) -> [ConsumptionViewModel] {
        switch self.mealType {
        case .breakfast:
            return summary.breakfast
        case .lunch:
            return summary.lunch
        case .snack:
            return summary.snack
        case .dinner:
            return summary.dinner
        }
    }
    
    private func getHeight() -> CGFloat {
        
        let bar = 75
        let rowHeight = 50 * getConsumptionArray(of: self.daySummary).count
        let bottomPadding = 20
        
        return CGFloat(bar + rowHeight + bottomPadding)
        
    }
}

#if DEBUG
struct MealSummary_Previews: PreviewProvider {
    
    static let content = DaysummaryViewModel()
    
    static var previews: some View {
        Group {
            MealSummary(width: 400,
                        mealType: .breakfast)
                .environmentObject(content)
            
            MealSummary(width: 400,
                        mealType: .breakfast)
                .environmentObject(content)
                .environment(\.colorScheme, .dark)
        }
            
    }
}
#endif


