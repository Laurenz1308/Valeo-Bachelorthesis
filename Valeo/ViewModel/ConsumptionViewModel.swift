//
//  ConsumptionViewModel.swift
//  Valeo
//
//  Created by Lori Hill on 15.02.21.
//

import Foundation
import Combine

/// Organizes all data needed to display a nutrient.
final class ConsumptionViewModel: ObservableObject, Identifiable {
    
    private var consumptionRepository: ConsumptionRepository
    
    private var canellables: Set<AnyCancellable> = []
    
    let id = UUID()
    
    @Published var consumption: Consumption?
    
    @Published var amount = 1.0 {
        didSet {
            consumption?.amount = self.amount
        }
    }
    
    var calorieText: String {
        String(format: "%.0f", Double(consumption?.calories ?? 0) * amount) + " kcal"
    }
    
    var totalFatText: String {
        String(format: "%.2f", consumption?.total_fat ?? 0 * amount) + " g"
    }
    
    var saturatedFatText: String {
        String(format: "%.2f", consumption?.saturated_fat ?? 0 * amount) + " g"
    }
    
    var proteinText: String {
        String(format: "%.2f", Double(consumption?.protein ?? 0) * amount) + " g"
    }
    
    var carbohydrateText: String {
        String(format: "%.2f", Double(consumption?.carbohydrate ?? 0) * amount) + " g"
    }
    
    var sugarsText: String {
        String(format: "%.2f", Double(consumption?.sugars ?? 0) * amount) + " g"
    }
    
    var servingSizeText: String {
        String(format: "%.0f", Double(consumption?.serving_size ?? 0) * amount) + " g"
    }
    
    var totalText: String {
        getTotalConsumptionRepresentation()
    }
    
    @Published var vitamines: [String: Any] = [:]
    
    @Published var minerals: [String: Any] = [:]
    
    @Published var others: [String: Any] = [:]
        
    init(consumption: Consumption) {
        self.amount = consumption.amount
        self.consumptionRepository = ConsumptionRepository(consumption)
        
        consumptionRepository.$consumption
            .assign(to: \.consumption, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$vitamines
            .assign(to: \.vitamines, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$minerals
            .assign(to: \.minerals, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$others
            .assign(to: \.others, on: self)
            .store(in: &canellables)
        
    }
    
    init(by nutrientId: UUID, mealType: MealType) {
        self.consumptionRepository = ConsumptionRepository(by: nutrientId, mealType: mealType)
        
        consumptionRepository.$consumption
            .assign(to: \.consumption, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$vitamines
            .assign(to: \.vitamines, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$minerals
            .assign(to: \.minerals, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$others
            .assign(to: \.others, on: self)
            .store(in: &canellables)
    }
    
    init(with nutrient: NutrientBase, mealType: MealType) {
        self.consumptionRepository = ConsumptionRepository(with: nutrient, mealType: mealType)
        
        consumptionRepository.$consumption
            .assign(to: \.consumption, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$vitamines
            .assign(to: \.vitamines, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$minerals
            .assign(to: \.minerals, on: self)
            .store(in: &canellables)
        
        consumptionRepository.$others
            .assign(to: \.others, on: self)
            .store(in: &canellables)
    }
    
    func updateConsumption(new consumption: Consumption) {
        self.consumptionRepository.update(consumption)
    }
    
    func getFurtherInformation() {
        self.consumptionRepository.getFurtherInformationOfNutrient()
    }
    
    func deleteConsumption() {
        consumptionRepository.delete()
    }
    
    private func getTotalConsumptionRepresentation() -> String {
        
        guard let servingSize = self.consumption?.serving_size else {
            return ""
        }
        
        let totalAmount = servingSize * self.amount
        
        if totalAmount < 0 {
            return "\(String(format: "%.2f g", totalAmount))"
        } else  if totalAmount < 1000 {
            return "\(String(format: "%.0f g", totalAmount))"
        } else {
            return "\(String(format: "%.1f kg", totalAmount / 1000))"
        }
    }
    
}


extension ConsumptionViewModel: Equatable {
    static func == (lhs: ConsumptionViewModel, rhs: ConsumptionViewModel) -> Bool {
        lhs.consumption == rhs.consumption
    }
    
    
}
