//
//  NutrientView.swift
//  Valeo
//
//  Created by Lori Hill on 27.01.21.
//

import SwiftUI
import CoreML

/// View to display a nutrient and its informations and amount for consumption.
struct NutrientView: View {
    
    let nutrientBase: NutrientBase
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var daySummary: DaysummaryViewModel
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var consumption: ConsumptionViewModel
    @State var amount = "100"
    @State var pickerSelection: AmountSizes = .gramms
    
    @State var saveAnimation = false
    @State private var displayBorder = false   // StrokeBorder (lineWidth) 64 - 5
    @State private var displayCheckmark = false  // Trimpath from 1 - 0
    @State private var mlRating: Double = 0
    
    private let user: User
    
    init(by nutrient: NutrientBase, mealType: MealType, user: User) {
        self.user = user
        self.nutrientBase = nutrient
        self.consumption = ConsumptionViewModel(with: nutrient, mealType: mealType)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        HStack {
                            Text(consumption.consumption?.name ?? "")
                                .font(.largeTitle)
                                .padding(.leading, 40)
                                                    
                            Spacer()
                        }
                        .padding(.top, 60)
                        .background(Color(.systemGray))
                        
                        HStack {
                            TextField("Input", text: $amount)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .frame(width: 100, height: 60, alignment: .center)
                                .padding(.leading, 30)
                            
                            Picker(selection: $pickerSelection, label: pickerTitleView, content: {
                                ForEach(AmountSizes.allCases) { size in
                                    Text(size.id)
                                        .tag(size)
                                }
                            })
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                            .frame(width: 200, height: 34, alignment: .center)
                            .contentShape(Rectangle())
                            .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(.systemGray4), lineWidth: 0.5))
                            
                            Spacer()
                        }
                        .padding(.top, 30)
                        
                        Button(action: self.saveButtonAction, label: {
                            Text(self.navigator.isNewNutrient ? "Speichern" : "Hinzufügen")
                                .foregroundColor(.black)
                                .frame(width: geometry.size.width * 0.7)
                                .padding()
                                .background(Color.green)
                                .clipShape(Capsule())
                        })
                        
                        HStack {
                            Text(self.consumption.calorieText)
                                .font(.largeTitle)
                                .padding(.leading, 40)
                            Spacer()
                            Text(self.getRatingEmoji())
                                .font(.title)
                                .padding(.top, 20)
                                .padding(.trailing, 40)
                        }
                        .padding(.top, 10)
                        
                        nutritionInformationText
                                            
                        Divider()
                        
                        nutrientBaseInformation
                            .padding(.horizontal, 30)
                        
                        Divider()
                        
                        furtherInformations
                    }
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                    updateCurrentValues()
                }
                .onChange(of: self.pickerSelection, perform: { value in
                    updateCurrentValues()
            })
                
                if saveAnimation {
                    Color
                        .black
                        .opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ZStack {
                        Circle()
                            .strokeBorder(style: StrokeStyle(lineWidth: displayBorder ? 5 : 64))
                            .frame(width: 128, height: 128)
                            .foregroundColor(.green)
                            .animation(Animation
                                        .easeOut(duration: 1.5)
                                        .speed(3))
                            .onAppear() {
                                    self.displayBorder.toggle()
                            }

                        Path { path in
                            path.move(to: CGPoint(x: -30, y: 0))
                            path.addLine(to: CGPoint(x: -30, y: 0))
                            path.addLine(to: CGPoint(x: -10, y: 20))
                            path.addLine(to: CGPoint(x: 30, y: -20))
                        
                        }.trim(from: 0, to: displayCheckmark ? 1 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 10,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .foregroundColor(displayCheckmark ? .green : .white)
                        .offset(x: geometry.size.width * 0.5,
                                y: geometry.size.height * 0.5)
                        .animation(Animation
                                    .interpolatingSpring(stiffness: 160, damping: 20)
                                    .delay(1))
                        .onAppear() {
                            self.displayCheckmark.toggle()
                        }
                    }
                }
                
            }
        }
        .onAppear {
            self.calculateRating(user: self.user)
            if (consumption.vitamines.isEmpty) &&
                (consumption.minerals.isEmpty) &&
                (consumption.others.isEmpty) {
                consumption.getFurtherInformation()
            }
        }
    }
    
    var nutritionInformationText: some View {
        VStack {
            HStack {
                Text("Nährwertangabe")
                    .font(.title)
                    .padding(.top, 20)
                    .padding(.leading, 40)
                Spacer()
            }
            
            HStack {
                Text(self.consumption.servingSizeText)
                    .padding(.leading, 40)
                Spacer()
            }
        }
    }
    
    var nutrientBaseInformation: some View {
        VStack(spacing: 5) {
            InformationRow(text: "Protein", value: self.consumption.proteinText)
            InformationRow(text: "Fett", value: self.consumption.totalFatText)
            InformationRow(text: "Gesättigte Fettsäuren", value: self.consumption.saturatedFatText)
            InformationRow(text: "Kohlenhydrate", value: self.consumption.carbohydrateText)
            InformationRow(text: "Zucker", value: self.consumption.sugarsText)
        }
    }
    
    var furtherInformations: some View {
        VStack {
            if !consumption.vitamines.isEmpty {
                                
                HStack {
                    Text("Vitamine")
                        .font(.largeTitle)
                        .padding(.leading, 40)
                    Text("100g")
                    Spacer()
                }
                DictionaryInformationView(dictionary: consumption.vitamines)
                    .padding(.horizontal, 30)
                Divider()
            }
            
            if !consumption.minerals.isEmpty {
                HStack {
                    Text("Mineralstoffe")
                        .font(.largeTitle)
                        .padding(.leading, 40)
                    Text("100g")
                    Spacer()
                }
                DictionaryInformationView(dictionary: consumption.minerals)
                    .padding(.horizontal, 30)
                Divider()
            }
            if !consumption.others.isEmpty {
                HStack {
                    Text("Weiteres")
                        .font(.largeTitle)
                        .padding(.leading, 40)
                    Text("100g")
                    Spacer()
                }
                DictionaryInformationView(dictionary: consumption.others)
                    .padding(.horizontal, 30)
            }
        }
    }
    
    private func calculateAmount(_ input: Double) -> Double {
        switch pickerSelection {
        case .portion:
            return (input * 50) / 100
        case .normalPortion:
            return input
        case .bigPortion:
            return 5 * input
        case .gramms:
            return input / 100
        case .kg:
            return input * 10
        }
    }
    
    private func updateCurrentValues() {
        let filtered = amount.filter { $0.isNumber }
        consumption.amount = calculateAmount(Double(filtered) ?? 0)
        amount = filtered
    }
    
    private func saveButtonAction() {
        
        self.daySummary.saveConsumption(consumption)
        
        // Save Animation abspielen und View verstecken
        self.saveAnimation.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2,
              execute: {
                self.displayBorder.toggle()
                self.displayCheckmark.toggle()
                self.saveAnimation.toggle()
                withAnimation {
                    self.navigator.setCurrentView(to: .main)
                }
              })
    }
    
    private func calculateRating(user: User) {
        let config = MLModelConfiguration()
        do {
            let model = try ValeoMLModel(configuration: config)
            let mlInput = ValeoMLModelInput.init(gender: user.gender, birth: user.birth,
                                                 weight: Double(user.weight), size: Double(user.size),
                                                 bmi: user.bmi, waist: Double(user.waist ?? -1),
                                                 bodyfat: "\(String(describing: user.bodyFat))",
                                                 calorieGoal: user.calorieGoal,
                                                 name: consumption.consumption?.name ?? "",
                                                 calories: Double(consumption.consumption?.calories ?? 0),
                                                 total_fat: consumption.consumption?.total_fat ?? 0,
                                                 saturated_fat: consumption.consumption?.saturated_fat ?? 0,
                                                 protein: consumption.consumption?.protein ?? 0,
                                                 carbohydrate: consumption.consumption?.carbohydrate ?? 0,
                                                 sugars: consumption.consumption?.sugars ?? 0,
                                                 serving_size: consumption.consumption?.serving_size ?? 0,
                                                 created: consumption.consumption?.created ?? "",
                                                 amount: consumption.amount,
                                                 meal: consumption.consumption?.meal ?? "")
            let prediction = try model.prediction(input: mlInput)
            self.mlRating = prediction.Record_Count
        } catch {
            return
        }
    }
    
    private func getRatingEmoji() -> String {
        if mlRating < 1 {
            return "😡"
        } else if mlRating < 3 {
            return "😣"
        } else if mlRating < 5 {
            return "🙁"
        } else if mlRating < 7 {
            return "😐"
        } else if mlRating < 9 {
            return "😃"
        } else {
            return "😍"
        }
    }
    
    var pickerTitleView: some View {
        
        Text(self.pickerSelection.id)
            .frame(width: 200, height: 34, alignment: .center)
        
    }
}

