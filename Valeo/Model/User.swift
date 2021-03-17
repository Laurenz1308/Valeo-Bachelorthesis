//
//  User.swift
//  Valeo
//
//  Created by Lori Hill on 11.01.21.
//

import Foundation

/// The struct of a user with equivalent data types like in the DB.
/// This struct conforms to the Codable protocol in order to be stored in UserDefaults easily.
public struct User: Codable, Equatable {
    
    // Persistent Information
    /// ID to identify user data, created by Fireabse, when signing up
    let userId: String
    /// just to personalize the UX
    let name: String
    /// ISO-8601 in yyyy-mm-dd
    let birth: String
    /// male, female, divers testosteron dominant, divers estrogen dominant
    let gender: String
    
    // Mutating Values
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
    
    public init() {
        self.userId = "0"
        self.name = "undefined"
        self.birth = "1990-01-01"
        self.gender = "divers"
        self.created = "1900-01-01"
        self.weight = 0
        self.size = 0
        self.bmi = 0
        self.waist = 0
        self.bodyFat = 0
        self.calorieGoal = 0
    }
    
    init(userId: String, name: String, birth: String, gender: String,
         created: String, weight: Int, size: Int, bmi: Double,
         waist: Int?, bodyFat: Double?, calorieGoal: Double) {
        self.userId = userId
        self.name = name
        self.birth = birth
        self.gender = gender
        self.created = created
        self.weight = weight
        self.size = size
        self.bmi = bmi
        self.waist = waist
        self.bodyFat = bodyFat
        self.calorieGoal = calorieGoal
    }
    
    ///
    /// Gets User from defaults by key "user".
    ///
    /// - returns: User frrom defaults in case there is one and it could be encoded, otherwise nil
    ///
//    public func loadFromDefaults() -> User? {
//        var defaultsUser: User?
//        let defaults = UserDefaults.standard
//        let loaded = defaults.data(forKey: "user") ?? Data()
//        let decoder = JSONDecoder()
//        if let decoded = try? decoder.decode(User.self, from: loaded) {
//            defaultsUser = decoded
//        }
//
//        return defaultsUser
//    }
    
    ///
    /// Saves the user to defaults with key "user".
    ///
    /// - returns: true if user was saved successfully, otherwise false
    ///
    public func safeToDefaults() -> Bool {
        let encoder = JSONEncoder()
        do {
            let encodedUser = try encoder.encode(self)
            let defaults = UserDefaults.standard
            defaults.set(encodedUser, forKey: "user")
            guard let savedUser = defaults.data(forKey: "user"), savedUser == encodedUser else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case userId
        case name
        case birth
        case gender
        case created
        case weight
        case size
        case bmi
        case waist
        case bodyFat
        case calorieGoal
    }
    
}
