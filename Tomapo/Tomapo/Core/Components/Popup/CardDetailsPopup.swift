//
//  CardDetailsPopup.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
internal import PhosphorSwift
 
struct CardDetailsPopup: View {
    let item: CardItem
    let onClose: () -> Void
 
    var body: some View {
        ZStack {
 
            // MARK: – Dimming
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }
 
            // MARK: – Panel (zentriert, Abstand zu allen 4 Rändern)
            VStack(spacing: 0) {
 
                // Minimize-Button oben rechts
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .fill(Color.theme.cardBg)
                                .frame(width: 36, height: 36)
                            Ph.arrowsIn.duotone
                                .frame(width: 18, height: 18)
                                .foregroundStyle(Color.theme.cardFg)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
 
                // Illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [item.color.opacity(0.75), item.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Ph.image.duotone
                                .frame(width: 54, height: 54)
                                .foregroundStyle(Color.white.opacity(0.9))
                        )
                        .shadow(color: item.color.opacity(0.35), radius: 16, x: 0, y: 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 24)
 
                // Titel
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.cardFg)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
 
                // Beschreibung
                Text(item.subtitle)
                    .font(.body)
                    .foregroundColor(Color.theme.cardFg)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
            }
            .background(
                Color.theme.cardBg
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
            )
            // Abstand zu allen 4 Seiten
            .padding(.horizontal, 24)
            .padding(.vertical, 60)
        }
    }
}
 
// MARK: - Preview
 
#Preview {
    ZStack {
        GeometryReader { geo in
            Image("TomapBackground")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .ignoresSafeArea()
 
        CardDetailsPopup(
            item: CardItem(
                title: "Wo kommt dein Essen her?",
                subtitle: "Scanne einen Barcode und entdecke die vollständige Reise deines Produkts – vom Feld bis in deinen Einkaufskorb.",
                color: Color.theme.chartDustyOlive
            ),
            onClose: {}
        )
    }
}
