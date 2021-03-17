//
//  IntroductionViewManager.swift
//  Valeo
//
//  Created by Lori Hill on 02.03.21.
//

import SwiftUI

struct IntroductionViewManager: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var navigator: Navigator
    @State var currentPage = 0
    let highestIntroductionView = 6
    @AppStorage("showedIntroduction") var showedIntroduction: Bool = false
    
    @State var animation = false
    @State var hasPlayedCircleAnimation = false
    var calorieText = "675 kcal übrig"
    
    let width = UIScreen.main.bounds.size.width
    @State var isExtended = true
    
    @State var nutrientList: [ConsumptionViewModel] = []
    @State var anamnesisClicked = false
        
    var body: some View {
        ZStack {
            
            if currentPage == 0 {
                IntroductionSubView(headLine: "Hallo \(user.name)",
                                    explanation: "Lerne hier die Funktionen der App kennen.",
                                    showsView: false, content: {Text("")}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 144/255, green: 238/255, blue: 144/255, opacity: 0.8))
                    .transition(.opacity)
            }
            if currentPage == 1 {
                IntroductionSubView(headLine: "Kalorientracker",
                                    explanation: "Halte hiermit deine übrigen Kalorien im Überblick.",
                                    showsView: true, content: {ringProgress}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 152/255, green: 251/255, blue: 152/255, opacity: 0.8))
                    .onAppear(perform: {
                        if self.animation {
                            self.hasPlayedCircleAnimation = true
                        } else {
                            self.animation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                                self.hasPlayedCircleAnimation = true
                            })
                        }
                    })
                    .onDisappear {
                        self.animation = false
                        self.hasPlayedCircleAnimation = false}
                    .transition(.opacity)
            }
            if currentPage == 2 {
                IntroductionSubView(headLine: "Mahlzeitenübersicht",
                                    explanation: "Sieh, was du gegessen hast.\nMit dem + kannst du neue Nahrungsmittel suchen.\nWenn du ein Element nach links swipest, kannst du es löschen.",
                                    showsView: true, content: {nutrientTable}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 0, green: 1, blue: 154/255, opacity: 0.8))
                    .onAppear {
                        if self.nutrientList.isEmpty {
                            setUpConsumptionList()
                        }
                    }
                    .transition(.opacity)
            }
            if currentPage == 3 {
                IntroductionSubView(headLine: "Anamnese",
                                    explanation: "Hier kannst du täglich deine Anamnese machen.\nDiese hilft uns zusammen mit deinen kosumierten Lebensmitteln herauszufinden, was du gut verträgst.\nMit diesen Informationen können wir dir helfen gesund und fit zu werden und bleiben.",
                                    showsView: true, content: {anamnesePreview}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 46/255, green: 139/255, blue: 87/255, opacity: 0.8))
                    .transition(.opacity)
            }
            if currentPage == 4 {
                IntroductionSubView(headLine: "KI Bewertung (Beta)",
                                    explanation: "Der Smiley bei einem Lebensmittel zeigt dir an, wie gut unsere KI das Lebensmittel für dich hält.\nDiese Bewertung ist komplett individuell und nur auf deinem Gerät für dich sichtbar.\n",
                                    showsView: true, content: {aiPreview}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 46/255, green: 139/255, blue: 87/255, opacity: 0.8))
                    .transition(.opacity)
            }
            if currentPage == 5 {
                IntroductionSubView(headLine: "",
                                    explanation: "",
                                    showsView: true, content: {DisclaimerView()}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 60/255, green: 179/255, blue: 113/255, opacity: 0.8))
                    .transition(.opacity)
            }
            if currentPage == 6 {
                IntroductionSubView(headLine: "Das wars auch schon",
                                    explanation: "Viel Spaß und Erfolg wünschen wir dir mit Valeo.",
                                    showsView: false, content: {Text("")}, pageBinding: $currentPage,
                                    color: Color(.sRGB, red: 60/255, green: 179/255, blue: 113/255, opacity: 0.8))
                    .transition(.opacity)
            }
            
            
        }
        .overlay(
            Button(action: {
                    withAnimation(.easeInOut){
                        if self.currentPage < self.highestIntroductionView {
                            self.currentPage += 1
                        } else {
                            showedIntroduction = true
                            self.navigator.showedIntroduction = true
                        }
                        
                    }}, label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 60, height: 60, alignment: .center)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.04),
                                        lineWidth: 2)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage)/CGFloat(highestIntroductionView))
                                .stroke(Color.white, lineWidth: 4)
                                .rotationEffect(.init(degrees: -90))
                        }
                        .padding(-15))
                
            })
            .padding(.bottom, 20)
            , alignment: .bottom
        )
        .background(Color.white.ignoresSafeArea())
    }
    
    var ringProgress: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.5),
                        style: StrokeStyle(lineWidth: 10))
            
            Circle()
                .trim(from: 0, to: self.animation ? 0.6 : 0)
                .stroke(Color.white,
                        style: StrokeStyle(lineWidth: 10,
                                           lineCap: .round,
                                           lineJoin: .round,
                                           miterLimit: .infinity,
                                           dash: [20 , 0],
                                           dashPhase: 0))
                .rotationEffect(Angle(degrees: -90))
                .shadow(color: .white, radius: 10)
                .animation(self.hasPlayedCircleAnimation ? .none : .easeInOut(duration: 1.5))
                
            
            Text(self.calorieText)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.black)
        }
        .frame(width: UIScreen.main.bounds.size.width * 0.5,
               height: UIScreen.main.bounds.size.width * 0.5,
               alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
    var nutrientTable: some View {
        ZStack {
            // List of nutrients of displayed meal
            VStack(spacing: 0) {
                Spacer()
                    .frame(width: width, height: 75, alignment: .center)
                
                if self.isExtended {
                    ForEach(self.nutrientList) { x in
                        if x.consumption != nil {
                            NutrientCell(consumption: x, deleteItem: self.delete(_:), showsToday: .constant(true))
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
                                .foregroundColor(self.colorScheme == .light ? Color.white : Color(.systemGray3)))
            .animation(.easeInOut)
            
            VStack(spacing: 0) {
                HStack {
                    Text(MealType.breakfast.rawValue)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .padding(.trailing, 20)
                    }
                }
                .padding()
                .onTapGesture {
                    withAnimation(.easeOut) {
                        isExtended.toggle()
                    }
                }
                .background(RoundedRectangle(cornerRadius: 25.0)
                                .foregroundColor(Color.black)
                                .onTapGesture {
                                    withAnimation(.easeOut) {
                                        isExtended.toggle()
                                    }
                            })
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
    
    var aiPreview: some View {
        VStack(spacing:0) {
            HStack {
                Text("Apfel")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)
            .background(Color(.systemGray))
            
            HStack {
                Spacer()
                Text("250")
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                    .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray4), lineWidth: 0.5))
                
                Text("g")
                    .padding(.vertical, 5)
                    .padding(.horizontal, 50)
                    .foregroundColor(.black)
                    .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray4), lineWidth: 0.5))
                Spacer()
            }
            .padding(.vertical)
            Text("Hinzufügen")
                .foregroundColor(.black)
                .frame(width: width * 0.7)
                .padding()
                .background(Color.green)
                .clipShape(Capsule())
                .padding(.horizontal)
            
            HStack {
                Text("142 kcal")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.trailing, 40)
                
                Text("😃")
                    .font(.title)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.white)
        .frame(width: width * 0.9)
    }
    
    var anamnesePreview: some View {
        Button(action: {self.anamnesisClicked.toggle()}, label: {
            Text(self.anamnesisClicked ? "Anamnese ✅" : "Anamnese")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .background(Capsule().foregroundColor(self.anamnesisClicked ? Color.black : Color.red))
                .padding(.horizontal, 15)
        })
    }
    
    private func delete(_ consumption: ConsumptionViewModel) {
        guard let id = consumption.consumption?.consumptionId else {
            return
        }
        self.nutrientList.removeAll { (cvm) -> Bool in
            cvm.consumption?.consumptionId == id
        }
    }
    
    private func getHeight() -> CGFloat {
        
        let bar = 75
        let rowHeight = 50 * self.nutrientList.count
        let bottomPadding = 20
        
        return CGFloat(bar + rowHeight + bottomPadding)
        
    }
    
    private func setUpConsumptionList() {
        
        let names = ["Jogurt", "Apfel"]
        
        for x in names {
            let consumption = ConsumptionViewModel(consumption: Consumption(consumptionId: UUID(), userId: "", created: "", nutrientId: UUID(), name: x, calories: 123, total_fat: 0, saturated_fat: 0, protein: 0, carbohydrate: 0, sugars: 0, serving_size: 100, amount: 0.3, meal: ""))
            self.nutrientList.append(consumption)
        }
    }
}

struct IntroductionViewManager_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IntroductionViewManager()
                .environmentObject(UserViewModel())
                .environmentObject(Navigator())
            
            DisclaimerView()
        }
    }
}


struct DisclaimerView: View {
    
    let text1 = "Diese App ist Teil einer Studie und wird in Zukunft weiterentwickelt und verbessert.\n"
    let text2 = "Aktuell ist lediglich eine englische Datenbank für die Nahrungsmittel vorhanden!\n"
    let text3 = "Medizinische Korrektheit kann und wird bisher nicht gewährleistet."
    
    var body: some View {
        
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .renderingMode(.original)
                .font(.system(size: 100))
            
            Text("Disclaimer")
                .foregroundColor(.black)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .kerning(1.4)
            
            
            Text(text1 + text2 + text3)
                .foregroundColor(.black)
                .font(.body)
                .fontWeight(.semibold)
                .kerning(1.4)
                .padding(.top, 10)
                .padding(.horizontal, 15)
        }
        
    }
}
