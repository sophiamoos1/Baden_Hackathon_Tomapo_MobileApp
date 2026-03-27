//
//  ScanResultSheetView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI

// MARK: - ViewModel

@MainActor
final class ScanResultViewModel: ObservableObject {
    @Published var offState: OFFApiState = .idle
    @Published var tomapoTrace: TomapoResponse? = nil

    // ── Echter OFF API-Call (auskommentiert) ──────────────────────────
    // func loadProduct(barcode: String, barcodeType: String, store: ScanHistoryStore) async {
    //     offState = .loading
    //     let result = await OFFFoodService.shared.fetchProduct(barcode: barcode)
    //     switch result {
    //     case .success(let response):
    //         offState = response.product != nil ? .found(response) : .notFound
    //         if let product = response.product {
    //             store.add(barcode: barcode, productName: product.productName,
    //                       brand: product.brands, barcodeType: barcodeType)
    //         }
    //     case .failure(let error):
    //         offState = .error(error)
    //     }
    //     tomapoTrace = await TomapoService.shared.fetchTrace(barcode: barcode)
    // }

    // ── Mock-Variante ─────────────────────────────────────────────────
    func loadProduct(barcode: String, barcodeType: String = "EAN13", store: ScanHistoryStore) async {
        offState = .loading
        try? await Task.sleep(nanoseconds: 600_000_000)

        let demoBarcode = TomapoMockData.trace(for: barcode) != nil ? barcode : "4316268651288"
        tomapoTrace = TomapoMockData.trace(for: demoBarcode)
        let response = OFFMockProducts.response(for: demoBarcode)
        offState = .found(response)

        // Scan direkt in den Store schreiben
        store.add(
            barcode: barcode,
            barcodeType: barcodeType, productName: response.product?.productName,
            brand: response.product?.brands
        )
    }
}

// MARK: - Haupt-Sheet

struct ScanResultSheetView2: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ScanResultViewModel()
    @EnvironmentObject private var historyStore: ScanHistoryStore

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.theme.bottomBarBackground)
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.theme.secondaryText)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Produkt erkannt")
                        .font(.headline)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
        }
        .task {
            await vm.loadProduct(
                barcode: result.value,
                barcodeType: result.type,
                store: historyStore
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.offState {
        case .idle, .loading:
            loadingView
        case .notFound:
            notFoundView
        case .error(let e):
            errorView(e)
        case .found(let response):
            if let product = response.product {
                productSheet(product: product, trace: vm.tomapoTrace)
            } else {
                notFoundView
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.theme.secondaryText)
            Text("Produkt wird geladen…")
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundColor(Color.theme.secondaryText.opacity(0.3))
            Text("Produkt nicht gefunden")
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
            Text(result.value)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: OFFApiError) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundColor(Color.theme.secondaryText.opacity(0.4))
            Text("Ladefehler")
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
            Text(error.localizedDescription ?? "Unbekannter Fehler")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Product Sheet Content

private struct productSheet: View {
    let product: OFFProduct
    let trace: TomapoResponse?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Hero Header ────────────────────────────────────────
                ProductHeroHeader(product: product, trace: trace)
                    .padding(.bottom, 8)

                // ── Rückruf-Banner (wenn aktiv) ────────────────────────
                if let recall = trace?.recallStatus, recall.isRecalled || recall.severity != .none {
                    RecallBanner(recall: recall)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }

                // ── Datenqualitäts-Banner ──────────────────────────────
                if product.hasDataErrors {
                    DataQualityBanner(errors: product.dataQualityErrorsTags ?? [])
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }

                VStack(alignment: .leading, spacing: 20) {

                    // ── Score-Übersicht ────────────────────────────────
                    ScoreTripletSection(product: product)

                    // ── Nährwerte ──────────────────────────────────────
                    if let n = product.nutriments, product.hasReliableNutritionData {
                        NutritionSection(nutriments: n, product: product)
                    }

                    // ── Zutaten ────────────────────────────────────────
                    if let text = product.ingredientsText, !text.isEmpty {
                        IngredientsSection(product: product, text: text)
                    }

                    // ── Allergene & Spuren ─────────────────────────────
                    if let allergens = product.allergensTags, !allergens.isEmpty {
                        AllergenSection(allergens: allergens, traces: product.tracesTags ?? [])
                    }

                    // ── Umwelt & Nachhaltigkeit ────────────────────────
                    if let env = trace?.environmentSummary {
                        EnvironmentSection(env: env, certs: trace?.certifications ?? [])
                    }

                    // ── Produktionskette ───────────────────────────────
                    if let stations = trace?.stations, !stations.isEmpty {
                        TraceabilitySection(trace: trace!)
                    }

                    // ── Herkunft & Produktion ──────────────────────────
                    OriginSection(product: product)

                    // ── Verpackung ─────────────────────────────────────
                    if let pkgs = product.packagings, !pkgs.isEmpty {
                        PackagingSection(packagings: pkgs, text: product.packagingText)
                    }

                    // ── Lagerung ───────────────────────────────────────
                    if let storage = product.conservationConditions, !storage.isEmpty {
                        StorageSection(text: storage)
                    }

                    // ── Datenqualität ──────────────────────────────────
                    DataQualitySection(product: product, trace: trace)

                    // ── Barcode Info ───────────────────────────────────
                    BarcodeInfoSection(barcode: product.code)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Hero Header

private struct ProductHeroHeader: View {
    let product: OFFProduct
    let trace: TomapoResponse?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                // Produktbild Placeholder
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.theme.bottomBarBackground)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: productIcon)
                            .font(.system(size: 28))
                            .foregroundColor(Color.theme.secondaryText.opacity(0.3))
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text(product.productName ?? "Unbekanntes Produkt")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color.theme.secondaryText)
                        .lineLimit(2)

                    if let brands = product.brands {
                        Text(brands)
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.6))
                    }

                    if let qty = product.quantity {
                        Text(qty)
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                    }

                    // Traceability Score Pill
                    if let ts = trace?.traceabilityScore {
                        TraceabilityPill(score: ts)
                            .padding(.top, 2)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    private var productIcon: String {
        let cats = product.categoriesTags ?? []
        if cats.contains(where: { $0.contains("water") }) { return "drop.fill" }
        if cats.contains(where: { $0.contains("fish") || $0.contains("seafood") }) { return "fish.fill" }
        if cats.contains(where: { $0.contains("egg") }) { return "circle.fill" }
        if cats.contains(where: { $0.contains("beverage") || $0.contains("soda") }) { return "cup.and.saucer.fill" }
        if cats.contains(where: { $0.contains("chocolate") || $0.contains("sweet") }) { return "birthday.cake.fill" }
        if cats.contains(where: { $0.contains("meat") || $0.contains("poultry") }) { return "fork.knife" }
        return "cart.fill"
    }
}

