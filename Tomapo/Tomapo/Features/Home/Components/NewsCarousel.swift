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
            title: "Wo kommt dein Essen her?",
            subtitle: "Scanne einen Barcode und entdecke die Reise deines Produkts",
            color: Color.theme.chartDustyOlive
        ),
        CardItem(
            title: "CO₂ Fussabdruck",
            subtitle: "Sieh auf einen Blick wie klimafreundlich dein Einkauf ist",
            color: Color.theme.chartSoftMossTeal
        ),
        CardItem(
            title: "Bio-Zertifikate",
            subtitle: "Alle Zertifikate und ihre Bedeutung erklärt",
            color: Color.theme.accentTerracotta
        ),
        CardItem(
            title: "Kühlkette prüfen",
            subtitle: "War dein Fisch immer kalt genug? Tomapo weiss es",
            color: Color.theme.chartMutedSkyClay
        ),
        CardItem(
            title: "Laborwerte",
            subtitle: "Pestizide, Schwermetalle, Allergene – alles auf einen Blick",
            color: Color.theme.chartWarmSandAmber
        ),
        CardItem(
            title: "Datenqualität",
            subtitle: "Wir zeigen dir wenn Produktdaten fehlen oder fehlerhaft sind",
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
        .background(Color.theme.oatMilk)
}
