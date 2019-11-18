//
//  BorderedTextModifier.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 11/17/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI

struct BorderedTextModifier: ViewModifier {
    
    let isSelected: Bool
    let selectedTextColor: Color
    let defaultTextColor: Color
    let selectedBackgroundColor: Color
    let defaultBackgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isSelected ? selectedTextColor : defaultTextColor)
            .padding(.all, 8)
            .background(isSelected ? selectedBackgroundColor : defaultBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundColor(selectedBackgroundColor))
    }
}

extension Text {
    
    func bordered(isSelected: Bool, selectedTextColor: Color, defaultTextColor: Color, selectedBackgroundColor: Color, defaultBackgroundColor: Color) -> some View {
        ModifiedContent(content: self, modifier: BorderedTextModifier(isSelected: isSelected, selectedTextColor: selectedTextColor, defaultTextColor: defaultTextColor, selectedBackgroundColor: selectedBackgroundColor, defaultBackgroundColor: defaultBackgroundColor))
    }
}