// MARK: - Recall Banner

private struct RecallBanner: View {
    let recall: TomapoRecallStatus

    private var bannerColor: Color {
        switch recall.severity {
        case .critical: return Color.theme.error
        case .warning:  return Color.theme.warning
        case .advisory: return Color.theme.warning.opacity(0.75)
        default:        return Color.theme.infso
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: recall.severity == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(bannerColor)
                Text(recall.severity == .critical ? "RÜCKRUF" : recall.severity == .advisory ? "Datenwarnung" : "Hinweis")
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(bannerColor)
                Spacer()
                if let by = recall.issuedBy {
                    Text(by).font(.caption2).foregroundColor(bannerColor.opacity(0.7))
                }
            }
            if let reason = recall.reason {
                Text(reason)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let action = recall.actionRequired {
                Text("➜ \(action)")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(bannerColor)
            }
        }
        .padding(12)
        .background(bannerColor.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(bannerColor.opacity(0.3), lineWidth: 1))
        .cornerRadius(12)
    }
}

// MARK: - Data Quality Banner

private struct DataQualityBanner: View {
    let errors: [String]

    private func label(for tag: String) -> String {
        if tag.contains("salt") { return "⚠ Salzwert unplausibel (>100g/100g)" }
        if tag.contains("energy") { return "⚠ Energiewert stimmt nicht mit Makros überein" }
        if tag.contains("over-105") { return "⚠ Nährwertsumme > 105g/100g" }
        return "⚠ \(tag.replacingOccurrences(of: "en:", with: ""))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.theme.warning)
                    .font(.caption)
                Text("Datenfehler in Open Food Facts")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(Color.theme.warning)
            }
            ForEach(errors, id: \.self) { e in
                Text(label(for: e))
                    .font(.caption2)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.7))
            }
            Text("Nährwertangaben auf Verpackung prüfen.")
                .font(.caption2)
                .foregroundColor(Color.theme.secondaryText.opacity(0.5))
        }
        .padding(12)
        .background(Color.theme.warning.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.warning.opacity(0.25), lineWidth: 1))
        .cornerRadius(12)
    }
}

// MARK: - Score Triplet

private struct ScoreTripletSection: View {
    let product: OFFProduct

    var body: some View {
        SheetSection(title: "Bewertungen", icon: "chart.bar.fill") {
            HStack(spacing: 12) {
                ScorePill(label: "Nutri", grade: product.nutriscoreGrade, style: .nutri)
                ScorePill(label: "Eco", grade: product.ecoscoreGrade, style: .eco)
                ScorePill(label: "NOVA", grade: product.novaGroup.map { "\($0)" }, style: .nova)
                Spacer()
            }

            // NOVA Erklärung
            if let nova = product.novaGroup {
                let group = OFFNovaGroup(rawValue: nova, error: product.novaGroupError)
                if group.isKnown {
                    Text("NOVA \(nova) – \(group.label)")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.55))
                }
            } else if product.novaGroupError == "missing_ingredients" {
                Text("NOVA nicht berechenbar – Zutaten fehlen")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.45))
            }
            if product.ecoscoreGrade == "not-applicable" {
                Text("Eco-Score gilt nicht für diese Kategorie")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.45))
            }
        }
    }
}

