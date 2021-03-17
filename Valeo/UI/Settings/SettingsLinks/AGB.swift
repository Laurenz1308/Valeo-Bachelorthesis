//
//  AGB.swift
//  Valeo
//
//  Created by Lori Hill on 10.01.21.
//

import SwiftUI

struct AGB: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(getLicense(for: "PrivacyPolicyGerman"))
                    .frame(width: geometry.size.width,
                       alignment: .center)
            }
        }
    }
    
    private func getLicense(for path: String) -> NSMutableAttributedString {
        let searchUrl = Bundle.main.url(forResource: path,
                                  withExtension: "rtf")
        
        guard let url = searchUrl else {
            return NSMutableAttributedString(string: "License not found")
        }
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
        let rtfString = try? NSMutableAttributedString(url: url, options: options, documentAttributes: nil)
        
        guard let foundString = rtfString else {
            return NSMutableAttributedString(string: "License not found")
        }
        
        return foundString
    }
    
}

struct AGB_Previews: PreviewProvider {
    static var previews: some View {
        AGB()
    }
}
