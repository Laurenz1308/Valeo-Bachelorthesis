//
//  ConsumptionRepository.swift
//  Valeo
//
//  Created by Lori Hill on 15.02.21.
//

import Foundation
import Firebase

/// Manages the data flow with Firebase.
final class ConsumptionRepository: ObservableObject {
    
    @Published var consumption: Consumption?
    
    @Published var vitamines: [String: Any] = [:]
    
    @Published var minerals: [String: Any] = [:]
    
    @Published var others: [String: Any] = [:]
    
    let firestore = Firestore.firestore()
    
    init(_ consumption: Consumption) {
        self.consumption = consumption
    }
    
    init(by nutrientId: UUID, mealType: MealType) {
        getByNutrientId(nutrientId, mealtype: mealType)
    }
    
    init(with nutrient: NutrientBase, mealType: MealType) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not logged")
            return
        }
        
        let iso = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withFullDate, .withFullTime])
        
        self.consumption = Consumption(consumptionId: UUID(),
                                       userId: uid,
                                       created: iso,
                                       nutrientId: nutrient.nutrientId,
                                       name: nutrient.name,
                                       calories: nutrient.calories,
                                       total_fat: nutrient.total_fat,
                                       saturated_fat: nutrient.saturated_fat,
                                       protein: nutrient.protein,
                                       carbohydrate: nutrient.carbohydrate,
                                       sugars: nutrient.sugars,
                                       serving_size: nutrient.serving_size,
                                       amount: 1,
                                       meal: mealType.rawValue)
    }
    
    /// Update an existing consumption of the current user by id of the consumption.
    func update(_ consumption: Consumption) {
        
        if consumption != self.consumption && consumption.consumptionId == self.consumption?.consumptionId {
            let docRef = firestore
                .collection(FirestoreCollections.consumptionCollection)
                .document(consumption.consumptionId.uuidString)
            
            do {
                try docRef.setData(from: consumption, completion: { (error) in
                    if error != nil {
                        print("Upload of consumption \(consumption.consumptionId) failed")
                        return
                    }
                })
            } catch {
                print(error.localizedDescription)
                print("Decoding failed")
                return
            }
            
        }
        
    }
    
    /// Delete consumption
    func delete() {
        
        guard let consumption = self.consumption else {
            print("Nothing to delete")
            return
        }
        
        let docRef = firestore
            .collection(FirestoreCollections.consumptionCollection)
            .document(consumption.consumptionId.uuidString)
        
        docRef.delete()
    }
    
    /// Get al Vitamines, Minderals and other information of the nutrient of the consumption.
    func getFurtherInformationOfNutrient() {
        
        guard self.consumption != nil else {
            print("No consumption found")
            return
        }
        
        getVitamines()
        getMinerals()
        getOthers()
    }
    
    private func getVitamines() {
        let docRef = firestore
            .collection(FirestoreCollections.nutrientCollection)
            .document(self.consumption!.nutrientId.uuidString)
            .collection(FirestoreCollections.nutrientDetailCollection)
            .document(FirestoreCollections.nutrientDetailedVitamineDocument)
        
        docRef.getDocument { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let result = snapshot?.data() else {
                print("Nothing received")
                return
            }
            self.vitamines = result
        }
    }
    
    private func getMinerals() {
        let docRef = firestore
            .collection(FirestoreCollections.nutrientCollection)
            .document(self.consumption!.nutrientId.uuidString)
            .collection(FirestoreCollections.nutrientDetailCollection)
            .document(FirestoreCollections.nutrientDetailedMineralDocument)
        
        docRef.getDocument { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let result = snapshot?.data() else {
                print("Nothing received")
                return
            }
            self.minerals = result
        }
    }
    
    private func getOthers() {
        let docRef = firestore
            .collection(FirestoreCollections.nutrientCollection)
            .document(self.consumption!.nutrientId.uuidString)
            .collection(FirestoreCollections.nutrientDetailCollection)
            .document(FirestoreCollections.nutrientDetailedOthersDocument)
        
        docRef.getDocument { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let result = snapshot?.data() else {
                print("Nothing received")
                return
            }
            self.others = result
        }
    }
    
    /// Create a new consumption by using the id of the nutrient.
    /// But it isn't uploaded to Firebase.
    private func getByNutrientId(_ id: UUID, mealtype: MealType) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not logged in")
            return
        }
        
        // Get nutrient
        let docRef = firestore
            .collection(FirestoreCollections.nutrientCollection)
            .document(id.uuidString)
        
        docRef.getDocument { (snapshot, error) in
            if error != nil {
                print("FetchRequest failed")
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot")
                return
            }
            
            do {
                let decodedNutrient = try snapshot.data(as: NutrientBase.self)
                
                guard let nutrient = decodedNutrient else {
                    print("Decoded nutrient is nil")
                    return
                }
                
                // Create new Consumption
                let createdISO = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withFullDate, .withFullDate])
                
                let consumption = Consumption(consumptionId: UUID(),
                                              userId: uid,
                                              created: createdISO,
                                              nutrientId: nutrient.nutrientId,
                                              name: nutrient.name,
                                              calories: nutrient.calories,
                                              total_fat: nutrient.total_fat,
                                              saturated_fat: nutrient.saturated_fat,
                                              protein: nutrient.protein,
                                              carbohydrate: nutrient.carbohydrate,
                                              sugars: nutrient.sugars,
                                              serving_size: nutrient.serving_size,
                                              amount: 1,
                                              meal: mealtype.rawValue)
                // set new consumption as self
                self.consumption = consumption
            } catch {
                print("decoding snapshot failed")
                return
            }
            
        }
    }
}