private struct ScorePill: View {
    let label: String
    let grade: String?
    let style: ScoreStyle

    enum ScoreStyle { case nutri, eco, nova }

    private var displayGrade: String { grade?.uppercased() ?? "?" }
    private var bgColor: Color {
        let g = grade?.lowercased()
        switch g {
        case "a": return Color.green.opacity(0.85)
        case "b": return Color(red: 0.53, green: 0.77, blue: 0.15)
        case "c": return Color.orange.opacity(0.8)
        case "d": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "e": return Color.red.opacity(0.85)
        case "not-applicable": return Color.theme.bottomBarBackground
        case "unknown", nil: return Color.theme.bottomBarBackground
        default:
            if style == .nova, let n = Int(grade ?? "") {
                switch n {
                case 1: return Color.green.opacity(0.8)
                case 2: return Color(red: 0.53, green: 0.77, blue: 0.15)
                case 3: return Color.orange.opacity(0.8)
                case 4: return Color.red.opacity(0.85)
                default: return Color.theme.bottomBarBackground
                }
            }
            return Color.theme.bottomBarBackground
        }
    }
    private var textColor: Color {
        let g = grade?.lowercased()
        if g == "unknown" || g == "not-applicable" || g == nil { return Color.theme.secondaryText.opacity(0.5) }
        return .white
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(bgColor)
                    .frame(width: 44, height: 44)
                Text(displayGrade == "NOT-APPLICABLE" ? "N/A" : displayGrade)
                    .font(.system(size: displayGrade.count > 2 ? 10 : 18, weight: .black))
                    .foregroundColor(textColor)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(Color.theme.secondaryText.opacity(0.55))
        }
    }
}

// MARK: - Nutrition Section

private struct NutritionSection: View {
    let nutriments: OFFNutriments
    let product: OFFProduct

    var body: some View {
        SheetSection(title: "Nährwerte pro 100g", icon: "fork.knife") {
            VStack(spacing: 0) {
                NutriRow(name: "Energie", value: nutriments.energyKcal100g, unit: "kcal",
                         level: nil, isHeader: true)
                Divider().padding(.leading, 16)
                NutriRow(name: "Fett", value: nutriments.fat100g, unit: "g",
                         level: product.nutrientLevels?.fat)
                Divider().padding(.leading, 16)
                NutriRow(name: "  davon gesättigte Fettsäuren",
                         value: nutriments.saturatedFat100g, unit: "g",
                         level: product.nutrientLevels?.saturatedFat, isSubRow: true)
                Divider().padding(.leading, 16)
                NutriRow(name: "Kohlenhydrate", value: nutriments.carbohydrates100g, unit: "g",
                         level: nil)
                Divider().padding(.leading, 16)
                NutriRow(name: "  davon Zucker", value: nutriments.sugars100g, unit: "g",
                         level: product.nutrientLevels?.sugars, isSubRow: true)
                if let fiber = nutriments.fiber100g, fiber > 0 {
                    Divider().padding(.leading, 16)
                    NutriRow(name: "Ballaststoffe", value: fiber, unit: "g", level: nil)
                }
                Divider().padding(.leading, 16)
                NutriRow(name: "Proteine", value: nutriments.proteins100g, unit: "g",
                         level: nil)
                Divider().padding(.leading, 16)
                NutriRow(name: "Salz", value: nutriments.salt100g, unit: "g",
                         level: product.nutrientLevels?.salt,
                         hasSuspicion: nutriments.hasSuspiciousSaltValue)
            }
            .background(Color.theme.bottomBarBackground)
            .cornerRadius(12)

            if let serving = product.servingSize {
                Text("Portionsgrösse: \(serving)")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.45))
            }
        }
    }
}

private struct NutriRow: View {
    let name: String
    let value: Double?
    let unit: String
    var level: String? = nil
    var isHeader: Bool = false
    var isSubRow: Bool = false
    var hasSuspicion: Bool = false

    private var trafficDot: Color? {
        switch level {
        case "low":    return Color.green
        case "moderate": return Color.orange
        case "high":   return Color.red
        default: return nil
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            if let dot = trafficDot {
                Circle().fill(dot).frame(width: 7, height: 7)
            }
            Text(name)
                .font(isHeader ? .subheadline.weight(.semibold) : isSubRow ? .caption : .subheadline)
                .foregroundColor(Color.theme.secondaryText.opacity(isSubRow ? 0.65 : 1.0))
            Spacer()
            if hasSuspicion {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundColor(Color.theme.warning)
            }
            if let v = value {
                Text("\(String(format: v >= 10 ? "%.1f" : "%.2f", v)) \(unit)")
                    .font(isHeader ? .subheadline.weight(.semibold) : .subheadline)
                    .foregroundColor(hasSuspicion ? Color.theme.warning : Color.theme.secondaryText)
            } else {
                Text("–")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.35))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, isSubRow ? 8 : 11)
    }
}

