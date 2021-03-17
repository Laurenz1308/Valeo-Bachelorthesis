//
//  LoginAndSignupView.swift
//  Valeo
//
//  Created by Lori Hill on 20.01.21.
//

import SwiftUI
import AuthenticationServices

struct LoginAndSignupView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authentication: AuthenticationViewModel
    @Namespace var firebaseAnimation
    
    @State var showMailLogin = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                if self.showMailLogin {
                    LoginAndSignupTabBar()
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .frame(maxHeight: geometry.size.height * 0.5,
                               alignment: .center)
                        .padding(.horizontal, 30)
                        .transition(.scale)
                        .matchedGeometryEffect(id: "mail", in: self.firebaseAnimation)
                        .onTapGesture {
                            hideKeyboard()
                        }
                    
                } else {
                    VStack {
                        
                        Button(action: {withAnimation(.easeInOut){
                            self.showMailLogin.toggle()
                        }}, label: {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.title2)
                                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                                
                                Text("Sign in with Email")
                                    .font(.title2)
                                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                            }
                            .padding()
                            .padding(.horizontal, 30)
                            .frame(width: UIScreen.main.bounds.size.width * 0.8,
                                   height: 60,
                                   alignment: .center)
                            .background(self.colorScheme == .light ? Color.white : Color.black)
                            .clipShape(Capsule())
                            
                        })
                        .transition(.scale)
                        .matchedGeometryEffect(id: "mail", in: self.firebaseAnimation)
                        
                        Button(action: { self.authentication.signInAnonymously() },
                               label: {
                            HStack {
                                Image("anonymousSF")
                                    .font(.title)
                                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                                
                                Text("Sign in Anonymously")
                                    .font(.title2)
                                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                            }
                            .padding()
                            .padding(.horizontal, 30)
                            .frame(width: UIScreen.main.bounds.size.width * 0.8,
                                   height: 60,
                                   alignment: .center)
                            .background(self.colorScheme == .light ? Color.white : Color.black)
                            .clipShape(Capsule())
                        })
                    }
                }
                
                HStack(spacing: 15){
                    Rectangle()
                        .fill(self.colorScheme == .light ? Color.black : Color.white)
                        .cornerRadius(1.5)
                        .frame(height: 3)
                    
                    Text("OR")
                        .bold()
                        .kerning(1.5)
                    
                    Rectangle()
                        .fill(self.colorScheme == .light ? Color.black : Color.white)
                        .cornerRadius(1.5)
                        .frame(height: 3)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                
                SignInWithAppleButton { (request) in
                    
                    // requestion parameters from apple login
                    authentication.nonce = authentication.randomNonceString()
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = authentication.sha256(authentication.nonce)
                    
                } onCompletion: { (result) in
                    // Getting error or success
                    switch result {
                    case .success(let user):
                        // do login with Firebase
                        guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                            print("Failure")
                            return
                        }
                        self.authentication.signInWithApple(credential: credential)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(self.colorScheme == .light ? .white : .black)
                .clipShape(Capsule())
                .padding(.horizontal, 30)
                .frame(height: 60, alignment: .center)
                
                
                Spacer()
                
            }
            .background( ZStack {
                LinearGradient(gradient:
                                            Gradient(colors: [Color("lightGreen"), Color("darkGreen")]),
                                           startPoint: .topTrailing,
                                           endPoint: .bottomLeading)
                Color(self.colorScheme == .light ? .white : .black)
                    .opacity(0.2)
            })
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                if self.showMailLogin {
                    withAnimation(.easeInOut){
                        self.showMailLogin.toggle()
                    }
                }
            }
        }
    }
}

struct LoginAndSignupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // MARK: Preview is not working because of AuthenticationCurve.animatableData.
            // MARK: Fore preview commet AuthenticationCurve.animatableData.
            LoginAndSignupView()
                .environmentObject(AuthenticationViewModel())
            
            LoginAndSignupView()
                .environmentObject(AuthenticationViewModel())
                .environment( \.colorScheme, .dark)
            
            LoginAndSignupTabBar()
                .environmentObject(AuthenticationViewModel())
            
            LoginTabView(namespace: Namespace().wrappedValue)
                .environmentObject(AuthenticationViewModel())
            
            SignupTabView(namespace: Namespace().wrappedValue)
                .environmentObject(AuthenticationViewModel())
            
            LoginAndSignupTabBar()
                .environmentObject(AuthenticationViewModel())
        }
    }
}


#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
