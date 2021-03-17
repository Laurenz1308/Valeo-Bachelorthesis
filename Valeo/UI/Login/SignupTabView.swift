//
//  SignupTabView.swift
//  Valeo
//
//  Created by Lori Hill on 25.02.21.
//

import SwiftUI

struct SignupTabView: View {
    
    @EnvironmentObject var authentication: AuthenticationViewModel
    var namespace: Namespace.ID
    
    var body: some View {
        VStack{
            HStack{
                Spacer(minLength: 0)
            }
            .padding()
            .padding(.leading,15)
            
            HStack{
                Image(systemName: "envelope")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                TextField("EMAIL", text: $authentication.newMail)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .matchedGeometryEffect(id: "email", in: self.namespace)
            
            HStack{
                
                Image(systemName: "lock")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                
                SecureField("NEW PASSWORD", text: $authentication.newPassword)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top)
            .matchedGeometryEffect(id: "password", in: self.namespace)
            
            HStack{
                Image(systemName: "lock")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                
                SecureField("CONFRIM PASSWORD", text: $authentication.confirmPassword)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top)
            .matchedGeometryEffect(id: "loginButton", in: self.namespace)
            
            HStack(spacing: 15){
                Button(action: authentication.signUp, label: {
                    Text("Signup")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 150)
                        .background(Color.green)
                        .clipShape(Capsule())
                })
                .opacity(authentication.newMail != "" &&
                            authentication.newPassword != "" &&
                            authentication.confirmPassword == authentication.newPassword &&
                            authentication.checkMailAndPasswordRequirements() ? 1 : 0.5)
                .disabled(authentication.newMail != "" &&
                            authentication.newPassword != "" &&
                            authentication.confirmPassword == authentication.newPassword &&
                            authentication.checkMailAndPasswordRequirements() ? false : true)
                .alert(isPresented: $authentication.alert, content: {
                    Alert(title: Text("Error"),
                          message: Text(authentication.alertMessage),
                          dismissButton: .destructive(Text("Ok")))
                })
            }
            .padding(.top)
            .padding(.bottom)
            .matchedGeometryEffect(id: "forgetButton", in: self.namespace)
        }
    }
}

struct SignupTabView_Previews: PreviewProvider {
    static var previews: some View {
        SignupTabView(namespace: Namespace().wrappedValue)
            .environmentObject(AuthenticationViewModel())
    }
}