// MARK: - Ingredients Section

private struct IngredientsSection: View {
    let product: OFFProduct
    let text: String
    @State private var expanded = false

    var body: some View {
        SheetSection(title: "Zutaten", icon: "list.bullet") {
            VStack(alignment: .leading, spacing: 10) {
                Text(text)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.75))
                    .lineLimit(expanded ? nil : 4)
                    .animation(.easeInOut(duration: 0.2), value: expanded)

                Button(expanded ? "Weniger anzeigen" : "Alle Zutaten") {
                    expanded.toggle()
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(Color.theme.secondaryText.opacity(0.55))

                // Diät-Tags
                HStack(spacing: 8) {
                    DietBadge(label: "Vegan", status: product.veganStatus)
                    if product.isGlutenFree {
                        PillBadge(label: "Glutenfrei", color: .blue)
                    }
                    if product.containsPalmOil {
                        PillBadge(label: "Palmöl", color: .orange)
                    }
                    if product.isOrganic {
                        PillBadge(label: "Bio", color: .green)
                    }
                    Spacer()
                }

                if let n = product.additivesN, n > 0 {
                    Text("\(n) Zusatzstoffe (E-Nummern)")
                        .font(.caption)
                        .foregroundColor(n > 3 ? Color.theme.warning : Color.theme.secondaryText.opacity(0.55))
                }
            }
        }
    }
}

private struct DietBadge: View {
    let label: String
    let status: OFFDietStatus

    private var color: Color {
        switch status {
        case .yes: return .green
        case .no: return .red
        case .maybe: return .orange
        case .unknown: return Color.theme.secondaryText.opacity(0.3)
        }
    }
    private var icon: String {
        switch status {
        case .yes: return "checkmark"
        case .no: return "xmark"
        case .maybe: return "questionmark"
        case .unknown: return "minus"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(label)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(color.opacity(0.12))
        .cornerRadius(20)
    }
}

private struct PillBadge: View {
    let label: String
    let color: Color
    var body: some View {
        Text(label)
            .font(.caption2)
            .foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .cornerRadius(20)
    }
}

// MARK: - Allergen Section

private struct AllergenSection: View {
    let allergens: [String]
    let traces: [String]

    private func format(_ tag: String) -> String {
        tag.replacingOccurrences(of: "en:", with: "")
           .replacingOccurrences(of: "-", with: " ")
           .capitalized
    }

    var body: some View {
        SheetSection(title: "Allergene & Spuren", icon: "exclamationmark.shield.fill") {
            VStack(alignment: .leading, spacing: 10) {
                FlexTagCloud(tags: allergens.map { format($0) }, color: Color.theme.error)
                if !traces.isEmpty {
                    Text("Kann Spuren enthalten")
                        .font(.caption2)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                    FlexTagCloud(tags: traces.map { format($0) }, color: Color.theme.warning)
                }
            }
        }
    }
}

// MARK: - Environment Section

private struct EnvironmentSection: View {
    let env: TomapoEnvironmentSummary
    let certs: [TomapoCertification]

    var body: some View {
        SheetSection(title: "Umwelt & Nachhaltigkeit", icon: "leaf.fill") {
            VStack(spacing: 12) {

                // CO₂-Fussabdruck
                if let total = env.co2TotalKgPerKg {
                    CO2BarView(total: total, phases: env.co2ByPhase)
                } else if env.ecoscoreGrade == "not-applicable" {
                    PlaceholderRow(text: "Eco-Score nicht anwendbar für diese Produktkategorie")
                } else {
                    PlaceholderRow(text: "CO₂-Daten nicht verfügbar")
                }

                Divider()

                // Kennzahlen Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    if let water = env.waterFootprintLiterPerKg {
                        EnvMetricCard(icon: "drop.fill", label: "Wasserverbrauch",
                                      value: "\(Int(water)) L/kg",
                                      color: .blue)
                    }
                    if let forest = env.forestFootprintM2PerKg {
                        EnvMetricCard(icon: "tree.fill", label: "Wald-Fussabdruck",
                                      value: "\(String(format: "%.1f", forest)) m²/kg",
                                      color: .green)
                    }
                    if let dist = env.totalTransportDistanceKm {
                        EnvMetricCard(icon: "location.fill", label: "Transportweg",
                                      value: "\(Int(dist)) km",
                                      color: Color.theme.secondaryText)
                    }
                    if let recycle = env.recyclablePackagingPercent {
                        EnvMetricCard(icon: "arrow.3.trianglepath", label: "Recyclebar",
                                      value: "\(Int(recycle))%",
                                      color: .green)
                    }
                }

                // Bedrohte Arten-Warnung
                if let risk = env.threatenedSpeciesRisk {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color.theme.warning)
                            .font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Artenbedrohungsrisiko")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color.theme.secondaryText)
                            if let exp = risk.explanation {
                                Text(exp)
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.secondaryText.opacity(0.65))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.theme.warning.opacity(0.08))
                    .cornerRadius(10)
                }

