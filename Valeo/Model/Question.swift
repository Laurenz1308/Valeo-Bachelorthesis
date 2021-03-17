//
//  Question.swift
//  Valeo
//
//  Created by Lori Hill on 04.02.21.
//

import Foundation
import Firebase


struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let index: Int
    let question: String
    let answerCount: Int
    let answers: [String]
    let nextQuestions: [Int]
    
    init(index: Int, question: String, answers: [String], nextQuestions: [Int]) {
        self.id = UUID()
        self.index = index
        self.question = question
        self.answerCount = answers.count
        self.answers = answers
        self.nextQuestions = nextQuestions
    }
    
    init(answer: AnsweredQuestion) {
        self.id = UUID()
        self.index = answer.index
        self.question = answer.question
        self.answerCount = answer.answerCount
        self.answers = answer.answers
        self.nextQuestions = answer.nextQuestions
    }
    
}
