//
//  Gender.swift
//  Valeo
//
//  Created by Lori Hill on 15.01.21.
//

import Foundation

enum Gender: String, CaseIterable, Identifiable {
    case male
    case female
    case divers
    
    var id: String { self.rawValue }
}
