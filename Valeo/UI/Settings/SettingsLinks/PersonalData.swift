//
//  PersonalData.swift
//  Valeo
//
//  Created by Lori Hill on 10.01.21.
//

import SwiftUI

struct PersonalData: View {
    
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var navigator: Navigator
    @State var weight = 0
    @State var size = 0
    @State var calorieGoal = 0
    @State var waist = 0
    @State var bodyFat = 0
    
    var body: some View {
        List {
            Section(header: Text("Unveränderliche Informationen")) {
                HStack {
                    Text("Name")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(user.name)
                }
                
                HStack {
                    Text("Geburtsdatum")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.user.birth)
                }
                
                HStack {
                    Text("Geschlecht")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.getGenderText())
                }
            }
            
            Section(header: Text("Weitere Informationen")) {
                HStack {
                    Text("Gewicht")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.user.weight)
                }                
                // MARK: self.$number muss auf user angepasst werden bzw. der Datenflow muss irgendwie geregelt werden. Im optimalfall erst den Wert von user in number laden, und beim speichern diesen Wert in user.userFromDefaults über eine Methode in User ändern. So, dass gleichzeitig auf Firebase über die Änderung informaiert wird.
                .contentShape(Rectangle())
                .onTapGesture {
                    self.navigator.popUpView =
                        PopUpViewContainer(content:
                                            NumberStepper(typeToChange: .weight,text: "Gewicht"))
                    self.navigator.showPopUpView = true
                }
                
                HStack {
                    Text("Größe")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.user.size)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.navigator.popUpView =
                        PopUpViewContainer(content:
                                            NumberStepper(typeToChange: .size,text: "Größe"))
                    self.navigator.showPopUpView = true
                }
                
                HStack {
                    Text("Kalorienziel")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.user.calorieGoal)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.navigator.popUpView =
                        PopUpViewContainer(content:
                                            NumberStepper(typeToChange: .calorieGoal,text: "Kalorienziel"))
                    self.navigator.showPopUpView = true
                }
                
                HStack {
                    Text("Taillenumfang")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.user.waist)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.navigator.popUpView =
                        PopUpViewContainer(content:
                                            NumberStepper(typeToChange: .waist,text: "Taillenumfang"))
                    self.navigator.showPopUpView = true
                }
                
                HStack {
                    Text("Körperfettanteil")
                        .font(.title3)
                    Spacer(minLength: 0)
                    Text(self.user.bodyFat)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.navigator.popUpView =
                        PopUpViewContainer(content:
                                            NumberStepper(typeToChange: .bodyfat,text: "Körperfettanteil"))
                    self.navigator.showPopUpView = true
                }
                
                VStack {
                    HStack {
                        Text("Die Berechnung des Kalorienziels erfolgt unter Verwendung der Harris-Benedict-Formel.\n" +
                            "Diese ist eine allgemein verwendete Formel zur Berechnung des Kalorienziels.")
                            .font(.caption)
                    }
                    .frame(width: UIScreen.main.bounds.size.width * 0.9,
                           alignment: .center)
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://de.wikipedia.org/wiki/Grundumsatz")!)
                    }, label: {
                        HStack {
                            Text("Mehr")
                                .padding(.leading, 10)
                                .font(.body)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    })
                    .frame(width: UIScreen.main.bounds.size.width * 0.9,
                           alignment: .center)
                }.padding(.top, 25)
                
                
            }
        }
        .navigationBarTitle("Persönliche Daten", displayMode: .inline)
    }
    
    private func getGenderText() -> String {
        if user.gender == "male" {
            return "Mann"
        }  else if user.gender == "female" {
            return "Frau"
        }else {
            return "Divers"
        }
    }
    
//    private func saveChanges() {
//        print("Save")
//        let result = self.user.updateMutableValues(weight: self.weight, size: self.size, waist: self.waist, bodyFat: Double(self.bodyFat))
//
//        print(result)
//
//    }
    
}

struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData()
            .environmentObject(UserViewModel())    }
}