                // Zertifikate
                if !certs.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Zertifikate")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.55))
                        FlexTagCloud(tags: certs.map { $0.name }, color: .green)
                    }
                }
            }
        }
    }
}

private struct CO2BarView: View {
    let total: Double
    let phases: CO2ByPhase

    private var phaseData: [(String, Double, Color)] {
        let rows: [(String, Double, Color)] = [
            ("Landwirtschaft", phases.agriculture ?? 0, Color.green.opacity(0.8)),
            ("Verarbeitung",   phases.processing ?? 0,  Color.orange.opacity(0.8)),
            ("Transport",      phases.transportation ?? 0, Color.blue.opacity(0.8)),
            ("Verpackung",     phases.packaging ?? 0,   Color.purple.opacity(0.7)),
            ("Distribution",   phases.distribution ?? 0, Color.pink.opacity(0.7)),
        ]
        return rows.filter { $0.1 > 0 }
    }

    private var co2Label: String {
        total < 1 ? "\(String(format: "%.2f", total)) kg" : "\(String(format: "%.1f", total)) kg"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CO₂ Fussabdruck")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.secondaryText)
                Spacer()
                Text("\(co2Label) CO₂eq/kg")
                    .font(.caption.weight(.bold))
                    .foregroundColor(co2Color)
            }

            // Segmented Bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(phaseData, id: \.0) { name, val, color in
                        let width = max(4, geo.size.width * (val / total))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: width)
                    }
                }
            }
            .frame(height: 10)
            .cornerRadius(5)

            // Legende
            FlowLegend(items: phaseData.map { ($0.0, $0.1, $0.2) })
        }
    }

    private var co2Color: Color {
        if total < 1 { return .green }
        if total < 3 { return .orange }
        return .red
    }
}

private struct FlowLegend: View {
    let items: [(String, Double, Color)]
    var body: some View {
        FlexLayout {
            ForEach(items, id: \.0) { name, val, color in
                HStack(spacing: 4) {
                    Circle().fill(color).frame(width: 7, height: 7)
                    Text("\(name): \(String(format: "%.2f", val))kg")
                        .font(.caption2)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.65))
                }
            }
        }
    }
}

private struct EnvMetricCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.55))
                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.secondaryText)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.theme.bottomBarBackground)
        .cornerRadius(10)
    }
}

// MARK: - Traceability Section

private struct TraceabilitySection: View {
    let trace: TomapoResponse

    var body: some View {
        SheetSection(title: "Produktionskette", icon: "arrow.triangle.branch") {
            VStack(alignment: .leading, spacing: 12) {
                // Traceability Score Header
                TraceabilityScoreBar(score: trace.traceabilityScore)

                // Timeline – delegiert an TomapoStationTimeline2
                TomapoStationTimeline2(stations: trace.stations)
            }
        }
    }
}

private struct TraceabilityScoreBar: View {
    let score: TomapoTraceabilityScore

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.theme.secondaryText.opacity(0.15), lineWidth: 4)
                    .frame(width: 40, height: 40)
                Circle()
                    .trim(from: 0, to: score.completeness)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(score.completeness * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.theme.secondaryText)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Rückverfolgbarkeit")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.secondaryText)
                HStack(spacing: 8) {
                    if score.verifiedStations > 0 {
                        Text("\(score.verifiedStations) verifiziert")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    if score.unknownStations > 0 {
                        Text("\(score.unknownStations) unbekannt")
                            .font(.caption2)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                    }
                    if score.hasGaps {
                        Text("Lücken vorhanden")
                            .font(.caption2)
                            .foregroundColor(Color.theme.warning)
                    }
                }
            }
            Spacer()

            if score.isThirdPartyVerified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding(10)
        .background(Color.theme.bottomBarBackground)
        .cornerRadius(10)
    }

    private var scoreColor: Color {
        score.completeness >= 0.8 ? .green : score.completeness >= 0.5 ? .orange : .red
    }
}

// MARK: - Origin Section

private struct OriginSection: View {
    let product: OFFProduct

