//
//  Activity.swift
//  Valeo
//
//  Created by Laurenz Hill on 17.12.20.
//

import Foundation

struct Activity: Equatable {
    
    var id: UUID
    var activity_id: UUID
    var name: String
    var burnPerMinute: Double
    var duration: Int
    
}
