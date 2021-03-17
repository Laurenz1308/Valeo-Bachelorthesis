//
//  HitsListController.swift
//  Valeo
//
//  Created by Lori Hill on 26.01.21.
//

import Foundation
import InstantSearch

/// Class to manage Algolia dynamic search.
class HitsListController: ObservableObject, HitsController {
        
    public weak var hitsSource: HitsInteractor<NutrientBase>?
    
    @Published var allNutrients: [NutrientBase] = []
    
    public func reload() {
        self.allNutrients = hitsSource!.getCurrentHits()
    }
    
    public func scrollToTop() {
    }
    
}
