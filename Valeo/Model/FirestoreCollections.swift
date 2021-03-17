//
//  FirestoreCollections.swift
//  Valeo
//
//  Created by Lori Hill on 11.02.21.
//

import Foundation

/// Here are all collection and document names for the Firestore data.
struct FirestoreCollections {
    
    static let userCollection = "user"
    static let userMutatingValues = "mutatingValues"
    static let userMutatingCreated = "created"
    
    static let anamnesisCollection = "anamnesis"
    static let anamnesisQuestionsCollection = "questions"
    static let anamnesisQuestionIndex = "index"
    
    static let consumptionCollection = "consumption"
    static let consumptionUserId = "userId"
    static let consumptionCreated = "created"
    
    static let daysummaryCollection = "daysummary"
    static let daysummaryUserId = "userId"
    static let daysummaryDate = "date"
    
    static let nutrientCollection = "nutrient"
    static let nutrientDetailCollection = "detailed"
    static let nutrientDetailedMineralDocument = "minerals"
    static let nutrientDetailedVitamineDocument = "vitamines"
    static let nutrientDetailedOthersDocument = "others"
}
