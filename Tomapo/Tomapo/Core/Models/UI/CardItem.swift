//
//  CardItem.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

// MARK: - Carousel Card Datenmodell

internal import Foundation
internal import SwiftUI

struct CardItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
}
