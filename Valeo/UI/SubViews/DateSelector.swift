//
//  DateSelector.swift
//  Valeo
//
//  Created by Lori Hill on 10.03.21.
//

import SwiftUI

struct DateSelector: View {
    
    @Environment(\.colorScheme) var colorScheme
    let height: CGFloat
    @Binding var selectedDate: Date
    @State var selected = false
    @State var hasNextDay = false
    @Namespace var animation
    
    var body: some View {
        ZStack {
            
            if !selected {
                HStack {
                    
                    Button(action: {
                        setToYesterday()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)
                            .foregroundColor(self.colorScheme == .light ? .black : .white)
                    })
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            self.selected.toggle()
                        }
                    }, label: {
                        Text(getFormatedDate())
                            .padding()
                            .foregroundColor(self.colorScheme == .light ? .black : .white)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        setToNextDay()
                    }, label: {
                        Image(systemName: "chevron.right")
                            .font(.largeTitle)
                            .foregroundColor(self.hasNextDay ?
                                                (self.colorScheme == .light ? .black : .white)
                                                : .clear)
                    })
                    .padding()
                    .disabled(!self.hasNext())
                    
                }
                .background(RoundedRectangle(cornerRadius: 25.0)
                                .matchedGeometryEffect(id: "id", in: self.animation)
                                .foregroundColor(self.colorScheme == .light ?
                                                Color.white.opacity(0.3) : Color.black.opacity(0.3)))
                
            } else {
                VStack(spacing: 0) {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.selected.toggle()
                            }
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(self.colorScheme == .light ? .black : .white)
                        })
                        .padding()
                    }
                    
                    DatePicker("", selection: self.$selectedDate, in: ClosedRange(uncheckedBounds: (lower: getMinDate(), upper: Date())), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                }
                .transition(.scale)
                .padding(.horizontal, 15)
                .background(RoundedRectangle(cornerRadius: 25.0)
                                .matchedGeometryEffect(id: "id", in: self.animation)
                                .foregroundColor(self.colorScheme == .light ?
                                                    Color.white : Color.black))
                .padding(.horizontal, 15)
            }
        }
        .frame(height: self.height)
        .onChange(of: self.selectedDate, perform: { value in
            self.hasNextDay = hasNext()
        })
    }
    
    private func getFormatedDate() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("german")
        formatter.dateStyle = .long
        
        let formatedString = formatter.string(from: self.selectedDate)
        
        return formatedString
    }
    
    private func getMinDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .year, value: -1, to: Date())
        
        return date ?? Date()
    }
    
    private func hasNext() -> Bool {
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .day, value: 1, to: self.selectedDate)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())
        
        
        guard let nextday = date, let actualTomorrow = tomorrow else {
            print("Could not convert dates")
            return false
        }
        
        let comaprison = calendar.compare(nextday, to: actualTomorrow, toGranularity: .day)
        
        if comaprison.rawValue == 0 {
            print("Dates are the same")
            return false
        } else {
            return true
        }
        
    }
    
    private func setToNextDay() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .day, value: 1, to: self.selectedDate)
        
        guard let nextDay = date, hasNext() else {
            print("Could not get next day")
            return
        }
        
        self.selectedDate = nextDay
        
    }
    
    private func setToYesterday() {
        let calendar = Calendar(identifier: .gregorian)
        let day = calendar.date(byAdding: .day, value: -1, to: self.selectedDate)
        
        guard let yesterday = day, yesterday > getMinDate() else {
            print("Could not get yesterday of current day")
            return
        }
        self.selectedDate = yesterday
    }
}

struct DateSelector_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [Color("lightGreen"),
                    Color("darkGreen")]),
                               startPoint: .topTrailing,
                               endPoint: .bottomLeading)
                    .edgesIgnoringSafeArea(.all)
                
                Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                
                DateSelector(height: 90, selectedDate: .constant(Date()))
                    .environment(\.locale, .init(identifier: "de"))
            }
            
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [Color("lightGreen"),
                    Color("darkGreen")]),
                               startPoint: .topTrailing,
                               endPoint: .bottomLeading)
                    .edgesIgnoringSafeArea(.all)
                
                Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                
                DateSelector(height: 90, selectedDate: .constant(Date()))
                    .environment(\.locale, .init(identifier: "de"))
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