    var body: some View {
        SheetSection(title: "Herkunft & Produktion", icon: "globe.europe.africa.fill") {
            VStack(spacing: 0) {
                if let origins = product.originsTags, !origins.isEmpty {
                    InfoRow(label: "Ursprung",
                            value: origins.map { fmt($0) }.joined(separator: ", "))
                    Divider().padding(.leading, 16)
                }
                if let countries = product.countriesTags, !countries.isEmpty {
                    InfoRow(label: "Verkaufsland",
                            value: countries.map { fmt($0) }.joined(separator: ", "))
                    Divider().padding(.leading, 16)
                }
                if let mfg = product.manufacturingPlaces, !mfg.isEmpty {
                    InfoRow(label: "Herstellungsort", value: mfg)
                    Divider().padding(.leading, 16)
                }
                if let stores = product.storesTags, !stores.isEmpty {
                    InfoRow(label: "Erhältlich bei",
                            value: stores.prefix(4).map { fmt($0) }.joined(separator: ", "))
                }
                if product.isOrganic {
                    Divider().padding(.leading, 16)
                    InfoRow(label: "Produktion", value: "Bio-zertifiziert (EU-Öko-VO)")
                }
            }
            .background(Color.theme.bottomBarBackground)
            .cornerRadius(12)
        }
    }

    private func fmt(_ tag: String) -> String {
        tag.replacingOccurrences(of: "en:", with: "")
           .replacingOccurrences(of: "de:", with: "")
           .replacingOccurrences(of: "fr:", with: "")
           .replacingOccurrences(of: "-", with: " ")
           .capitalized
    }
}

// MARK: - Packaging Section

private struct PackagingSection: View {
    let packagings: [OFFPackaging]
    let text: String?

    private func fmt(_ s: String?) -> String {
        (s ?? "–").replacingOccurrences(of: "en:", with: "")
                   .replacingOccurrences(of: "-", with: " ")
                   .capitalized
    }

    var body: some View {
        SheetSection(title: "Verpackung", icon: "shippingbox.fill") {
            VStack(spacing: 0) {
                ForEach(Array(packagings.enumerated()), id: \.offset) { i, pkg in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(fmt(pkg.shape))
                                .font(.subheadline)
                                .foregroundColor(Color.theme.secondaryText)
                            Text(fmt(pkg.material))
                                .font(.caption)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.55))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if let r = pkg.recycling {
                                Text(r.contains("recycle") ? "♻ Recyclebar" : "Nicht recyclebar")
                                    .font(.caption2)
                                    .foregroundColor(r.contains("recycle") ? .green : .red)
                            }
                            if let w = pkg.weightMeasured {
                                Text("\(String(format: "%.1f", w))g")
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if i < packagings.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color.theme.bottomBarBackground)
            .cornerRadius(12)

            if let t = text, !t.isEmpty {
                Text(t)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.5))
            }
        }
    }
}

// MARK: - Storage Section

private struct StorageSection: View {
    let text: String
    var body: some View {
        SheetSection(title: "Lagerung", icon: "thermometer.medium") {
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText.opacity(0.8))
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.bottomBarBackground)
                .cornerRadius(12)
        }
    }
}

// MARK: - Data Quality Section

private struct DataQualitySection: View {
    let product: OFFProduct
    let trace: TomapoResponse?

    private func completenessColor(_ c: Double) -> Color {
        c >= 0.8 ? .green : c >= 0.5 ? .orange : .red
    }

    var body: some View {
        SheetSection(title: "Datenqualität", icon: "checkmark.shield") {
            VStack(spacing: 0) {
                if let c = product.completeness {
                    InfoRow(label: "OFF-Vollständigkeit",
                            value: "\(Int(c * 100))%",
                            valueColor: completenessColor(c))
                    Divider().padding(.leading, 16)
                }
                if let sources = trace?.dataSources, !sources.isEmpty {
                    InfoRow(label: "Datenquellen",
                            value: sources.map { $0.name }.joined(separator: ", "))
                    Divider().padding(.leading, 16)
                }
                if let editor = product.lastEditor {
                    InfoRow(label: "Letzter Bearbeiter", value: editor)
                }
                if !(product.dataQualityWarningsTags?.isEmpty ?? true) {
                    Divider().padding(.leading, 16)
                    InfoRow(label: "Warnungen",
                            value: "\(product.dataQualityWarningsTags!.count) Hinweise",
                            valueColor: Color.theme.warning)
                }
            }
            .background(Color.theme.bottomBarBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Barcode Info Section

private struct BarcodeInfoSection: View {
    let barcode: String
    @State private var copied = false
    var body: some View {
        SheetSection(title: "Barcode", icon: "barcode") {
            HStack {
                Text(barcode)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(Color.theme.secondaryText)
                Spacer()
                Button {
                    UIPasteboard.general.string = barcode
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                }
            }
            .padding(14)
            .background(Color.theme.bottomBarBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Traceability Pill

private struct TraceabilityPill: View {
    let score: TomapoTraceabilityScore
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: score.isThirdPartyVerified ? "checkmark.seal.fill" : "clock.fill")
                .font(.caption2)
                .foregroundColor(pillColor)
            Text("\(Int(score.completeness * 100))% rückverfolgbar")
                .font(.caption2)
                .foregroundColor(pillColor)
        }
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(pillColor.opacity(0.12))
        .cornerRadius(20)
    }
    private var pillColor: Color {
        score.completeness >= 0.8 ? .green : score.completeness >= 0.5 ? .orange : .red
    }
}

// MARK: - Shared UI Components

struct SheetSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.secondaryText.opacity(0.55))
                    .tracking(0.5)
            }
            content()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = Color.theme.secondaryText

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText.opacity(0.6))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16).padding(.vertical, 11)
    }
}

