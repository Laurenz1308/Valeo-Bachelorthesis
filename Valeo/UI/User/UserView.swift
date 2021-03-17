//
//  UserView.swift
//  Valeo
//
//  Created by Lori Hill on 10.02.21.
//

import SwiftUI

struct UserView: View {
    
    @EnvironmentObject var user: UserViewModel
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: [Color("lightGreen").opacity(0.5) , Color("darkGreen").opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Gewichtsverlauf")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.leading, 25)
                        .padding(.bottom, 5)
                        .padding(.top, 10)
                    
                    Spacer()
                }
                
                LineChart(mutatingValuesList: self.$user.mutableUserInfromations)
                    .frame(height: 200, alignment: .center)
                
                Text("Weitere Tabellen kommen in kürze")
                    .lineLimit(10)
                    .multilineTextAlignment(.leading)
                    .frame( height: 100, alignment: .center)
                    .padding(.top, 30)

                Spacer()
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
            .environmentObject(UserViewModel())
    }
}
