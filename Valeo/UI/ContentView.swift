//
//  ContentView.swift
//  Valeo
//
//  Created by Lori Hill on 19.11.20.
//

import SwiftUI
import Firebase

/// View to Upload data from a JSON to Firebase. Not embedded into the main app, but can be used manualy for testing.
/// Could be used in App scene.
struct ContentView: View {
    
    @ObservedObject var nutrientModel = NutrientUploader()
    @State var tapped = false
        
    var body: some View {
        Text(nutrientModel.uploadStateString)
            .font(.largeTitle)
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(RoundedRectangle(cornerRadius: 20).foregroundColor(.green))
            .onTapGesture {
                if !tapped {
                    nutrientModel.uploadNutrientsFromJSON()
                    self.tapped = true
                }
            }
    }
    
    private func test() {
        if let path = Bundle.main.path(forResource: "nutrition", ofType: "json") {
            
//            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                
                let result = try JSONDecoder().decode([Food].self, from: data)
                
                for x in result {
                    x.uploadFood()
                }
                
            } catch {
                print("Error")
            }
        }
    }
    
    func testUploadQuestions() {
        
            
        let question1 = Question(index: 500, question: "My final question 500", answers: ["My final answer one", "My final answer two", "My final answer three"], nextQuestions: [0,0,0])
        
        let db = Firestore.firestore()
        do {
            try db.collection("questions").document(question1.id.uuidString).setData(from: question1)
            print("\(question1.id) successfully created")
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
