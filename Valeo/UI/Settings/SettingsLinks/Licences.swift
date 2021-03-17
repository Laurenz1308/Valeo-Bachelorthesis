//
//  Licences.swift
//  Valeo
//
//  Created by Lori Hill on 10.01.21.
//

import SwiftUI

struct Licences: View {
    
    var body: some View {
        List {
            NavigationLink("Firebase SDK License",
                           destination: LicenseView(text: getLicense(for: "FirebaseSDKLicense")))
            
            NavigationLink("Algolia SDK License",
                           destination: LicenseView(text: getLicense(for: "AlgoliaSDKLicense")))
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

struct Licences_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Licences()
        }
    }
}

struct LicenseView: View {
    
    let text: NSAttributedString
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(text)
                    .frame(width: geometry.size.width,
                       alignment: .center)
            }
        }
    }
    
}


extension Text {
    init(_ astring: NSAttributedString) {
        self.init("")
        
        astring.enumerateAttributes(in: NSRange(location: 0, length: astring.length), options: []) { (attrs, range, _) in
            
            var t = Text(astring.attributedSubstring(from: range).string)

            if let color = attrs[NSAttributedString.Key.foregroundColor] as? UIColor {
                t  = t.foregroundColor(Color(color))
            }

            if let font = attrs[NSAttributedString.Key.font] as? UIFont {
                t  = t.font(.init(font))
            }

            if let kern = attrs[NSAttributedString.Key.kern] as? CGFloat {
                t  = t.kerning(kern)
            }
            
            
            if let striked = attrs[NSAttributedString.Key.strikethroughStyle] as? NSNumber, striked != 0 {
                if let strikeColor = (attrs[NSAttributedString.Key.strikethroughColor] as? UIColor) {
                    t = t.strikethrough(true, color: Color(strikeColor))
                } else {
                    t = t.strikethrough(true)
                }
            }
            
            if let baseline = attrs[NSAttributedString.Key.baselineOffset] as? NSNumber {
                t = t.baselineOffset(CGFloat(baseline.floatValue))
            }
            
            if let underline = attrs[NSAttributedString.Key.underlineStyle] as? NSNumber, underline != 0 {
                if let underlineColor = (attrs[NSAttributedString.Key.underlineColor] as? UIColor) {
                    t = t.underline(true, color: Color(underlineColor))
                } else {
                    t = t.underline(true)
                }
            }
            
            self = self + t
            
        }
    }
}
