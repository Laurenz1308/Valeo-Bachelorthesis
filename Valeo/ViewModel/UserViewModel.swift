//
//  UserViewModel.swift
//  Valeo
//
//  Created by Lori Hill on 11.02.21.
//

import Foundation
import Combine

final class UserViewModel: ObservableObject {
    
    @Published var userRepository = UserRepository()
    @Published var user: User?
    @Published var authenticationError = false
    @Published var mutableUserInfromations: [UserMutable] = []
    @Published var noUserFound = false
    @Published var hasAcceptedPrivacyPolicy = false
    @Published var showSurvey = false
    @Published var surveyLink = ""
    
    @Published var loading = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    // Persistent Information
    /// ID to identify user data, created by Fireabse, when signing up
    var id: String {
        user?.userId ?? ""
    }
    /// just to personalize the UX
    var name: String {
        user?.name ?? ""
    }
    /// ISO-8601 in yyyy-mm-dd
    var birth: String {
        prettyPrintDate(date: user?.birth ?? "1990-01-01")
    }
    /// male, female, divers testosteron dominant, divers estrogen dominant
    var gender: String {
        user?.gender ?? ""
    }
    
    var age: Int {
        self.getAgeInYears(birth: iso8601Converter(from: user?.birth ?? "1990-01-01") ?? Date())
    }
    
    // Mutating Values
    /// date mutating information where saved
    var date: String {
        user?.created.description ?? ""
    }
    /// weight in gramm
    var weight: String {
        user != nil ? "\(String(describing: user!.weight)) kg" : "---"
    }
    /// size in cm
    var size: String {
        user != nil ? "\(String(describing: user!.size)) cm" : "---"
    }
    /// BMI by official formular
    var bmi: Double {
        user?.bmi ?? 0.0
    }
    /// optional measure of waist size
    var waist: String {
        var result: String = "---"
        if user != nil && user?.waist != nil {
            result = "\(String(describing: user!.waist!)) cm"
        }
        return result
    }
    /// optional measurement of body fat
    var bodyFat: String {
        var result: String = "---"
        if user?.bodyFat != nil {
            result = String(format: "%.1f", user?.bodyFat ?? 0.0) + "%"
        }
        return result
    }
    /// current goal for daily calorie intake
    var calorieGoal: String {
        String(format: "%.0f", user?.calorieGoal ?? 0.0) + " kcal"
    }
    
    // Connect repository publishers to viewmodel publishers
    init() {
        userRepository.$user
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
        
        userRepository.$mutableUserInformation
            .assign(to: \.mutableUserInfromations, on: self)
            .store(in: &cancellables)
        
        userRepository.$noUserFound
            .assign(to: \.noUserFound, on: self)
            .store(in: &cancellables)
        
        userRepository.$authenticationError
            .assign(to: \.authenticationError, on: self)
            .store(in: &cancellables)
        
        userRepository.$loading
            .assign(to: \.loading, on: self)
            .store(in: &cancellables)
        
        userRepository.$hasAcceptedPrivacyPolicy
            .assign(to: \.hasAcceptedPrivacyPolicy, on: self)
            .store(in: &cancellables)
        
        userRepository.$showSurvey
            .assign(to: \.showSurvey, on: self)
            .store(in: &cancellables)
        
        userRepository.$surveyLink
            .assign(to: \.surveyLink, on: self)
            .store(in: &cancellables)
    }
    
    func getMutableUserInformation() {
        userRepository.getMutableUserData()
    }
    
