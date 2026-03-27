//
//  PopupManager.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//


internal import SwiftUI
internal import Combine

final class PopupManager: ObservableObject {
    @Published var activeItem: CardItem? = nil
 
    func show(_ item: CardItem) {
        activeItem = item
    }
 
    func dismiss() {
        activeItem = nil
    }
 
    var isShowing: Bool { activeItem != nil }
}

