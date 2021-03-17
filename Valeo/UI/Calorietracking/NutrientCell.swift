//
//  NutrientCell.swift
//  Valeo
//
//  Created by Laurenz Hill on 13.12.20.
//

import SwiftUI

/// View to reprecent a consumed nutrient in the MealSummary.swift.
struct NutrientCell: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var consumption: ConsumptionViewModel
    var deleteItem: (_ consumption: ConsumptionViewModel) -> Void
    
    @State var offset: CGFloat = 0
    @State var isSwiped = false
    @Binding var showsToday: Bool
    
    var body: some View {
        
        ZStack {
            
            if self.offset != 0 {
                LinearGradient(gradient: Gradient(colors: [.yellow ,.red]),
                               startPoint: .leading,
                               endPoint: .trailing)
            }
            
            HStack {
                
                Spacer()
                
                Button(action: {withAnimation(.easeOut) {deleteItem(consumption)}}) {
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(self.offset != 0 ? .white : .clear)
                        .frame(width: 75, height: 50, alignment: .center)
                }
                
            }
            
            HStack {
                Text(consumption.consumption?.name ?? "")
                    .foregroundColor(self.colorScheme == .light ? .black : .white)
                
                Text(consumption.totalText)
                    .foregroundColor(self.colorScheme == .light ? .black : .white)
                
                Spacer()
            }
            .padding()
            .background(self.colorScheme == .light ? Color.white : Color(.systemGray4))
            .contentShape(Rectangle())
            .offset(x: offset)
            .gesture(DragGesture()
                        .onChanged(self.onChanged(value:))
                        .onEnded(self.onEnd(value:)))
        }
        .frame(height: 50, alignment: .center)
    }
    
    private func onChanged(value: DragGesture.Value) {
        if self.showsToday {
            if value.translation.width < 0 {
                if isSwiped {
                    self.offset = value.translation.width - 90
                } else {
                    self.offset = value.translation.width
                }
            }
        }
    }
    
    private func onEnd(value: DragGesture.Value) {
        
        guard self.showsToday else {
            return
        }
        
        withAnimation(.easeOut(duration: 0.1)) {
            if value.translation.width < 0 {
                
                // Checking conditions
                
                if -value.translation.width > UIScreen.main.bounds.width/2 {
                    offset = -1000
//                    deleteItem(nutrient)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut){
                            deleteItem(consumption)
                        }
                    }
                } else if value.translation.width < -75 {
                    offset = -75
                    isSwiped = true
                } else {
                    offset = 0
                    isSwiped = false
                }
                
            } else {
                offset = 0
                isSwiped = false
            }
        }
        
    }
    
    private func getAmountString() -> String {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        
        return format.string(from: NSNumber(value: consumption.amount)) ?? ""
    }
    
}

struct NutrientCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NutrientCell(consumption: ConsumptionViewModel(consumption: Consumption(consumptionId: UUID(), userId: "", created: "", nutrientId: UUID(), name: "Apfel", calories: 123, total_fat: 0.6, saturated_fat: 0.3, protein: 3, carbohydrate: 34, sugars: 12.5, serving_size: 100, amount: 1, meal: MealType.breakfast.rawValue)),
                         deleteItem: { (_) in }, showsToday: .constant(true))
            
            NutrientCell(consumption: ConsumptionViewModel(consumption: Consumption(consumptionId: UUID(), userId: "", created: "", nutrientId: UUID(), name: "Apfel", calories: 123, total_fat: 0.6, saturated_fat: 0.3, protein: 3, carbohydrate: 34, sugars: 12.5, serving_size: 100, amount: 1, meal: MealType.breakfast.rawValue)),
                         deleteItem: { (_) in }, showsToday: .constant(true))
                .environment(\.colorScheme, .dark)
        }
    }
}