    /// Create a new User and save it to Firebase, CoreData and Defaults.
    /// If the App hasn't been registered to Firebase a anonymous authentication will be made.
    /// With a valid anonymous authentication a new user will be added to Firestore.
    /// Afterwards the mutable values will be saved to a subcollection of the user in Firestore and will be saved locally on device with CoreData.
    /// At the end the new user will be stored in defaults and the userVM get's updated to the new user.
    ///
    /// - parameters name: name of the new user
    /// - parameters birth: birthday of the new user
    /// - parameters gender: gender of the new user
    /// - parameters weight: current weight of the new user, must be greater than 0
    /// - parameters size: current size of the new user, must be greater than 0
    /// - returns Bool?: If an error occures it returns Bool otherwise nil since the request is performed assymmetric
    func createNewUser(name: String, birth: Date, gender: Gender, weight: Int, size: Int) -> Bool? {
        
        // Check if Birthday is over 14 and under 99
        let calendar = Calendar(identifier: .gregorian)
        let youngestAgeUnsecure = calendar.date(byAdding: .year, value: -14, to: Date())
        let oldestAgeUnsecure = calendar.date(byAdding: .year, value: -100, to: Date())
        
        guard let youngestAge = youngestAgeUnsecure, let oldestAge = oldestAgeUnsecure else {
            print("Could not check age")
            return false
        }
        
        guard youngestAge > birth && birth > oldestAge && name != "" else {
            print("Person to young")
            return false
        }
        
        guard let id = userRepository.userId else {
            print("User not authenticated")
            self.authenticationError = true
            return false
        }
        
        let isoDateDay = ISO8601DateFormatter.string(from: birth, timeZone: TimeZone.current, formatOptions: [.withFullDate])
        let fullIso = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withFullTime, .withFullDate])
        
        let calculatedBMI = calculateBMI(weight: weight, size: size)
        let calculatedCalorieGoal = getCalorieGoal(birth: birth, gender: gender, weight: weight, size: size)
        let newUser = User(userId: id, name: name, birth: isoDateDay,
                           gender: gender.rawValue, created: fullIso, weight: weight,
                           size: size, bmi: calculatedBMI, waist: 0, bodyFat: 0,
                           calorieGoal: calculatedCalorieGoal)
        
        userRepository.createUser(newUser)
        return nil
    }
    
    /// Updates all mutable values of a user and saves changes.
    /// Changes will be saved in Firestore, CoreData and Defaults.
    ///
    /// - parameters weight:  new weight of user in case of change, must be greater than 0
    /// - parameters size: new size of user in case of change, must be greater than 0
    /// - parameters waist: new waist of user in case of change
    /// - parameters bodyFat: new bodyfat of user in case of change
    /// - returns: true in case of a successfull change of userinformation, false otherwise
    func updateUser(weight: Int?, size: Int?, waist: Int?, bodyFat: Double?, calorieGoal: Double?) {
                
        guard let user = self.user else {
            print("No current user aviable")
            // MARK: hanlde this error appropriatly
            return
        }
        
        // Setting up new user
        let todayISO = ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withFullDate])
        var modifyCalorieGoal = false
        
        var newUser = User(userId: user.userId, name: user.name,
                           birth: user.birth, gender: user.gender,
                           created: todayISO, weight: Int(user.weight),
                           size: Int(user.size), bmi: user.bmi,
                           waist: Int(user.waist ?? 0), bodyFat: user.bodyFat,
                           calorieGoal: user.calorieGoal)
        
        if weight != nil {
            newUser.weight = weight!
            modifyCalorieGoal = true
        }
        if size != nil {
            newUser.size = size!
            modifyCalorieGoal = true
        }
        
        if waist != nil {
            newUser.waist = waist
        }
        if bodyFat != nil {
            newUser.bodyFat = bodyFat!
        }
        
        if calorieGoal == nil && modifyCalorieGoal {
            newUser.calorieGoal = getCalorieGoal(birth: iso8601Converter(from: newUser.birth) ?? Date(),
                                                 gender: Gender(rawValue: newUser.gender) ?? .male,
                                                 weight: newUser.weight, size: newUser.size)
        } else {
            newUser.calorieGoal = calorieGoal!
        }
        
        newUser.bmi = calculateBMI(weight: newUser.weight, size: newUser.size)
        
        // Check if actual changes have been made
        if newUser != user {
            
            let mutabelUserInformation = UserMutable(created: newUser.created,
                                                     weight: newUser.weight,
                                                     size: newUser.size,
                                                     bmi: newUser.bmi,
                                                     waist: newUser.waist,
                                                     bodyFat: newUser.bodyFat,
                                                     calorieGoal: newUser.calorieGoal)
            
            // Save new userinformation
            userRepository.updateUser(newUser, mutabelUserInformation)
        }
    }
    
    
    
    private func calculateBMI(weight: Int, size: Int) -> Double {
        
        if size > 0 {
            let sizeInm = size / 100
            let resultBmi = Double(weight) / Double(sizeInm^2)
            return resultBmi
        } else {
            return 0.0
        }
    }
    
    /// Calculating basic energy consumption of a person by using the Harris-Benedict-Equation.
    public func getCalorieGoal(birth: Date, gender: Gender, weight: Int, size: Int) -> Double {
        
        let age = self.getAgeInYears(birth: birth)
        let weightInKg = weight
        
        if gender == .male {
            let formular1: Double = 13.7 * Double(weightInKg)
            let formular2: Double = Double(5 * size)
            let formular3: Double = 6.8 * Double(age)
            let maleBaseEnergyConsumption = 66.47 + formular1 + formular2 - formular3
            return maleBaseEnergyConsumption
        } else if gender == .female {
            let formular1: Double = 9.6 * Double(weightInKg)
            let formular2: Double = 1.8 * Double(size)
            let formular3: Double = 4.7 * Double(age)
            let femaleBaseEnergyConsumption = 655.1 + formular1 + formular2 - formular3
            return femaleBaseEnergyConsumption
        } else {
            let formular1: Double = 13.7 * Double(weightInKg)
            let formular2: Double = Double(5 * size)
            let formular3: Double = 6.8 * Double(age)
            let maleBaseEnergyConsumption = 66.47 + formular1 + formular2 - formular3
            return maleBaseEnergyConsumption
        }
    }
    
    private func getAgeInYears(birth: Date) -> Int {
        let birthDate = birth
        let today = Date()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthDate, to: today)

        return components.year!
    }
    
    private func iso8601Converter(from string: String) -> Date? {
        let isoFromatter = DateFormatter()
        isoFromatter.dateFormat = "yyyy-MM-dd"
        let fromatedDate = isoFromatter.date(from: string)
        
        return fromatedDate
    }
    
    // If possible the date will be converted to a normal german date output.
    // Otherwise the date string of the user will be used.
    private func prettyPrintDate(date: String) -> String {
        
        let encodedDate = iso8601Converter(from: date)
        
        if encodedDate != nil {
            let decodeFormatter = DateFormatter()
            decodeFormatter.dateFormat = "dd.MM.yyyy"
            let prettyDate = decodeFormatter.string(from: encodedDate!)
            
            return prettyDate
        }
        
        return date
    }
}
