//
//  UserMutable.swift
//  Valeo
//
//  Created by Lori Hill on 16.01.21.
//

import Foundation

public struct UserMutable: Codable, Equatable {
    
    /// date mutating information where saved
    var created: String
    /// weight in gramm
    var weight: Int
    /// size in cm
    var size: Int
    /// BMI by official formular
    var bmi: Double
    /// optional measure of waist size
    var waist: Int?
    /// optional measurement of body fat
    var bodyFat: Double?
    /// current goal for daily calorie intake
    var calorieGoal: Double
    
}
