//
//  SwiftUIView.swift
//  Valeo
//
//  Created by Lori Hill on 06.03.21.
//

import SwiftUI

struct AcceptPrivacyPolicy: View {
    
    @AppStorage("hasAcceptedPrivacyPolicy")
        var hasAcceptedPrivacyPolicy: Bool = false
    @EnvironmentObject var user: UserViewModel
    let policyText = "Bitte akzeptiere die Datenschutzerklärung um die App nutzen zu können"
    
    @State var accepted = false
    @State var showPolicy = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Text(policyText)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 30)
                    
                    HStack {
                        Button(action: {withAnimation{self.accepted.toggle()}}, label: {
                            ZStack {
                                if self.accepted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.green)
                                        .transition(.opacity)
                                }
                                Circle()
                                    .strokeBorder(Color.black,lineWidth: 4)
                                    .frame(width: 50, height: 50, alignment: .center)
                            }
                        })
                        .padding(.leading, 20)
                        
                        Button(action: {withAnimation{self.showPolicy.toggle()}}, label: {
                            Text("Ich akzeptiere die Datenschutzerklärung von Valeo Diary")
                        })
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 25)
                    
                    Button(action: self.confirmPolicy, label: {
                        Text("Bestätigen")
                            .foregroundColor(.black)
                    })
                    .frame(width: geometry.size.width * 0.8,
                           height: 60,
                           alignment: .center)
                    .background(
                        ZStack {
                            Color.green
                            if !self.accepted {
                                Color.black.opacity(0.3)
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .disabled(!self.accepted)
                    
                    Spacer()
                }
                
                if self.showPolicy {
                    AGB()
                        .background(Color.white)
                        .overlay(Button(action: {withAnimation{self.showPolicy.toggle()}}, label: {
                            Image(systemName: "xmark.circle")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                                .background(Color.white.clipShape(Circle()))
                        })
                        .padding(.all, 25)
                        , alignment: .topTrailing)
                }
                
            }
        }
        .background(RoundedRectangle(cornerRadius: 25.0).foregroundColor(Color(.systemGray)))
    }
    
    
    private func confirmPolicy() {
        withAnimation{
            if self.accepted {
                self.hasAcceptedPrivacyPolicy = true
                self.user.hasAcceptedPrivacyPolicy = true
            }
        }
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AcceptPrivacyPolicy()
            .environmentObject(UserViewModel())
    }
}
