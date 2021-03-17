//
//  AnamnesisRepository.swift
//  Valeo
//
//  Created by Lori Hill on 12.02.21.
//

import Foundation
import Firebase

/// Manages the data flow of creatting an anamnesis of the user.
final class AnamnesisRepository: ObservableObject {
        
    @Published var error = false
    @Published var errorMessage = ""
    @Published var loading = false
    @Published var userId = Auth.auth().currentUser?.uid ?? ""
    
    // The current question if there is one. Should always be the last element of questions.
    @Published var currentQuestion: Question?
    
    /// Requesting the next question from Firestore. If a question can be found it will be set as currentQuestion.
    /// In case of failure an error will be displayed.
    ///
    /// - parameters of  index:  index of the nextQuestion
    ///
    func loadNextQuestion(of index: Int) {
        
        self.loading = true
        
        let db = Firestore.firestore()
        db.collection(FirestoreCollections.anamnesisQuestionsCollection)
            .whereField(FirestoreCollections.anamnesisQuestionIndex, isEqualTo: index)
            .getDocuments { [self] (snapshot, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    self.errorMessage = "Something with finding the question went wrong."
                    self.error = true
                    self.loading = false
                    return
                }
                
                guard snapshot != nil else {
                    self.errorMessage = "Something with finding the question went wrong."
                    self.error = true
                    self.loading = false
                    return
                }
                
                if snapshot!.isEmpty {
                    print("No question found for index \(index)")
                    self.errorMessage = "Something with finding the question went wrong."
                    self.error = true
                    self.loading = false
                    return
                } else if snapshot!.count == 1 {
                    
                    do {
                        let foundQuestion = try snapshot!.documents.first!.data(as: Question.self)!
                        self.currentQuestion = foundQuestion
                                                
                        self.loading = false
                        return
                    } catch {
                        print(error.localizedDescription)
                        self.errorMessage = "Something with displaying the question went wrong."
                        self.error = true
                        self.loading = false
                        return
                    }
                }
                
        }
    }
    
}
