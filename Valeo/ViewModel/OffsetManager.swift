//
//  OffsetManager.swift
//  Valeo
//
//  Created by Laurenz Hill on 14.12.20.
//

import SwiftUI

/// Handles the animation of the calorie circle indicator on the main view.
class OffsetManager: ObservableObject {
    
    @Published var offset: CGFloat = 0
    @Published var defaultOffset: CGFloat = 0
    @Published var hasPlayedCircleAnimation = false
    
}
