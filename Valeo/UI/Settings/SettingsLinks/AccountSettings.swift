//
//  AccountSettings.swift
//  Valeo
//
//  Created by Lori Hill on 10.01.21.
//

import SwiftUI

struct AccountSettings: View {
    
    @EnvironmentObject var authentication: AuthenticationViewModel
    @State var showWarning = false
    
    var body: some View {
        VStack {
            HStack {
                Text("E-Mail: ")
                Spacer()
                Text(authentication.firebaseUser?.email ?? "no_email_found")
            }
            Divider()
            
            Button(action: { withAnimation{self.showWarning.toggle()} }, label: {
                Text("Account löschen")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.all, 10)
                    .overlay(Capsule().stroke(Color.gray, lineWidth: 3))
                    .background(Color.red)
                    .clipShape(Capsule())
            })
            Spacer()
        }
        .padding(.horizontal, 20)
        .alert(isPresented: self.$showWarning, content: {
            Alert(title: Text("Account löschen"),
                  message: Text("Bist du dir sicher, dass du deinen Account endgültig löschen willst?\nEr kann danach nicht wiederhergestellt werden."),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Ich bin sicher"),
                                                action: self.authentication.deleteAccount))
        })
    }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings()
            .environmentObject(AuthenticationViewModel())
    }
}
