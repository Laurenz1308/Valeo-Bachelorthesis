//
//  Consumption.swift
//  Valeo
//
//  Created by Lori Hill on 27.01.21.
//

import Foundation
import Firebase

struct Consumption: Codable, Equatable {
    
    let consumptionId: UUID
    let userId: String
    let created: String
    let nutrientId: UUID
    let name: String
    let calories: Int
    let total_fat: Double
    let saturated_fat: Double
    let protein: Double
    let carbohydrate: Double
    let sugars: Double
    let serving_size: Double
    
    var amount: Double
    let meal: String
    
    public static func loadFromFirestore() -> [Consumption] {
        
        let todayISOString =
            ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withFullDate])
        
        var returnArray: [Consumption] = []
        
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid
        
        let docRef = db.collection("daysummary")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: todayISOString)
        
        docRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                if snapshot != nil {
                    if !snapshot!.documents.isEmpty {
                        for document in snapshot!.documents {
                            do {
                                let foundConsumption = try document.data(as: Consumption.self)
                                if foundConsumption != nil {
                                    returnArray.append(foundConsumption!)
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
        
        
        return returnArray
    }
    
    public func saveToFirestore() {
        let db = Firestore.firestore()
        let docRef = db.collection("consumption").document(consumptionId.uuidString)
        
        do {
            try docRef.setData(from: self)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteFromFirestore() {
        let db = Firestore.firestore()
        let docRef = db.collection("consumption").document(consumptionId.uuidString)
        docRef.delete()
    }
}

