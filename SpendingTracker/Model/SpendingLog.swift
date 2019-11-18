//
//  SpendingLog.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation

struct SpendingLog: Identifiable {
    
    let id: String
    let name: String
    let category: Category
    let amount: Double
    let date: Date
    
    init(id: String, name: String, category: Category, amount: Double, date: Date) {
        self.id = id
        self.name = name
        self.category = category
        self.amount = amount
        self.date = date
    }
}

extension SpendingLog: Equatable {}
