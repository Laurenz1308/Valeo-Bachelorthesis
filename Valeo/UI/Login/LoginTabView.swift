//
//  LoginTabView.swift
//  Valeo
//
//  Created by Lori Hill on 25.02.21.
//

import SwiftUI

struct LoginTabView: View {
    
    @EnvironmentObject var authentication: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
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
                TextField("EMAIL", text: $authentication.email)
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
                
                SecureField("PASSWORD", text: $authentication.password)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top)
            .matchedGeometryEffect(id: "password", in: self.namespace)
            
            HStack(spacing: 15){
                Button(action: authentication.login, label: {
                    Text("LOGIN")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 150)
                        .background(Color(.cyan))
                        .clipShape(Capsule())
                })
                .opacity(authentication.email != "" && authentication.password != "" ? 1 : 0.5)
                .disabled(authentication.email != "" && authentication.password != "" ? false : true)
                .alert(isPresented: $authentication.alert, content: {
                    Alert(title: Text("Error"),
                          message: Text(authentication.alertMessage),
                          dismissButton: .destructive(Text("Ok")))
                })
            }
            .padding(.top)
            .matchedGeometryEffect(id: "loginButton", in: self.namespace)
            
            // Forget Button...
            
            Button(action: {}, label: {
                Text("Forgot password?")
                    .foregroundColor(Color.red)
            })
            .padding(.top,8)
            .padding(.bottom, 10)
            .matchedGeometryEffect(id: "forgetButton", in: self.namespace)
        }
    }
}

struct LoginTabView_Previews: PreviewProvider {
    static var previews: some View {
        LoginTabView(namespace: Namespace().wrappedValue)
            .environmentObject(AuthenticationViewModel())
    }
}
