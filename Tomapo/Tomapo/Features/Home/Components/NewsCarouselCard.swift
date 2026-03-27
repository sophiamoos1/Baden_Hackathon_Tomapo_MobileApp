//
//  NewsCarouselCard.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
internal import PhosphorSwift

// MARK: - Card
 
struct NewsCarouselCard: View {
    let item: CardItem
 
    @EnvironmentObject private var popupManager: PopupManager
 
    var body: some View {
        ZStack(alignment: .bottomLeading) {
 
            // Hintergrund
            RoundedRectangle(cornerRadius: 20)
                .fill(item.color)
                .frame(width: 220, height: 140)
 
            // Glanz
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220, height: 140)
 
            // Text unten links
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
 
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
            }
            .padding(16)
 
            // Expand-Icon oben rechts
            VStack {
                HStack {
                    Spacer()
                    Button {
                        popupManager.show(item)
                    } label: {
                        Ph.arrowsOut.duotone
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(12)
                    }
                }
                Spacer()
            }
            .frame(width: 220, height: 140)
        }
        .frame(width: 220, height: 140)
        .shadow(color: item.color.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}
 
// MARK: - Preview
 
#Preview {
    NewsCarouselCard(item: CardItem(
        title: "Neue Funktion",
        subtitle: "Entdecke die Produktionskette deiner Lebensmittel",
        color: Color.theme.chartDustyOlive
    ))
    .environmentObject(PopupManager())
    .padding()
    .background(Color.theme.oatMilk)
}
