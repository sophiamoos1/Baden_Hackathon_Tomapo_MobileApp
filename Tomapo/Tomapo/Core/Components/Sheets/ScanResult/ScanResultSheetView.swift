//
//  ScanResultSheetView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
// MARK: - Haupt-Sheet
 
struct ScanResultSheetView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ScanResultViewModel()
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
 
    var body: some View {
        NavigationStack {
            ZStack { Color.theme.warmPearl.ignoresSafeArea(); content }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle().fill(Color.theme.oatMilk).frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.theme.bodyText)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Produkt erkannt")
                        .font(.headline).foregroundColor(Color.theme.bodyText)
                }
            }
        }
        .task { await vm.loadProduct(barcode: result.value, barcodeType: result.type, store: historyStore) }
    }
 
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading: loadingView
        case .notFound:        notFoundView
        case .error(let e):    errorView(e)
        case .loaded(let p):   ProductSheetContent(product: p)
        }
    }
 
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.2).tint(Color.theme.bodyText)
            Text("Produkt wird geladen…").font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.6))
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
 
    private var notFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass").font(.system(size: 44)).foregroundColor(Color.theme.bodyText.opacity(0.3))
            Text("Produkt nicht gefunden").font(.headline).foregroundColor(Color.theme.bodyText)
            Text(result.value).font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
 
    private func errorView(_ error: TomapoApiError) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundColor(Color.theme.bodyText.opacity(0.4))
            Text("Ladefehler").font(.headline).foregroundColor(Color.theme.bodyText)
            Text(error.localizedDescription ?? "Unbekannter Fehler")
                .font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
                .multilineTextAlignment(.center).padding(.horizontal)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
 
// MARK: - Sheet Content
 
private struct ProductSheetContent: View {
    let product: TomapoResponse
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ProductHeroHeader(product: product).padding(.bottom, 8)
 
                // Rückruf-Banner
                if let recall = product.officialRecalls.first {
                    RecallBanner(alert: recall).padding(.horizontal, 16).padding(.bottom, 12)
                }
 
                // Datenfehler-Banner
                if product.hasDataErrors {
                    DataQualityBanner(errors: product.dataQualityErrorsTags ?? [])
                        .padding(.horizontal, 16).padding(.bottom, 12)
                }
 
                VStack(alignment: .leading, spacing: 20) {
                    ScoreTripletSection(product: product)
                    if let n = product.nutriments, product.hasReliableNutritionData {
                        NutritionSection(nutriments: n, product: product)
                    }
                    // 4 Boxen
                    ProductDetailBoxesView(product: product)
                }
                .padding(.horizontal, 16).padding(.bottom, 48)
            }
        }
    }
}
 
// MARK: - Hero Header
 
private struct ProductHeroHeader: View {
    let product: TomapoResponse
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.theme.oatMilk)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: productIcon)
                            .font(.system(size: 28))
                            .foregroundColor(Color.theme.bodyText.opacity(0.3))
                    )
                VStack(alignment: .leading, spacing: 5) {
                    Text(product.productName ?? "Unbekanntes Produkt")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color.theme.bodyText).lineLimit(2)
                    if let brands = product.brands {
                        Text(brands).font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.6))
                    }
                    if let qty = product.quantity {
                        Text(qty).font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.45))
                    }
                    TraceabilityPill(score: product.traceabilityScore).padding(.top, 2)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16)
        }
    }
 
    private var productIcon: String {
        let cats = product.categoriesTags ?? []
        if cats.contains(where: { $0.contains("water") })                           { return "drop.fill" }
        if cats.contains(where: { $0.contains("fish") || $0.contains("seafood") }) { return "fish.fill" }
        if cats.contains(where: { $0.contains("egg") })                             { return "circle.fill" }
        if cats.contains(where: { $0.contains("beverage") || $0.contains("soda") }){ return "cup.and.saucer.fill" }
        if cats.contains(where: { $0.contains("chocolate") || $0.contains("sweet") }){ return "birthday.cake.fill" }
        if cats.contains(where: { $0.contains("meat") || $0.contains("poultry") }) { return "fork.knife" }
        return "cart.fill"
    }
}
 
// MARK: - Recall Banner (nutzt TomapoProductAlert direkt)
 
private struct RecallBanner: View {
    let alert: TomapoProductAlert
 
