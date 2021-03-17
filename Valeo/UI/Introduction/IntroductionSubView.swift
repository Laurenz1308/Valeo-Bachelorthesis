//
//  IntroductionSubView.swift
//  Valeo
//
//  Created by Lori Hill on 02.03.21.
//

import SwiftUI

struct IntroductionSubView<Content: View>: View {
    
    @EnvironmentObject var navigator: Navigator
    @AppStorage("showedIntroduction") var showedIntroduction: Bool = false
        
    var headline: String
    var optionalView: Content
    var explanation: String
    var showsView: Bool
    var bgColor: Color
    
    @Binding var currentPage: Int
    
    init(headLine: String, explanation: String, showsView: Bool,
         @ViewBuilder content: @escaping() -> Content, pageBinding: Binding<Int>, color: Color) {
        self.headline = headLine
        self.explanation = explanation
        self.showsView = showsView
        self.optionalView = content()
        self._currentPage = pageBinding
        self.bgColor = color
    }
    
    var body: some View {
        VStack(spacing: 20){
            HStack {
                if currentPage > 0 {
                    Button(action: {withAnimation(.easeInOut){if self.currentPage > 0 {self.currentPage -= 1}}}, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                    })
                }
                Spacer()
                Button(action: {withAnimation(.easeInOut){
                        self.showedIntroduction = true
                        self.navigator.showedIntroduction = true
                }}, label: {
                    Text("Überspringen")
                        .fontWeight(.semibold)
                        .kerning(1.2)
                })
            }
            .foregroundColor(.black)
            .padding()
            
            Spacer(minLength: 0)
            Text(headline)
                .foregroundColor(.black)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .kerning(1.4)
                .padding(.bottom, self.showsView ? 0 : 20)
            
            if showsView {
                optionalView
            }
            
            Text(explanation)
                .foregroundColor(.black)
                .font(.body)
                .fontWeight(.semibold)
                .kerning(1.4)
                .padding(.horizontal, 15)
            
            Spacer(minLength: 0)
            Spacer(minLength: 100)
            
            
        }
        .background(self.bgColor.ignoresSafeArea())
    }
    

}
