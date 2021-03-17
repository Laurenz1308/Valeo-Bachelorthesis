//
//  SaveText.swift
//  LifeCreator
//
//  Created by Lori Hill on 24.06.20.
//  Copyright © 2020 Laurenz Hill. All rights reserved.
//

import SwiftUI

struct SaveText: View {
    
    var geometry: CGSize
    
    var body: some View {
        Text("Save")
            .font(.custom("Avenir", size: 20))
            .foregroundColor(Color.black)
            .frame(width: geometry.width / 3, height: geometry.height / 12, alignment: .center)
            .background(Color.green)
            .cornerRadius(20)
            .shadow(color: .black, radius: 10, x: 2, y: 2)
            .padding(.vertical, 30)
    }
}

struct SaveText_Previews: PreviewProvider {
    static var previews: some View {
        SaveText(geometry: CGSize(width: 500, height: 1000))
    }
}
