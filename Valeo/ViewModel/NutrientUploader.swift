//
//  NutrientVM.swift
//  Valeo
//
//  Created by Lori Hill on 22.01.21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class NutrientUploader: ObservableObject {
        
    @Published var uploadStateString = ""
    
    func uploadNutrientsFromJSON() {
        if let path = Bundle.main.path(forResource: "fullNutrientList", ofType: "json") {
            
//            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                
                let result = try JSONDecoder().decode([Food].self, from: data)
                
                for x in result {
                    
                    if x.id >= 4000 && x.id < 6000 {
                        uploadNutrient(food: x)
                    }
                }
                
            } catch {
                print("Error")
            }
        }
    }
    
    public func testUpload() {
        let db = Firestore.firestore()
        
        let docRef = db.collection("Test").document("meinTest")
        docRef.setData(["name":"fertig"]) { (error) in
            if error != nil {
                self.uploadStateString = error!.localizedDescription
                print(error!.localizedDescription)
            }
        }
    }
    
    private func uploadNutrient(food: Food) {

        let db = Firestore.firestore()
        
        let id = UUID().uuidString
        
        do {
            let data = try getUploadData(id: id, food: food)
            
            db.collection("nutrient").document(id).setData(data) { (error) in
                if error != nil {
                    print("Failed creating doc \(id)")
                    self.uploadStateString = "Failed creating doc \(id)"
                    print(error!)
                    return
                } else {
                    print("Successfully created doc \(id)")
                    self.uploadStateString = "Successfully created doc \(id)"
                    let vitamines = self.getSubcollectionDocVitamine(food: food)
                    db.collection("nutrient").document(id).collection("detailed").document("vitamines").setData(vitamines) { (error) in
                        if error != nil {
                            print("Failed creating vitamines for doc \(id)")
                            self.uploadStateString = "Failed creating vitamines for doc \(id)"
                            print(error!)
                            return
                        } else {
                            print("Successfully created vitamines for doc \(id)")
                            self.uploadStateString = "Successfully created vitamines for doc \(id)"
                            return
                        }
                    }
                    let minerals = self.getSubcollectionDocMinerals(food: food)
                    db.collection("nutrient").document(id).collection("detailed").document("minerals").setData(minerals) { (error) in
                        if error != nil {
                            print("Failed creating minerals for doc \(id)")
                            self.uploadStateString = "Failed creating minerals for doc \(id)"
                            print(error!)
                            return
                        } else {
                            print("Successfully created minerals for doc \(id)")
                            self.uploadStateString = "Successfully created minerals for doc \(id)"
                            return
                        }
                    }
                    let others = self.getSubcollectionDocOthers(food: food)
                    db.collection("nutrient").document(id).collection("detailed").document("others").setData(others) { (error) in
                        if error != nil {
                            print("Failed creating other information for doc \(id)")
                            self.uploadStateString = "Failed creating other information for doc \(id)"
                            print(error!)
                            return
                        } else {
                            print("Successfully created other Information for doc \(id)")
                            self.uploadStateString = "Successfully created other Information for doc \(id)"
                            return
                        }
                    }
                }
            }
        } catch {
            print("Error: \(id) could not be created")
        }
    }
    
    func getUploadData(id: String, food: Food) throws -> [String:Any] {
        
        let carbs = stringToDouble(string: food.carbohydrate)
        let sugars = stringToDouble(string: food.sugars)
        let total_fat = stringToDouble(string: food.total_fat)
        let saturated_fat = stringToDouble(string: food.saturated_fat)
        let protein = stringToDouble(string: food.protein)
        let serving_size = stringToDouble(string: food.serving_size)
        
        if carbs == nil || sugars == nil || total_fat == nil ||
            saturated_fat == nil || protein == nil || serving_size == nil {
            throw NSError()
        }
        
        let data: [String:Any] = [
            "nutrientId" : id,
            "name": food.name,
            "calories": food.calories,
            "carbohydrate": carbs!,
            "sugars" : sugars!,
            "total_fat" : total_fat!,
            "saturated_fat" : saturated_fat!,
            "protein" : protein!,
            "serving_size": serving_size!
        ]
        
        return data
    }
    
    func getSubcollectionDocVitamine(food: Food) -> [String: Any] {
        var result: [String:Any] = [:]
        let mirror = Mirror(reflecting: food)
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }
            if label == "vitamin_a" || label == "vitamin_a_rae" || label == "vitamin_b12" ||
                label == "vitamin_b6" || label == "vitamin_c" || label == "vitamin_d" ||
                label == "vitamin_e" || label == "vitamin_k" || label == "folate" || label == "folic_acid" ||
                label == "niacin" || label == "pantothenic_acid" || label == "riboflavin" || label == "thiamin" ||
                label == "tocopherol_alpha" {
                result[label] = valueMaybe
            }
        }
        
        return result
    }
    
    func getSubcollectionDocMinerals(food: Food) -> [String: Any] {
        var result: [String:Any] = [:]
        let mirror = Mirror(reflecting: food)
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }
            if label == "sodium" || label == "calcium" || label == "copper" ||
                label == "iron" || label == "magnesium" || label == "manganese" ||
                label == "phosphorous" || label == "potassium" || label == "zink" {
                result[label] = valueMaybe
            }
        }
        
        return result
    }
    
    func getSubcollectionDocOthers(food: Food) -> [String: Any] {
        var result: [String:Any] = [:]
        let mirror = Mirror(reflecting: food)
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }
            if label != "vitamin_a" && label != "vitamin_a_rae" && label != "vitamin_b12" &&
                label != "vitamin_b6" && label != "vitamin_c" && label != "vitamin_d" &&
                label != "vitamin_e" && label != "vitamin_k" && label != "folate" && label != "folic_acid" &&
                label != "niacin" && label != "pantothenic_acid" && label != "riboflavin" && label != "thiamin" &&
                label != "tocopherol_alpha" && label != "sodium" && label != "calcium" && label != "copper" &&
                label != "iron" && label != "magnesium" && label != "manganese" &&
                label != "phosphorous" && label != "potassium" && label != "id" && label != "name" && label != "calories" && label != "total_fat" && label != "saturated_fat" && label != "protein"
                && label != "carbohydrate" && label != "sugars" && label != "serving_size"{
                result[label] = valueMaybe
            }
        }
        
        return result
    }
    
    func getNutrient() {
        let db = Firestore.firestore()
        
        db.collection("nutrient").limit(to: 1).getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
            }
            
            let result = Result { try snapshot!.documents.first!.data(as: NutrientBase.self) }
            
            print(result)
            
        }
    }
    
    func stringToDouble(string: String) -> Double? {
        
        if !string.isEmpty {
            let index = string.firstIndex(of: "g") ?? string.endIndex
            let hasEmptySpace = string.firstIndex(of: " ") ?? index

            let beginning: String

            if hasEmptySpace < index {
                beginning = String(string[..<hasEmptySpace])
            } else {
                beginning = String(string[..<index])
            }

            return Double(beginning)
        } else {
            return 0.0
        }
    }
    
}
