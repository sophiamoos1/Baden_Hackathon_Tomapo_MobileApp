//
//  BackNavigationBar.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
import PhosphorSwift
 
struct BackNavigationBar: View {
    let title: String
    let onBack: () -> Void
 
    var body: some View {
        HStack {
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
 
                    Ph.arrowFatLeft.duotone
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.theme.softOliveFog)
                }
            }
            Spacer()
        }
        .overlay(
            Text(title)
                .font(.headline)
                .foregroundColor(Color.theme.bodyText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}
 
