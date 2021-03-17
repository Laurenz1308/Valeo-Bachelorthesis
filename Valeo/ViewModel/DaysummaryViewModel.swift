//
//  DaysummaryViewModel.swift
//  Valeo
//
//  Created by Lori Hill on 15.02.21.
//

import Foundation
import Combine

/// Organizes data and makes them displayable of all the data needed to represent a day in the main view.
final class DaysummaryViewModel: ObservableObject {
    
    @Published var daysummaryRepository = DaysummaryRepository()
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var daysummary: DaySummary?
    @Published var needToAskForAnamnesis = false
    @Published var todaysConsumptions: [ConsumptionViewModel] = []
    let today = Date()
    @Published var showsToday = true
    @Published var selectedDate = Date() {
        didSet {
            // Verifying selected day to either show accordingly or load new
            let calendar = Calendar(identifier: .gregorian)
            
            let compareOld = calendar.compare(selectedDate, to: loadedOld, toGranularity: .day)
            let compareToday = calendar.compare(today, to: selectedDate, toGranularity: .day)
            
            if compareToday.rawValue == 0 {
                self.showsToday = true
            } else if compareOld.rawValue == 0 {
                self.showsToday = false
            } else {
                // selected day is neither today nor the old day loaded before
                // load the daysummary of selected old day
                self.showsToday = false
                self.loadOldDaySummary(of: self.selectedDate)
                loadedOld = self.selectedDate
            }
        }
    }
    private var loadedOld = Date()
    @Published var oldDaysummary: DaySummary?
    @Published var oldConsumptions: [ConsumptionViewModel] = []
    @Published var loading = false
    