    private var bannerColor: Color {
        switch alert.severity {
        case .critical: return Color.theme.error
        case .high:     return Color.theme.warning
        default:        return Color.theme.infso
        }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(bannerColor)
                Text(alert.severity == .critical ? "RÜCKRUF" : "Warnung")
                    .font(.caption).fontWeight(.bold).foregroundColor(bannerColor)
                Spacer()
                Text(alert.displayAuthor).font(.caption2).foregroundColor(bannerColor.opacity(0.7))
            }
            Text(alert.description).font(.caption).foregroundColor(Color.theme.bodyText)
                .fixedSize(horizontal: false, vertical: true)
            if let action = alert.actionRequired {
                Text("➜ \(action)").font(.caption).fontWeight(.semibold).foregroundColor(bannerColor)
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
        if tag.contains("salt")     { return "⚠ Salzwert unplausibel (>100g/100g)" }
        if tag.contains("energy")   { return "⚠ Energiewert stimmt nicht mit Makros überein" }
        if tag.contains("over-105") { return "⚠ Nährwertsumme > 105g/100g" }
        return "⚠ \(tag.replacingOccurrences(of: "en:", with: ""))"
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.theme.warning).font(.caption)
                Text("Datenfehler erkannt").font(.caption).fontWeight(.semibold).foregroundColor(Color.theme.warning)
            }
            ForEach(errors, id: \.self) { Text(label(for: $0)).font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.7)) }
            Text("Nährwertangaben auf Verpackung prüfen.").font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.5))
        }
        .padding(12)
        .background(Color.theme.warning.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.warning.opacity(0.25), lineWidth: 1))
        .cornerRadius(12)
    }
}
 
// MARK: - Score Triplet
 
private struct ScoreTripletSection: View {
    let product: TomapoResponse
 
    var body: some View {
        SheetSection(title: "Bewertungen", icon: "chart.bar.fill") {
            HStack(spacing: 12) {
                ScorePill(label: "Nutri", grade: product.nutriscoreGrade, style: .nutri)
                ScorePill(label: "Eco",   grade: product.ecoscoreGrade,   style: .eco)
                ScorePill(label: "NOVA",  grade: product.novaGroup.map { "\($0)" }, style: .nova)
                Spacer()
            }
            if let nova = product.novaGroup, product.nova.isKnown {
                Text("NOVA \(nova) – \(product.nova.label)").font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.55))
            } else if product.novaGroupError == "missing_ingredients" {
                Text("NOVA nicht berechenbar – Zutaten fehlen").font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.45))
            }
            if product.ecoscoreGrade == "not-applicable" {
                Text("Eco-Score gilt nicht für diese Kategorie").font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.45))
            }
        }
    }
}
 
private struct ScorePill: View {
    let label: String; let grade: String?
    enum ScoreStyle { case nutri, eco, nova }
    let style: ScoreStyle
 
    private var displayGrade: String { grade?.uppercased() ?? "?" }
    private var bgColor: Color {
        switch grade?.lowercased() {
        case "a": return Color.green.opacity(0.85)
        case "b": return Color(red: 0.53, green: 0.77, blue: 0.15)
        case "c": return Color.orange.opacity(0.8)
        case "d": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "e": return Color.red.opacity(0.85)
        case "not-applicable", "unknown", nil: return Color.theme.oatMilk
        default:
            if style == .nova, let n = Int(grade ?? "") {
                switch n {
                case 1: return Color.green.opacity(0.8); case 2: return Color(red: 0.53, green: 0.77, blue: 0.15)
                case 3: return Color.orange.opacity(0.8); case 4: return Color.red.opacity(0.85)
                default: return Color.theme.oatMilk
                }
            }
            return Color.theme.oatMilk
        }
    }
    private var textColor: Color {
        let g = grade?.lowercased()
        if g == "unknown" || g == "not-applicable" || g == nil { return Color.theme.bodyText.opacity(0.5) }
        return .white
    }
 
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(bgColor).frame(width: 44, height: 44)
                Text(displayGrade == "NOT-APPLICABLE" ? "N/A" : displayGrade)
                    .font(.system(size: displayGrade.count > 2 ? 10 : 18, weight: .black))
                    .foregroundColor(textColor)
            }
            Text(label).font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.55))
        }
    }
}
 
// MARK: - Nutrition Section
 
private struct NutritionSection: View {
    let nutriments: ProductNutriments
    let product: TomapoResponse
 
    var body: some View {
        SheetSection(title: "Nährwerte pro 100g", icon: "fork.knife") {
            VStack(spacing: 0) {
                NutriRow(name: "Energie", value: nutriments.energyKcal100g, unit: "kcal", level: nil, isHeader: true)
                Divider().padding(.leading, 16)
                NutriRow(name: "Fett", value: nutriments.fat100g, unit: "g", level: product.nutrientLevels?.fat)
                Divider().padding(.leading, 16)
                NutriRow(name: "  davon gesättigte Fettsäuren", value: nutriments.saturatedFat100g, unit: "g",
                         level: product.nutrientLevels?.saturatedFat, isSubRow: true)
                Divider().padding(.leading, 16)
                NutriRow(name: "Kohlenhydrate", value: nutriments.carbohydrates100g, unit: "g", level: nil)
                Divider().padding(.leading, 16)
                NutriRow(name: "  davon Zucker", value: nutriments.sugars100g, unit: "g",
                         level: product.nutrientLevels?.sugars, isSubRow: true)
                if let fiber = nutriments.fiber100g, fiber > 0 {
                    Divider().padding(.leading, 16)
                    NutriRow(name: "Ballaststoffe", value: fiber, unit: "g", level: nil)
                }
                Divider().padding(.leading, 16)
                NutriRow(name: "Proteine", value: nutriments.proteins100g, unit: "g", level: nil)
                Divider().padding(.leading, 16)
                NutriRow(name: "Salz", value: nutriments.salt100g, unit: "g",
                         level: product.nutrientLevels?.salt,
                         hasSuspicion: nutriments.hasSuspiciousSaltValue)
            }
            .background(Color.theme.oatMilk).cornerRadius(12)
            if let serving = product.servingSize {
                Text("Portionsgrösse: \(serving)").font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.45))
            }
        }
    }
}
 