struct PlaceholderRow: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(Color.theme.secondaryText.opacity(0.4))
            .padding(.vertical, 4)
    }
}

// MARK: - FlexTagCloud

struct FlexTagCloud: View {
    let tags: [String]
    let color: Color

    /// Reihenfolge-stabile Deduplizierung:
    /// NSOrderedSet würde die Reihenfolge nicht garantieren –
    /// daher manuell mit reduce über ein Set als Duplikat-Filter.
    private var uniqueTags: [String] {
        tags.reduce(into: (seen: Set<String>(), result: [String]())) { acc, tag in
            guard !acc.seen.contains(tag) else { return }
            acc.seen.insert(tag)
            acc.result.append(tag)
        }.result
    }

    var body: some View {
        FlexLayout {
            ForEach(uniqueTags, id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .foregroundColor(color)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(20)
            }
        }
    }
}

// MARK: - FlexLayout (simple wrap layout)

struct FlexLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowH: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0; y += rowH + spacing; rowH = 0
            }
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowH: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowH + spacing; rowH = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
    }
}

// MARK: - OFF Mock Products (bis echte API eingebunden)

enum OFFMockProducts {
    static func response(for barcode: String) -> OFFApiResponse {
        OFFApiResponse(code: barcode, status: 1, statusVerbose: "product found",
                       product: product(for: barcode))
    }

