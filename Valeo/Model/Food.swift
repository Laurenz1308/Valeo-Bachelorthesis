//
//  Food.swift
//  Valeo
//
//  Created by Laurenz Hill on 23.11.20.
//

import SwiftUI
import Firebase

struct Food: Codable {
    
    var id: Int
    var name: String
    var calories: Int
    var total_fat: String
    var saturated_fat: String
    var protein: String
    var carbohydrate: String
    var sugars: String
    var serving_size: String
    
    var cholesterol: String
    var sodium: String
    var choline: String
    var folate: String
    var folic_acid: String
    var niacin: String
    var pantothenic_acid: String
    var riboflavin: String
    var thiamin: String
    var vitamin_a: String
    var vitamin_a_rae: String
    var carotene_alpha: String
    var carotene_beta: String
    var cryptoxanthin_beta: String
    var lutein_zeaxanthin: String
    var lucopene: String
    var vitamin_b12: String
    var vitamin_b6: String
    var vitamin_c: String
    var vitamin_d: String
    var vitamin_e: String
    var tocopherol_alpha: String
    var vitamin_k: String
    var calcium: String
    var copper: String
    var iron: String
    var magnesium: String
    var manganese: String
    var phosphorous: String
    var potassium: String
    var selenium: String
    var zink: String
    var alanine: String
    var arginine: String
    var aspartic_acid: String
    var cystine: String
    var glutamic_acid: String
    var glycine: String
    var histidine: String
    var hydroxyproline: String
    var isoleucine: String
    var leucine: String
    var lysine: String
    var methionine: String
    var phenylalanine: String
    var proline: String
    var serine: String
    var threonine: String
    var tryptophan: String
    var tyrosine: String
    var valine: String
    var fiber: String
    var fructose: String
    var galactose: String
    var glucose: String
    var lactose: String
    var maltose: String
    var sucrose: String
    var fat: String
    var saturated_fatty_acids: String
    var monounsaturated_fatty_acids: String
    var polyunsaturated_fatty_acids: String
    var fatty_acids_total_trans: String
    var alcohol: String
    var ash: String
    var caffeine: String
    var theobromine: String
    var water: String

    func uploadFood() {
        let db = Firestore.firestore()
        
        let id = UUID().uuidString
        
        let data = getUploadData(id: id)
        
        db.collection("food").document(id).setData(data) { (error) in
            if error != nil {
                print("Failed creating doc \(id)")
                print(error!)
                return
            } else {
                print("Successfully created doc \(id)")
                let detailedData = getSubcollection()
                db.collection("food").document(id).collection("detailed").document("detail").setData(detailedData) { (error) in
                    if error != nil {
                        print("Failed creating detailed Information for doc \(id)")
                        print(error!)
                        return
                    } else {
                        print("Successfully created detailed Information for doc \(id)")
                        return
                    }
                }
            }
        }
        
    }
    
    func getUploadData(id: String) -> [String:Any] {
        
        let data: [String:Any] = [
            "id" : id,
            "name": self.name,
            "calories": self.calories,
            "carbohydrate": self.carbohydrate,
            "sugars" : self.sugars,
            "total_fat" : self.total_fat,
            "sturated_fat" : self.saturated_fat,
            "protein" : self.protein,
            "serving_size": self.serving_size
        ]
        
        return data
    }
    
    func getSubcollection() -> [String: Any] {
        
        var result: [String:Any] = [:]
        
        let mirror = Mirror(reflecting: self)
        
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }

            if label != "name" && label != "id" && label != "calories" &&
                label != "carbohydrate" && label != "sugars" && label != "total_fat" &&
                label != "sturated_fat" && label != "protein" && label != "serving_size" {

                result[label] = valueMaybe

            }
        }
        
        return result
    }
    
}
