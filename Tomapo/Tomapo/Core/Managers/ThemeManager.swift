//
//  ThemeManager.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var currentScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
}
