//
//  BoardingWaistAndBodyfat.swift
//  Valeo
//
//  Created by Lori Hill on 14.01.21.
//

import SwiftUI

struct BoardingWaistAndBodyfat: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Wie groß bist du?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 30)
            
            Spacer()
        }
    }
}

struct BoardingWaistAndBodyfat_Previews: PreviewProvider {
    static var previews: some View {
        BoardingWaistAndBodyfat()
    }
}
