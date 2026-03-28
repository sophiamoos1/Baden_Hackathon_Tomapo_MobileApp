//
//  NewsCarousel.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct NewsCarousel: View {

    // Platzhalter-Karten mit Theme-Farben
    private let items: [CardItem] = [
        CardItem(
            title: "Where does your food come from?",
            subtitle: "Scan a barcode and discover your product's journey",
            color: Color.theme.chartDustyOlive
        ),
        CardItem(
            title: "CO₂ Footprint",
            subtitle: "See at a glance how climate-friendly your shopping is",
            color: Color.theme.chartSoftMossTeal
        ),
        CardItem(
            title: "Organic Certificates",
            subtitle: "All certificates and their meaning explained",
            color: Color.theme.accentFg
        ),
        CardItem(
            title: "Check Cold Chain",
            subtitle: "Was your fish always cold enough? Tomapo knows",
            color: Color.theme.chartMutedSkyClay
        ),
        CardItem(
            title: "Lab Results",
            subtitle: "Pesticides, heavy metals, allergens – all at a glance",
            color: Color.theme.chartWarmSandAmber
        ),
        CardItem(
            title: "Data Quality",
            subtitle: "We show you when product data is missing or incorrect",
            color: Color.theme.chartTerracottaRose
        ),
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(items) { item in
                    NewsCarouselCard(item: item)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)   // Platz für Schatten der Karten
        }
    }
}

// MARK: - Preview

#Preview {
    NewsCarousel()
        .background(Color.theme.cardBg)
}