struct NutrientView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            NavigationView {
//                NutrientView(consumption: ConsumptionVM(consumption: Consumption(consumptionId: UUID(),
//                        userId: "myUserId", created: "2020-01-01",
//                        nutrientId: UUID.init(uuidString: "00073C1B-131D-4304-9A84-7D5B312353D4")!,
//                        name: "Apfel", calories: 52, total_fat: 0.2, saturated_fat: 0.1,
//                        protein: 0.3, carbohydrate: 13.8, sugars: 10.0, serving_size: 100,
//                        amount: 1, meal: MealType.breakfast.rawValue)))
//                    .navigationBarTitle("Test", displayMode: .inline)
//                    .environmentObject(Navigator())
//                    .environmentObject(DaySummaryVM())
//            }
            
            DictionaryInformationView(dictionary: ["key1":"1","key2":"2","key3":"3","key4":"4","key5":"5"])
        }
    }
}

struct InformationRow: View {
    
    var text: String
    var value: String
    
    
    var body: some View {
        
        HStack {
            Text(text)
                .font(.headline)
            
            Spacer()
            
            Text(value)
        }
        
    }
    
}

struct DictionaryInformationView: View {
    
    @State var dictionary: [String:Any]
        
    var body: some View {
        VStack {
            ForEach(Array(dictionary.keys).sorted(), id: \.self){ x in
                InformationRow(text: "\(x)", value: "\(dictionary[x]!)")
            }
            
        }
    }
}

enum AmountSizes: String, CaseIterable, Identifiable {
    case portion
    case normalPortion
    case bigPortion = "große Portion (500g)"
    case gramms = "g"
    case kg = "kg"
    
    var id: String {
        switch self.self {
        case .portion:
            return "kleine Portion (50g)"
        case .normalPortion:
            return "100g"
        case .bigPortion:
            return "große Portion (500g)"
        case .gramms:
            return "g"
        case .kg:
            return "kg"
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
