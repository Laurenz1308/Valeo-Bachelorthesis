//
//  Anamnesis.swift
//  Valeo
//
//  Created by Laurenz Hill on 10.12.20.
//

import Foundation

struct Anamnesis: Codable {
    
    var anamnesisId: UUID
    var userId: String
    var created: String
    var finished: String
    var questionId: [UUID]
    var answerIndices: [Int]
}
