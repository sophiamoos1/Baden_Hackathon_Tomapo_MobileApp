//
//  ProductDetailsBoxesView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct ProductDetailBoxesView: View {
    let product: TomapoResponse
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore

    @State private var showStations    = false
    @State private var showIngredients = false
    @State private var showAlerts      = false
    @State private var showInfo        = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "square.grid.2x2.fill").font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
                Text("DETAILS").font(.caption.weight(.semibold)).foregroundColor(Color.theme.bodyText.opacity(0.55)).tracking(0.5)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                // ── 1. Produktionskette ──────────────────────────────────
                DetailBox(
                    icon: "arrow.triangle.branch",
                    title: "Produktionskette",
                    badge: "\(product.stations.count) Stationen",
                    badgeColor: stationsColor,
                    subtitle: product.traceabilityScore.completeness >= 0.8
                        ? "Vollständig rückverfolgbar"
                        : "\(Int(product.traceabilityScore.completeness * 100))% rückverfolgbar",
                    accentColor: .green
                ) { showStations = true }
                .fullScreenCover(isPresented: $showStations) {
                    ProductStationsScreen(product: product, onBack: { showStations = false })
                }

                // ── 2. Inhaltsstoffe ─────────────────────────────────────
                DetailBox(
                    icon: "list.bullet.rectangle",
                    title: "Inhaltsstoffe",
                    badge: ingredientsBadge,
                    badgeColor: additivesColor,
                    subtitle: product.ingredientsText != nil ? "Zutaten vorhanden" : "Keine Daten",
                    accentColor: .blue
                ) { showIngredients = true }
                .fullScreenCover(isPresented: $showIngredients) {
                    ProductIngredientsScreen(product: product, onBack: { showIngredients = false })
                }

                // ── 3. Meldungen ─────────────────────────────────────────
                DetailBox(
                    icon: "exclamationmark.bubble.fill",
                    title: "Meldungen",
                    badge: alertsBadge,
                    badgeColor: alertsColor,
                    subtitle: alertsSubtitle,
                    accentColor: alertsColor
                ) { showAlerts = true }
                .fullScreenCover(isPresented: $showAlerts) {
                    ProductAlertsScreen(product: product, onBack: { showAlerts = false })
                        .environmentObject(userMessageStore)
                }

                // ── 4. Details ───────────────────────────────────────────
                DetailBox(
                    icon: "info.circle.fill",
                    title: "Details",
                    badge: "\(product.certifications.filter(\.isCurrentlyValid).count) Zertifikate",
                    badgeColor: .green,
                    subtitle: "Herkunft, Verpackung, CO₂",
                    accentColor: Color.theme.mutedSage
                ) { showInfo = true }
                .fullScreenCover(isPresented: $showInfo) {
                    ProductInfoScreen(product: product, onBack: { showInfo = false })
                }
            }
        }
    }

    // MARK: - Computed badge helpers

    private var ingredientsBadge: String {
        let n = product.ingredientCount
        let e = product.additivesN ?? 0
        return n > 0 ? "\(n) Zutaten\(e > 0 ? " · \(e) E-Nr." : "")" : "–"
    }

    private var additivesColor: Color {
        let n = product.additivesN ?? 0
        return n > 5 ? Color.theme.warning : n > 0 ? Color.theme.infso : .green
    }

    private var stationsColor: Color {
        product.traceabilityScore.completeness >= 0.8 ? .green
        : product.traceabilityScore.completeness >= 0.5 ? .orange : .red
    }

    private var alertsBadge: String {
        let active = product.activeAlerts.count
        return active > 0 ? "\(active) aktiv" : "Keine Warnungen"
    }

    private var alertsColor: Color {
        guard let sev = product.highestAlertSeverity else { return .green }
        switch sev {
        case .critical: return Color.theme.error
        case .high:     return Color.theme.warning
        case .medium:   return Color.theme.warning
        default:        return Color.theme.infso
        }
    }

    private var alertsSubtitle: String {
        if product.hasActiveRecall { return "Aktiver Rückruf!" }
        let n = product.communityAlertCount
        return n > 0 ? "\(n) Community-Meldung\(n == 1 ? "" : "en")" : "Keine aktiven Warnungen"
    }
}

// MARK: - Detail Box Component

struct DetailBox: View {
    let icon: String
    let title: String
    let badge: String
    let badgeColor: Color
    let subtitle: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(Color.theme.bodyText.opacity(0.3))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(badgeColor)
                        .lineLimit(1)

                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.theme.oatMilk)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(Color.theme.oatMilk.opacity(0.55))
                        .lineLimit(2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.theme.oatMilk)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

