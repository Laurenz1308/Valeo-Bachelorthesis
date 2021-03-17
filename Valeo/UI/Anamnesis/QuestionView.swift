//
//  QuestionView.swift
//  Valeo
//
//  Created by Lori Hill on 03.03.21.
//

import SwiftUI

struct QuestionView: View {
    
    let question: Question
    let namespace: Namespace.ID
    var answerQuestion: (Int) -> Void
    
    var body: some View {
        VStack {
            Text(question.question)
                .font(.title)
                .padding()
            
            ForEach(0..<question.answers.count, id: \.self) { index in
                HStack {
                    
                    Spacer()
                    
                    if question.answers.count > index {
                        Text(question.answers[index])
                            .font(.title3)
                            .padding()
                            .overlay(Capsule()
                                        .stroke(Color(.cyan), lineWidth: 2))
                            .padding(.horizontal, 15)
                            .matchedGeometryEffect(id: "\(question.index) \(index)",
                                                   in: namespace)
                            .onTapGesture {
                                withAnimation {
                                    self.answerQuestion(index)
                                }
                            }
                    }
                }
            }
        }
        .transition(.move(edge: .top))
    }
}
