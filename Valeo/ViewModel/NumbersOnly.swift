//
//  NumbersOnly.swift
//  Valeo
//
//  Created by Lori Hill on 10.03.21.
//

import Foundation

class NumbersOnly: ObservableObject {
    @Published var value: String {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            guard let reformed = Int(filtered),
                  reformed > lowerBounds &&
                    reformed < upperBounds else {
                return
            }
            
            if value != filtered {
                value = filtered
            }
            
            if self.number != reformed {
                self.number = reformed
            }
        }
    }
    
    @Published var number: Int {
        didSet {
            self.value = String(self.number)
        }
    }
    
    var lowerBounds: Int
    var upperBounds: Int
    
    init(with value: Int) {
        self.number = value
        self.value = String(value)
        self.lowerBounds = 0
        self.upperBounds = 5000
    }
    
}