    var breakfast: [ConsumptionViewModel] {
        if showsToday {
            let filtered = todaysConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.breakfast.rawValue
            }
            return filtered
        } else {
            let filtered = oldConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.breakfast.rawValue
            }
            return filtered
        }
    }
    
    var lunch: [ConsumptionViewModel] {
        if showsToday {
            let filtered = todaysConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.lunch.rawValue
            }
            return filtered
        } else {
            let filtered = oldConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.lunch.rawValue
            }
            return filtered
        }
    }
    
    var snack: [ConsumptionViewModel] {
        if showsToday {
            let filtered = todaysConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.snack.rawValue
            }
            return filtered
        } else {
            let filtered = oldConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.snack.rawValue
            }
            return filtered
        }
    }
    
    var dinner: [ConsumptionViewModel] {
        if showsToday {
            let filtered = todaysConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.dinner.rawValue
            }
            return filtered
        } else {
            let filtered = oldConsumptions.filter { (element) -> Bool in
                return element.consumption?.meal == MealType.dinner.rawValue
            }
            return filtered
        }
    }
    
    var totalCalories: Int {
        if showsToday {
            return totalCalories(of: todaysConsumptions)
        } else {
            return totalCalories(of: oldConsumptions)
        }
    }
    
    var totalCarbohydrates: Int {
        if showsToday {
            return totalCarbohydrates(of: todaysConsumptions)
        } else {
            return totalCarbohydrates(of: oldConsumptions)
        }
    }
    
    var totalProtein: Int {
        if showsToday {
            return totalProtein(of: todaysConsumptions)
        } else {
            return totalProtein(of: oldConsumptions)
        }
    }
    
    var totalFat: Int {
        if showsToday {
            return totalFat(of: todaysConsumptions)
        } else {
            return totalFat(of: oldConsumptions)
        }
    }
    
    var todaysWater: Double {
        if showsToday {
            return daysummary?.water ?? 0.0
        } else {
            return oldDaysummary?.water ?? 0.0
        }
    }
    
    var hasTodaysAnamnesis: Bool {
        if showsToday {
            return self.daysummary?.anamnesisId != nil
        } else {
            return true
        }
    }
    
    init() {
        daysummaryRepository.$daySummary
            .assign(to: \.daysummary, on: self)
            .store(in: &cancellables)
        
        daysummaryRepository.$todaysConsumptions
            .map { consumptions in
                consumptions.map(ConsumptionViewModel.init)
            }
            .assign(to: \.todaysConsumptions, on: self)
            .store(in: &cancellables)
        
        daysummaryRepository.$oldDaysummary
            .assign(to: \.oldDaysummary, on: self)
            .store(in: &cancellables)
        
        daysummaryRepository.$oldConsumptions
            .map { consumptions in
                consumptions.map(ConsumptionViewModel.init)
            }
            .assign(to: \.oldConsumptions, on: self)
            .store(in: &cancellables)
        
        daysummaryRepository.$loading
            .assign(to: \.loading, on: self)
            .store(in: &cancellables)
    }
    
    func saveConsumption(_ consumption: ConsumptionViewModel) {
        
        guard showsToday else {
            print("Wrong day to add consumption")
            return
        }
                
        guard consumption.consumption != nil else {
            print("Consumption is empty")
            return
        }
        
        guard daysummary != nil && daysummaryRepository.daySummary != nil else {
            print("No daysummary existing")
            daysummaryRepository = DaysummaryRepository()
            
            self.cancellables = []
            
            daysummaryRepository.$daySummary
                .assign(to: \.daysummary, on: self)
                .store(in: &cancellables)
            
            daysummaryRepository.$todaysConsumptions
                .map { consumptions in
                    consumptions.map(ConsumptionViewModel.init)
                }
                .assign(to: \.todaysConsumptions, on: self)
                .store(in: &cancellables)
            return
        }
        
        let existing = self.todaysConsumptions.filter { (consumptionVM) -> Bool in
            let mealTypMatch = consumptionVM.consumption?.meal == consumption.consumption?.meal
            let nameMatch = consumptionVM.consumption?.name == consumption.consumption?.name
            return mealTypMatch && nameMatch
        }
        
        if existing.isEmpty {
            daysummaryRepository.addConsumption(consumption.consumption!)
        } else if existing.count == 1 {
            // Update first element
            existing[0].updateConsumption(new: consumption.consumption!)
        } else {
            // Since there are multpile something is wrong and its easiest to just append it
            daysummaryRepository.addConsumption(consumption.consumption!)
        }
        
        
    }
    
    func deleteConsumption(by id: UUID) {
        if self.showsToday {
            let foundConsumption = self.todaysConsumptions.first { (consumptionVM) -> Bool in
                consumptionVM.consumption?.consumptionId == id
            }
            
            foundConsumption?.deleteConsumption()
            
            self.daysummaryRepository.deleteConsumption(by: id)
        }
    }
    
    func uploadAnamnesis(of anamnesis: Anamnesis) {
        if self.showsToday {
            let finished = ISO8601DateFormatter.string(from: Date(),
                                                       timeZone: .current,
                                                       formatOptions: [.withFullTime, .withFullDate])
            
            var uploadAnamnesis = anamnesis
            uploadAnamnesis.finished = finished
            daysummaryRepository.createAnamnesis(uploadAnamnesis)
        }
    }
    
    func loadOldDaySummary(of day: Date) {
        daysummaryRepository.getOldDaySummary(of: day)
        daysummaryRepository.getOldConsumption(of: day)
    }
    
    private func totalCalories(of consumptions: [ConsumptionViewModel]) -> Int {
        var summedCalories = 0
        for x in consumptions {
            // Consumption has calories relative to servingSize, by multiplying it with the amount yout get the consumed calories.
            summedCalories += Int(Double(x.consumption!.calories) * x.amount)
        }
        return summedCalories
    }
    
    private func totalCarbohydrates(of consumptions: [ConsumptionViewModel]) -> Int {
        var summedCarbohydretas = 0
        for x in consumptions {
            // Consumption has calories relative to servingSize, by multiplying it with the amount yout get the consumed carbohydrates.
            summedCarbohydretas += Int(x.consumption!.carbohydrate * x.amount)
        }
        return summedCarbohydretas
    }
    
    private func totalProtein(of consumptions: [ConsumptionViewModel]) -> Int {
        var summedProtein = 0
        for x in consumptions {
            // Consumption has calories relative to servingSize, by multiplying it with the amount yout get the consumed carbohydrates.
            summedProtein += Int(x.consumption!.protein * x.amount)
        }
        return summedProtein
    }
    
    private func totalFat(of consumptions: [ConsumptionViewModel]) -> Int {
        var summedFat = 0
        for x in consumptions {
            // Consumption has calories relative to servingSize, by multiplying it with the amount yout get the consumed carbohydrates.
            summedFat += Int(x.consumption!.total_fat * x.amount)
        }
        return summedFat
    }
}
