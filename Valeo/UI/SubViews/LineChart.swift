//
//  LineChart.swift
//  Valeo
//
//  Created by Lori Hill on 09.02.21.
//

import SwiftUI

struct LineChart: View {
    
    @Binding var mutatingValuesList: [UserMutable]
    
    var maxY: Int {
        if mutatingValuesList.count > 1 {
            return getMaxOfWeights(from: mutatingValuesList) + 2
        } else {
            return 0
        }
    }
    
    var minY: Int {
        if mutatingValuesList.count > 1 {
            return getMinOfWeights(from: mutatingValuesList) - 2
        } else {
            return 0
        }
    }
    
    var maxXDate: Date {
        if mutatingValuesList.isEmpty {
            return getMaxOfDates(from: mutatingValuesList)
        } else {
            return Date()
        }
    }
    
    var minXDate: Date {
        if mutatingValuesList.isEmpty {
            return getMinOfDates(from: mutatingValuesList)
        } else {
            return Date()
        }
    }
    
    let minX = 0
    
    var maxX: Int {
        if mutatingValuesList.isEmpty {
            return distantanceOfDatesInDays(maxXDate, minXDate)
        } else {
            return 0
        }
    }
    
    var xrange: Int {
        mutatingValuesList.count
    }
    
    static let height: CGFloat = 200
    
    static let width: CGFloat = UIScreen.main.bounds.size.width - 50
    
    @State var trim = false
    
    var body: some View {
        VStack {
            
            HStack {
                Text("\(maxY) kg")
                    .padding(.leading, 50)
                    .foregroundColor(.white)
                    .offset(x: 0, y: 30.0)
                
                Spacer()
            }
            .zIndex(2)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black)
                    .background(RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.black.opacity(0.8)))
                    .frame(width: LineChart.width, height: LineChart.height, alignment: .center)
                    .zIndex(-1)
                
                if mutatingValuesList.count > 1 {
                    LimitLine(upperBorder: getY(for: getMinOfWeights(from: self.mutatingValuesList)), width: LineChart.width)
                        .stroke(Color.white)
                        .frame(width: LineChart.width, height: LineChart.height, alignment: .center)
                    
                    LimitLine(upperBorder: getY(for: getMaxOfWeights(from: self.mutatingValuesList)), width: LineChart.width)
                        .stroke(Color.white)
                        .frame(width: LineChart.width, height: LineChart.height, alignment: .center)
                    
                    LineGraph(dataPoints: getPointsForChart(of: self.mutatingValuesList))
                        .trim(from: 0.0, to: self.trim ? 1.0 : 0.0)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.green, Color.white ,Color.red]), startPoint: .bottom, endPoint: .top), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .shadow(color: .white, radius: 2)
                        .frame(width: LineChart.width, height: LineChart.height, alignment: .center)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2)) {
                                self.trim.toggle()
                            }
                        }
                }
            }
            
            HStack {
                Text("\(minY) kg")
                    .padding(.leading, 50)
                    .foregroundColor(.white)
                    .offset(x: 0, y: -30.0)
                
                Spacer()
            }
            .zIndex(2)
        }
    }
    
    private func getPointsForChart(of list: [UserMutable]) -> [CGPoint] {
        
        var points: [CGPoint] = []
        
        let sortedList = list.sorted { (value1, value2) -> Bool in
            value2.created > value1.created
        }
        
        for value in sortedList {
            guard let date = smallISOConverter(from: value.created) else {
                print("\(value.created) could not be parsed to a date")
                break
            }
            
            let x = getX(for: date)
            let y = getY(for: value.weight)
            
            let point = CGPoint(x: x, y: y)
            points.append(point)
        }
        
        return points
    }

    private func getX(for date: Date) -> CGFloat {
        
        let dayDistance = distantanceOfDatesInDays(date, minXDate)
        
        let inPercent = CGFloat(dayDistance) / CGFloat(maxX)
        
        let inRelationToWidth = LineChart.width * inPercent
        
        return CGFloat(inRelationToWidth)
    }

    private func getY(for weight: Int) -> CGFloat {
        
        let normalizedMaxY = maxY - minY
        
        let normalizedWeight = weight - minY
        
        let inPercent = CGFloat(normalizedWeight) / CGFloat(normalizedMaxY)
        
        let inRelationToHeight = LineChart.height * (1 - inPercent)
        
        return CGFloat(inRelationToHeight)
        
    }

    private func getMaxOfDates(from array: [UserMutable]) -> Date {
        
        var maxDate = smallISOConverter(from: "1990-01-01")
        
        for element in array {
            guard let date = smallISOConverter(from: element.created) else {
                break
            }
            
            if date > maxDate ?? Date() {
                maxDate = date
            }
        }
                
        return maxDate ?? Date()
    }

    private func getMinOfDates(from array: [UserMutable]) -> Date {
        
        var minDate = Date()
        
        for element in array {
            let date = smallISOConverter(from: element.created)
            
            if date != nil {
                if date! < minDate {
                    minDate = date!
                }
            }
        }
        
        return minDate
    }

    private func getMaxOfWeights(from array: [UserMutable]) -> Int {
        var maxWeight: Int = -10
        
        for element in array {
            if element.weight > maxWeight {
                maxWeight = element.weight
            }
        }
        
        return maxWeight
    }

    private func getMinOfWeights(from array: [UserMutable]) -> Int {
        var minWeight: Int = 99999999999
        
        for element in array {
            if element.weight < minWeight {
                minWeight = element.weight
            }
        }
        
        return minWeight
    }

    private func smallISOConverter(from string: String) -> Date? {
        let isoFromatter = DateFormatter()
        isoFromatter.dateFormat = "yyyy-MM-dd"
        let fromatedDate = isoFromatter.date(from: string)
        
        return fromatedDate
    }

    private func distantanceOfDatesInDays(_ lhs: Date, _ rhs: Date) -> Int {
        
        let distanceTimeInterval = lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
        
        let distanceInDays = Double(distanceTimeInterval) / (24 * 60 * 60)
        
        return Int(distanceInDays)
    }
    
}

struct MyLineChart_Previews: PreviewProvider {
    
    static let previewUserMutable = [
        UserMutable(created: "2021-01-01", weight: 79, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-01-07", weight: 78, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-01-14", weight: 79, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-01-21", weight: 78, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-01-28", weight: 78, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-02-04", weight: 77, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-02-12", weight: 76, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-02-17", weight: 74, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-02-26", weight: 75, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-03-07", weight: 74, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-03-14", weight: 72, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-03-21", weight: 73, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-03-28", weight: 74, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-04-04", weight: 72, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-04-12", weight: 71, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0),
        UserMutable(created: "2021-04-17", weight: 71, size: 184, bmi: 0, waist: 0, bodyFat: 0, calorieGoal: 0)
    ]
    
    static var previews: some View {
        LineChart(mutatingValuesList: .constant(previewUserMutable))
    }
}

struct LineGraph: Shape {
    
    var dataPoints: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            guard dataPoints.count > 1 else { return }

            p.move(to: dataPoints[0])

            for x in dataPoints {
                p.addLine(to: x)
            }
        }
    }
    
    
}

struct LimitLine: Shape {
    var upperBorder: CGFloat
    var width: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 0, y: upperBorder))
            p.addLine(to: CGPoint(x: width, y: upperBorder))
        }
    }
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
