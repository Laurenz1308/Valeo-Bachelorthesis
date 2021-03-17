//
//  BoardingGender.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct BoardingGender: View {
    
    @Binding var gender: Gender
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Was ist dein Geschlecht?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 30)
            
            Picker("Geschlecht", selection: self.$gender) {
                Text("Mann").tag(Gender.male)
                Text("Frau").tag(Gender.female)
                Text("Divers").tag(Gender.divers)
            }
            
            Spacer()
        }
    }
}

struct BoardingGender_Previews: PreviewProvider {
    static var previews: some View {
        BoardingGender(gender: .constant(.male))
    }
}