private struct NutriRow: View {
    let name: String; let value: Double?; let unit: String
    var level: String? = nil; var isHeader: Bool = false
    var isSubRow: Bool = false; var hasSuspicion: Bool = false
 
    private var trafficDot: Color? {
        switch level {
        case "low": return .green; case "moderate": return .orange; case "high": return .red; default: return nil
        }
    }
 
    var body: some View {
        HStack(spacing: 8) {
            if let dot = trafficDot { Circle().fill(dot).frame(width: 7, height: 7) }
            Text(name)
                .font(isHeader ? .subheadline.weight(.semibold) : isSubRow ? .caption : .subheadline)
                .foregroundColor(Color.theme.bodyText.opacity(isSubRow ? 0.65 : 1.0))
            Spacer()
            if hasSuspicion { Image(systemName: "exclamationmark.triangle.fill").font(.caption2).foregroundColor(Color.theme.warning) }
            if let v = value {
                Text("\(String(format: v >= 10 ? "%.1f" : "%.2f", v)) \(unit)")
                    .font(isHeader ? .subheadline.weight(.semibold) : .subheadline)
                    .foregroundColor(hasSuspicion ? Color.theme.warning : Color.theme.bodyText)
            } else {
                Text("–").font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.35))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, isSubRow ? 8 : 11)
    }
}
 
// MARK: - Traceability Pill
 
private struct TraceabilityPill: View {
    let score: TomapoTraceabilityScore
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: score.isThirdPartyVerified ? "checkmark.seal.fill" : "clock.fill")
                .font(.caption2).foregroundColor(pillColor)
            Text("\(Int(score.completeness * 100))% rückverfolgbar")
                .font(.caption2).foregroundColor(pillColor)
        }
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(pillColor.opacity(0.12)).cornerRadius(20)
    }
    private var pillColor: Color {
        score.completeness >= 0.8 ? .green : score.completeness >= 0.5 ? .orange : .red
    }
}
 
// MARK: - Shared Components (öffentlich für andere Views)
 
struct SheetSection<Content: View>: View {
    let title: String; let icon: String
    @ViewBuilder let content: () -> Content
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
                Text(title.uppercased()).font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.bodyText.opacity(0.55)).tracking(0.5)
            }
            content()
        }
    }
}
 
struct InfoRow: View {
    let label: String; let value: String
    var valueColor: Color = Color.theme.bodyText
    var body: some View {
        HStack(spacing: 8) {
            Text(label).font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.6))
            Spacer()
            Text(value).font(.subheadline).foregroundColor(valueColor).multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16).padding(.vertical, 11)
    }
}
 
struct PlaceholderRow: View {
    let text: String
    var body: some View {
        Text(text).font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.4)).padding(.vertical, 4)
    }
}
 
struct FlexTagCloud: View {
    let tags: [String]; let color: Color
    var body: some View {
        FlexLayout {
            ForEach(tags, id: \.self) { tag in
                Text(tag).font(.caption2).foregroundColor(color)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(color.opacity(0.1)).cornerRadius(20)
            }
        }
    }
}
 
struct FlexLayout: Layout {
    var spacing: CGFloat = 6
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0; var y: CGFloat = 0; var rowH: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            rowH = max(rowH, size.height); x += size.width + spacing
        }
        return CGSize(width: width, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var rowH: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowH = max(rowH, size.height); x += size.width + spacing
        }
    }
}
 
// MARK: - DietBadge (nutzt DietStatus statt OFFDietStatus)
 
struct DietBadge: View {
    let label: String; let status: DietStatus
 
    private var color: Color {
        switch status { case .yes: return .green; case .no: return .red; case .maybe: return .orange; case .unknown: return Color.theme.bodyText.opacity(0.3) }
    }
    private var icon: String {
        switch status { case .yes: return "checkmark"; case .no: return "xmark"; case .maybe: return "questionmark"; case .unknown: return "minus" }
    }
 
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 9, weight: .bold))
            Text(label).font(.caption2)
        }
        .foregroundColor(color).padding(.horizontal, 8).padding(.vertical, 4)
        .background(color.opacity(0.12)).cornerRadius(20)
    }
}
 
// MARK: - Preview
 
#Preview {
    ScanResultSheetView(result: ScanResult(value: "4316268651288", type: "EAN13"))
        .environmentObject(ScanHistoryStore())
        .environmentObject(TomapoUserMessageStore())
}
