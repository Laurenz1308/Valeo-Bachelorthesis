//
//  FoodBase.swift
//  Valeo
//
//  Created by Lori Hill on 22.01.21.
//

import Foundation

/// Data struct of the asic information of a nutrient.
struct NutrientBase: Codable, Equatable {
    
    static func == (lhs: NutrientBase, rhs: NutrientBase) -> Bool {
        return lhs.nutrientId == rhs.nutrientId
    }
    
    let nutrientId: UUID
    let name: String
    let calories: Int
    let total_fat: Double
    let saturated_fat: Double
    let protein: Double
    let carbohydrate: Double
    let sugars: Double
    let serving_size: Double
    
    // MARK: Optional könnten Dictionarys zu Vitaminen, Mineralstoffen und weiterem angezeigt werden.
    var vitamines: [String : Any]?
    var minerals: [String : Any]?
    var other: [String : Any]?
    
    enum CodingKeys: String, CodingKey {
        case nutrientId
        case name
        case calories
        case total_fat
        case saturated_fat
        case protein
        case carbohydrate
        case sugars
        case serving_size
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nutrientId = try container.decode(UUID.self, forKey: .nutrientId)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        total_fat = try container.decode(Double.self, forKey: .total_fat)
        saturated_fat = try container.decode(Double.self, forKey: .saturated_fat)
        protein = try container.decode(Double.self, forKey: .protein)
        carbohydrate = try container.decode(Double.self, forKey: .carbohydrate)
        sugars = try container.decode(Double.self, forKey: .sugars)
        serving_size = try container.decode(Double.self, forKey: .serving_size)
        
        vitamines = nil
        minerals = nil
        other = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nutrientId, forKey: .nutrientId)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(total_fat, forKey: .total_fat)
        try container.encode(saturated_fat, forKey: .saturated_fat)
        try container.encode(protein, forKey: .protein)
        try container.encode(carbohydrate, forKey: .carbohydrate)
        try container.encode(sugars, forKey: .sugars)
        try container.encode(serving_size, forKey: .serving_size)
    }
    
    
}
