//
//  BoardingWeight.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct BoardingWeight: View {
    
    @Binding var weight: Int
    
    var body: some View {
        VStack {
            Spacer()
            Text("Wie viel wiegst du?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 30)
            
            Picker("", selection: self.$weight) {
                ForEach(40 ..< 250) {n in
                    Text("\(n) kg")
                }
            }
            
            Spacer()
        }
    }
}

struct BoardingWeight_Previews: PreviewProvider {
    static var previews: some View {
        BoardingWeight(weight: .constant(70))
    }
}
