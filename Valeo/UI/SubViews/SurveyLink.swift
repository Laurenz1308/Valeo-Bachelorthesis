//
//  SurveyLink.swift
//  Valeo
//
//  Created by Lori Hill on 08.03.21.
//

import SwiftUI

struct SurveyLink: View {
    
    let text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            
            Button(action: {
                
                guard let url = URL(string: text) else {
                    print("Url cannot be opened")
                    return
                }
                UIApplication.shared.open(url)
            }, label: {
                Text("Eine Umfrage ist verfügbar")
                    .font(.title3)
                    .bold()
                    .foregroundColor(self.colorScheme == .light ? .black : .white)
            })
        }
        .padding()
        .frame(width: UIScreen.main.bounds.size.width * 0.9,
               height: 75, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(Color(.systemGray)))
    }
}

struct SurveyLink_Previews: PreviewProvider {
    static var previews: some View {
        SurveyLink(text: "https://www.google.de")
    }
}
