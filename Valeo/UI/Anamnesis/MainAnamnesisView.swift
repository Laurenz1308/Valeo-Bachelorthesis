//
//  MainAnamnesisView.swift
//  Valeo
//
//  Created by Lori Hill on 04.02.21.
//

import SwiftUI

/// View to display the anamnesis to the user.
struct MainAnamnesisView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var daySummary: DaysummaryViewModel
    @EnvironmentObject var navigator: Navigator
    
    @ObservedObject var anamnesis = AnamnesisViewModel()
    
    @Namespace var animation
    
    @State var saveAnimation = false
    @State private var displayBorder = false   // StrokeBorder (lineWidth) 64 - 5
    @State private var displayCheckmark = false  // Trimpath from 1 - 0
    
    @State var showQuestion = true
                    
    var body: some View {
        VStack {
            
            HStack {
                Button(action: { withAnimation
                { self.navigator.setCurrentView(to: .main)}}) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(.leading, 15)
                }
                
                Spacer()
                
                Text("Anamnese")
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(.clear)
                    .padding(.trailing, 15)
            }
            .padding(.bottom, 10)
            .background(Color(.systemGray3).edgesIgnoringSafeArea(.top))
            
            oldQuestion
            
            Spacer()
            
            if anamnesis.currentQuestion != nil && !anamnesis.loading {
                if showQuestion {
                    QuestionView(question: anamnesis.currentQuestion!,
                                 namespace: self.animation,
                                 answerQuestion: self.answerQuestion(at:))
                    .transition(.move(edge: .top))
                }
                Spacer()
            } else {
                if anamnesis.loading {
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 14)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .trim(from: 0, to: 0.2)
                            .stroke(Color.green, lineWidth: 7)
                            .frame(width: 70, height: 70)
                            .rotationEffect(Angle(degrees: anamnesis.loading ? 360 : 0))
                            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    }
                    Spacer()
                } else if anamnesis.anamnesisFinished {
                    if saveAnimation {
                        checkmarkSaveAnimation
                    } else {
                        Button(action: { saveAnamnesis() }) {
                            Text("Speicher Anamnese")
                                .font(.title)
                                .padding()
                                .overlay(Capsule()
                                            .stroke(Color(.green), lineWidth: 2))
                                .padding(.horizontal, 15)
                                .foregroundColor(self.colorScheme == .light ? .black : .white)
                        }
                        Spacer()
                    }
                } else {
                    Text("Not Loading and nothing to display")
                    Spacer()
                }
            }
            
        }
        .alert(isPresented: self.$anamnesis.error, content: {
            Alert(title: Text(anamnesis.errorMessage))
        })
        .onChange(of: self.anamnesis.loading, perform: { value in
            if !value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showQuestion = true
                }
            }
        })
    }
    
    var oldQuestion: some View {
        ForEach(anamnesis.answeredQuestions.reversed()) { item in
            if item.id == anamnesis.answeredQuestions.last?.id {
                HStack {
                    
                    Spacer()
                    
                    Text("\(item.answers[item.answerIndex])")
                        .font(.caption)
                        .padding()
                        .overlay(Capsule()
                                    .stroke(Color(.cyan), lineWidth: 2))
                        .padding(.horizontal, 15)
                        .matchedGeometryEffect(id: "\(item.index) \(item.answerIndex)",
                                               in: animation)
                        .onTapGesture {
                            withAnimation {
                                anamnesis.getPreviousQuestion()
                            }
                        }
                        .transition(.opacity)
                }
            }
        }
    }
    
    var checkmarkSaveAnimation: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: displayBorder ? 5 : 64))
                    .frame(width: 128, height: 128)
                    .foregroundColor(.green)
                    .animation(Animation
                                .easeOut(duration: 1.5)
                                .speed(3))
                    .onAppear() {
                            self.displayBorder.toggle()
                    }

                Path { path in
                    path.move(to: CGPoint(x: -30, y: 0))
                    path.addLine(to: CGPoint(x: -30, y: 0))
                    path.addLine(to: CGPoint(x: -10, y: 20))
                    path.addLine(to: CGPoint(x: 30, y: -20))
                
                }.trim(from: 0, to: displayCheckmark ? 1 : 0)
                .stroke(style: StrokeStyle(lineWidth: 10,
                                           lineCap: .round,
                                           lineJoin: .round))
                .foregroundColor(displayCheckmark ? .green : .white)
                .offset(x: geometry.size.width * 0.5,
                        y: geometry.size.height * 0.5)
                .animation(Animation
                            .interpolatingSpring(stiffness: 160, damping: 20)
                            .delay(1))
                .onAppear() {
                    self.displayCheckmark.toggle()
                }
            }
            Spacer()
        }
    }
    
    private func answerQuestion(at index: Int) {
        withAnimation(.easeInOut){
            self.showQuestion = false
            self.anamnesis.answerQuestion(at: index)
        }
    }
    
    private func saveAnamnesis() {
        
        if self.anamnesis.anamnesis != nil {
            DispatchQueue.main.async {
                self.daySummary.uploadAnamnesis(of: self.anamnesis.anamnesis!)
            }
            
            self.saveAnimation.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigator.setCurrentView(to: .main)
            }
        }
    }
    
}

struct MainAnamnesisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainAnamnesisView()
                .environmentObject(Navigator())
                .environmentObject(DaysummaryViewModel())
        }
    }
}

