//
//  DailyNutrientRow.swift
//  Valeo
//
//  Created by Laurenz Hill on 12.12.20.
//

import SwiftUI

/// View to display a basic summary of the current day in the calorietracker.
struct DailyNutrientRow: View {
    
    @EnvironmentObject var daySummary: DaysummaryViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Konsumierte Nährstoffe")
                    .font(.title3)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.top, 15)
            .padding(.bottom, 5)
            
            HStack {
                
                Spacer()
                
                VStack {
                    Text("\(daySummary.totalCarbohydrates) g")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                    Text("Kohlenhydrate")
                        .allowsTightening(true)
                        .foregroundColor(.white)
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity)
                
                VStack {
                    Text("\(daySummary.totalProtein) g")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                    Text("Eiweiß")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity)
                
                VStack {
                    Text("\(daySummary.totalFat) g")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                    Text("Fett")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity)
                
                
            }
            .background(RoundedRectangle(cornerRadius: 25.0)
                            .foregroundColor(Color.black.opacity(0.5)))
        }
        .padding(.horizontal, 15)
    }
}

struct DailyNutrientRow_Previews: PreviewProvider {
    static var previews: some View {
        DailyNutrientRow()
            .environmentObject(DaysummaryViewModel())
    }
}