    private static func product(for barcode: String) -> OFFProduct? {
        switch barcode {
        case "4316268651288":
            return OFFProduct(
                code: barcode, productName: "BioBio Bio-Eier Freilandhaltung 10 Stück",
                genericName: "Bio-Freilandeier", brands: "BioBio", quantity: "10 Stück",
                productQuantity: 10, productQuantityUnit: "Stück",
                servingSize: "63g (1 Ei)", servingQuantity: 63,
                storesTags: ["netto-marken-discount"],
                imageUrl: nil, imageFrontUrl: nil, imageIngredientsUrl: nil,
                imageNutritionUrl: nil, imagePackagingUrl: nil,
                categoriesTags: ["en:eggs", "en:hen-eggs", "en:free-range-eggs"],
                foodGroupsTags: ["en:eggs"], foodGroups: "en:eggs",
                pnnsGroups1: "Fish Meat Eggs", pnnsGroups2: "Eggs",
                nutriscoreGrade: "a", nutriscoreScore: -4,
                ecoscoreGrade: "b", ecoscoreScore: 65,
                novaGroup: 1, novaGroupError: nil,
                nutriments: OFFNutriments(
                    energyKcal100g: 147, energyKj100g: 614,
                    energyKcalServing: 93, energyKjServing: 388,
                    fat100g: 10.6, saturatedFat100g: 3.1,
                    fatServing: 6.7, saturatedFatServing: 2.0,
                    carbohydrates100g: 0.4, sugars100g: 0.4,
                    fiber100g: 0, addedSugars100g: nil, starch100g: nil,
                    carbohydratesServing: 0.3, sugarsServing: 0.3, fiberServing: nil,
                    proteins100g: 12.7, proteinsServing: 8.0,
                    salt100g: 0.36, sodium100g: 0.14,
                    saltServing: 0.23, sodiumServing: 0.09, novaGroup100g: 1),
                nutrientLevels: OFFNutrientLevels(
                    fat: "moderate", saturatedFat: "moderate",
                    sugars: "low", salt: "low"),
                ingredientsText: "Bio-Freilandeier",
                ingredients: nil, ingredientsN: 1, additivesN: 0,
                additivesTags: [],
                allergensTags: ["en:eggs"], tracesTags: [],
                ingredientsAnalysisTags: ["en:vegan-status-unknown"],
                labelsTags: ["en:organic","en:eu-organic","en:no-gmos","en:fsc","en:de-oko-005"],
                countriesTags: ["en:germany"], originsTags: ["en:germany"],
                manufacturingPlaces: "Sulingen, Niedersachsen, DE",
                manufacturingPlacesTags: ["en:germany"],
                packagingTags: ["en:paperboard","en:recycled-materials"],
                packagings: [OFFPackaging(
                    material: "en:paperboard", shape: "en:egg-box",
                    recycling: "en:recycle-in-sorting-bin",
                    weightMeasured: 46, numberOfUnits: 10,
                    quantityPerUnit: "1 Ei", foodContact: 1,
                    nonRecyclableAndNonBiodegradable: "no",
                    environmentalScoreMaterialScore: 92)],
                packagingText: "FSC-Mix Karton C122951 · 100% recyclierbar",
                conservationConditions: "Kühl und trocken lagern (4–8°C). MHD beachten.",
                dataQualityErrorsTags: [],
                dataQualityWarningsTags: ["en:ecoscore-origins-of-ingredients-not-specified"],
                completeness: 0.92,
                createdT: 1638000000, lastModifiedT: 1740000000, lastEditor: "smoothie-app")

        case "3274080005003":
            return OFFProduct(
                code: barcode, productName: "Cristaline Quellwasser",
                genericName: "Natürliches Quellwasser", brands: "Cristaline",
                quantity: "1.5 L", productQuantity: 1500, productQuantityUnit: "ml",
                servingSize: "200 ml", servingQuantity: 200, storesTags: ["migros","coop"],
                imageUrl: nil, imageFrontUrl: nil, imageIngredientsUrl: nil,
                imageNutritionUrl: nil, imagePackagingUrl: nil,
                categoriesTags: ["en:beverages","en:waters","en:spring-waters"],
                foodGroupsTags: nil, foodGroups: nil, pnnsGroups1: "Beverages",
                pnnsGroups2: "Waters and flavored waters",
                nutriscoreGrade: nil, nutriscoreScore: nil,
                ecoscoreGrade: "not-applicable", ecoscoreScore: nil,
                novaGroup: 1, novaGroupError: nil,
                nutriments: OFFNutriments(
                    energyKcal100g: 0, energyKj100g: 0,
                    energyKcalServing: 0, energyKjServing: 0,
                    fat100g: 0, saturatedFat100g: 0, fatServing: 0, saturatedFatServing: 0,
                    carbohydrates100g: 0, sugars100g: 0, fiber100g: nil,
                    addedSugars100g: nil, starch100g: nil,
                    carbohydratesServing: 0, sugarsServing: 0, fiberServing: nil,
                    proteins100g: 0, proteinsServing: 0,
                    salt100g: 0, sodium100g: 0, saltServing: 0, sodiumServing: 0,
                    novaGroup100g: 1),
                nutrientLevels: nil,
                ingredientsText: nil, ingredients: nil,
                ingredientsN: 0, additivesN: 0, additivesTags: [],
                allergensTags: [], tracesTags: [],
                ingredientsAnalysisTags: ["en:vegan"],
                labelsTags: ["en:made-in-the-eu"],
                countriesTags: ["en:switzerland","en:france"],
                originsTags: ["en:france"],
                manufacturingPlaces: "Serbonnes, Bourgogne, France",
                manufacturingPlacesTags: ["en:france"],
                packagingTags: ["en:pet-1-polyethylene-terephthalate","en:bottle","en:hdpe-2-high-density-polyethylene","en:bottle-cap"],
                packagings: [
                    OFFPackaging(material: "en:pet-1-polyethylene-terephthalate",
                                  shape: "en:bottle", recycling: "en:recycle",
                                  weightMeasured: 20.24, numberOfUnits: 1,
                                  quantityPerUnit: "1.5 L", foodContact: 1,
                                  nonRecyclableAndNonBiodegradable: "no",
                                  environmentalScoreMaterialScore: 35)],
                packagingText: "PET 1 Flasche · HDPE Deckel · 100% recyclierbar",
                conservationConditions: "Kühl und lichtgeschützt lagern.",
                dataQualityErrorsTags: [],
                dataQualityWarningsTags: [],
                completeness: 0.94, createdT: 1580000000,
                lastModifiedT: 1740000000, lastEditor: "kiliweb")

        default:
            return OFFProduct(
                code: barcode, productName: "Produkt \(barcode)",
                genericName: nil, brands: nil, quantity: nil,
                productQuantity: nil, productQuantityUnit: nil,
                servingSize: nil, servingQuantity: nil, storesTags: nil,
                imageUrl: nil, imageFrontUrl: nil, imageIngredientsUrl: nil,
                imageNutritionUrl: nil, imagePackagingUrl: nil,
                categoriesTags: nil, foodGroupsTags: nil, foodGroups: nil,
                pnnsGroups1: nil, pnnsGroups2: nil,
                nutriscoreGrade: nil, nutriscoreScore: nil,
                ecoscoreGrade: nil, ecoscoreScore: nil,
                novaGroup: nil, novaGroupError: nil,
                nutriments: nil, nutrientLevels: nil,
                ingredientsText: nil, ingredients: nil, ingredientsN: nil,
                additivesN: nil, additivesTags: nil,
                allergensTags: nil, tracesTags: nil,
                ingredientsAnalysisTags: nil, labelsTags: nil,
                countriesTags: nil, originsTags: nil,
                manufacturingPlaces: nil, manufacturingPlacesTags: nil,
                packagingTags: nil, packagings: nil, packagingText: nil,
                conservationConditions: nil,
                dataQualityErrorsTags: nil, dataQualityWarningsTags: nil,
                completeness: 0.1, createdT: nil, lastModifiedT: nil, lastEditor: nil)
        }
    }
}

// MARK: - Preview

#Preview {
    ScanResultSheetView2(result: ScanResult(value: "4316268651288", type: "EAN13"))
}
