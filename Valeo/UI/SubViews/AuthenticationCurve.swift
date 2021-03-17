//
//  AuthenticationCurve.swift
//  Valeo
//
//  Created by Lori Hill on 25.02.21.
//

import SwiftUI

struct AuthenticationCurve: Shape {
    
    var axisFactor: CGFloat
    var animatableData: CGFloat {
        get{return axisFactor}
        set{axisFactor = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            
            let center = rect.width / 2
            
            // Begin of curve
            path.move(to: CGPoint(x: -center + axisFactor, y: rect.height))
            
            // Bottomline to begin of wave
            path.addLine(to: CGPoint(x: -100 + axisFactor, y: rect.height))
            
            // Wave up
            let to1 = CGPoint(x: 0 + axisFactor, y: 0)
            let control11 = CGPoint(x: -50 + axisFactor, y: rect.height)
            let control12 = CGPoint(x: -50 + axisFactor, y: 0)
            
            path.addCurve(to: to1, control1: control11, control2: control12)
            
            //TopLine of wave
            path.addLine(to: CGPoint(x: center - 50 + axisFactor, y: 0))
            
            // Wave down
            let to2 = CGPoint(x: center+50 + axisFactor, y: rect.height)
            let control21 = CGPoint(x: center+5 + axisFactor, y: 0)
            let control22 = CGPoint(x: center+5 + axisFactor, y: rect.height)
            
            path.addCurve(to: to2, control1: control21, control2: control22)
            
            // Second bottom line to end
            path.addLine(to: CGPoint(x: rect.width + axisFactor, y: rect.height))
            
        }
    }
    
}
