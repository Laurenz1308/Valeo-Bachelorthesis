//
//  BoardingSize.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct BoardingSize: View {
    
    @Binding var size: Int
    
    var body: some View {
        VStack {
            Spacer()
            Text("Wie groß bist du?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 30)
            
            Picker("", selection: self.$size) {
                ForEach(60 ..< 250) {n in
                    Text("\(n) cm")
                }
            }
            
            Spacer()
        }
    }
}

struct BoardingSize_Previews: PreviewProvider {
    static var previews: some View {
        BoardingSize(size: .constant(100))
    }
}
