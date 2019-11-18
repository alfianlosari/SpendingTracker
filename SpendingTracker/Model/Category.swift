//
//  Category.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 11/17/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation

enum Category: String, CaseIterable, Identifiable, Hashable {
    
    var id: String {
        rawValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
        
    case housing
    case food
    case transportation
    case utilities
    case insurance
    case medical
    case saving
    case investing
    case payment
    case personal
}
