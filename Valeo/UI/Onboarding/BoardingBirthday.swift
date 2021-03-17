//
//  BoardingBirthday.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct BoardingBirthday: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var birth: Date
    
    var body: some View {
        VStack {
            Spacer()
            Text("Wann ist dein Geburtstag?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 30)
            
            DatePicker("", selection: self.$birth, in: ClosedRange(uncheckedBounds: (lower: getMinDate(), upper: getMaxDate())), displayedComponents: .date)
                        
//            DatePicker("", selection: self.$birth, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .padding(.horizontal, 15)
                .background(RoundedRectangle(cornerRadius: 25.0)
                                .foregroundColor(self.colorScheme == .light ?
                                                    Color.white.opacity(0.3) : Color.black.opacity(0.3)))
                .padding(.horizontal, 15)
            
            Spacer()
        }
    }
    
    private func getMinDate() -> Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let oldestAgeUnsecure = calendar.date(byAdding: .year, value: -100, to: Date())
        
        return oldestAgeUnsecure ?? Date()
    }
    
    private func getMaxDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let youngestAgeUnsecure = calendar.date(byAdding: .year, value: -14, to: Date())
        
        return youngestAgeUnsecure ?? Date()
    }
}

struct BoardingBirthday_Previews: PreviewProvider {
    
    static let colors: [Color] = [
        Color(.sRGB, red: 214/255, green: 93/255, blue: 177/255, opacity: 1),
        Color(.sRGB, red: 132/255, green: 94/255, blue: 194/255, opacity: 1)
    ]
    
    static var previews: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .topTrailing, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)
            
            BoardingBirthday(birth: .constant(Date()))
        }
        
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .topTrailing, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)
            
            BoardingBirthday(birth: .constant(Date()))
        }.environment(\.colorScheme, .dark)
    }
}
