//
//  BoardingName.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct BoardingName: View {
    
    @Binding var name: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Willkommen!")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            Text("Wie heißt du?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            TextField("Name", text: self.$name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct BoardingName_Previews: PreviewProvider {
    static var previews: some View {
        BoardingName(name: .constant(""))
    }
}
