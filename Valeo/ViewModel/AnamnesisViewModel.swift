//
//  AnamnesisViewModel.swift
//  Valeo
//
//  Created by Lori Hill on 12.02.21.
//

import Foundation
import Combine

final class AnamnesisViewModel: ObservableObject {
    
    private var anamnesisRepository = AnamnesisRepository()
    
    var anamnesis: Anamnesis?
    
    var currentQuestionIndex: Int = 0
    
    var userId: String = ""
    
    @Published var questions: [Question] = []
    @Published var answerIndicesToAskedQuestions: [Int] = []
    @Published var answeredQuestions: [AnsweredQuestion] = []
        
    @Published var error = false
    @Published var errorMessage = ""
    @Published var loading = false
    
    // The current question if there is one. Should always be the last element of questions.
    @Published var currentQuestion: Question?
    @Published var anamnesisFinished = false
    
    private var cancelables: Set<AnyCancellable> = []
    
    init() {
        anamnesisRepository.$currentQuestion
            .assign(to: \.currentQuestion, on: self)
            .store(in: &cancelables)
        
        anamnesisRepository.$loading
            .assign(to: \.loading, on: self)
            .store(in: &cancelables)
        
        anamnesisRepository.$error
            .assign(to: \.error, on: self)
            .store(in: &cancelables)
        
        anamnesisRepository.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancelables)
        
        anamnesisRepository.$userId
            .assign(to: \.userId, on: self)
            .store(in: &cancelables)
        
        if anamnesisRepository.userId != "" {
            let isoStringNow = ISO8601DateFormatter().string(from: Date())
            self.anamnesis = Anamnesis(anamnesisId: UUID(),
                                       userId: anamnesisRepository.userId,
                                       created: isoStringNow,
                                       finished: "",
                                       questionId: [],
                                       answerIndices: [])
        }
        
        anamnesisRepository.loadNextQuestion(of: currentQuestionIndex)
    }
    
    /// Answer the current question. the answer will be appended to answeredQuestions so it can be managed.
    /// A request for the next question with self.loadNextQuestion() will be made if the index of the next question is greater than zero.
    /// A zero index for the next question represnets the end of the anamnese which will be displayed in that case.
    ///
    /// - parameters at index: The index of the answers array of the current question. It will be used to get the nextQuestionIndex from currentQuestion.
    ///
    public func answerQuestion(at index: Int) {
        
        guard self.userId != "" else {
            print("Not authenticated")
            return
        }
        
        
        if self.anamnesis == nil  {
            let iso = ISO8601DateFormatter.string(from: Date(),
                                                  timeZone: .current,
                                                  formatOptions: [.withFullDate,.withFullTime])
            
            self.anamnesis = Anamnesis(anamnesisId: UUID(),
                                       userId: userId,
                                       created: iso,
                                       finished: "",
                                       questionId: [],
                                       answerIndices: [])
        }
        
        guard let question = currentQuestion, question.answers.count > index else {
            print("ERROR no current question found or index wrong")
            self.errorMessage = "No current question found."
            self.error = true
            return
        }
        
        let answer = AnsweredQuestion(from: question, with: index)
        let nextQuestionIndex = question.nextQuestions[index]
        self.answeredQuestions.append(answer)
        self.anamnesis!.questionId.append(self.currentQuestion!.id)
        self.anamnesis!.answerIndices.append(index)
        
        self.currentQuestion = nil
        
        if nextQuestionIndex > 0 {
            anamnesisRepository.loadNextQuestion(of: nextQuestionIndex)
        } else {
            self.anamnesisFinished = true
        }
        
    }
    
    /// Getter of previous question. Shoul only be displayed in UI from view that shows oldQuestion.
    /// The currentQuestion will be deleted from questions, the currently previous question removed from answeredQuestions and set as cuerentQuestion.
    /// OldQuestionId will be set to the last element.id of answeredQuestions.
    ///
    func getPreviousQuestion() {
        
        guard anamnesis != nil && answeredQuestions.count > 0 else {
            print("No previous question found")
            self.errorMessage = "No previous question found"
            self.error = true
            return
        }
        
        let oldQuestion = Question(answer: self.answeredQuestions.last!)
        
        questions.removeAll { (question) -> Bool in
            if currentQuestion != nil {
                return question.id == self.currentQuestion!.id
            } else {
                return question.id == questions.last?.id
            }
        }
        
        self.currentQuestion = oldQuestion
        
        answeredQuestions.removeAll { (answeredQuestion) -> Bool in
            answeredQuestion.id == answeredQuestions.last?.id
        }
        
        self.anamnesis!.questionId.removeLast()
        self.anamnesis!.answerIndices.removeLast()
                
    }
    
}
