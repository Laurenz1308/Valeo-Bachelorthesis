//
//  AnsweredQuestion.swift
//  Valeo
//
//  Created by Lori Hill on 07.02.21.
//

import Foundation

struct AnsweredQuestion: Identifiable, Codable, Equatable {
    let id: UUID
    let index: Int
    let question: String
    let answerCount: Int
    let answers: [String]
    let nextQuestions: [Int]
    var answerIndex: Int
    
    init(from question: Question, with answer: Int) {
        self.id = UUID()
        self.index = question.index
        self.question = question.question
        self.answerCount = question.answerCount
        self.answers = question.answers
        self.nextQuestions = question.nextQuestions
        self.answerIndex = answer
    }
    
}
