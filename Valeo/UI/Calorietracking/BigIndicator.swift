//
//  BigIndicator.swift
//  Valeo
//
//  Created by Laurenz Hill on 12.12.20.
//

import SwiftUI

struct BigIndicator: View {
    var emoji: String
    var text: Int
    
    var body: some View {
        GeometryReader { g in
            VStack {
                Text(self.emoji)
                    .font(.largeTitle)
                Text(String(self.text) + " kcal")
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.white)
            }
            .padding(.all, 15)
            .frame(width: g.size.width, height: g.size.height, alignment: .center)
            .background(Circle()
                        .foregroundColor(Color.black.opacity(0.5)))
        }
    }
}

struct BigIndicator_Previews: PreviewProvider {
    static var previews: some View {
        BigIndicator(emoji: "🔥", text: 345)
    }
}
