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
    var batchID: String? = nil
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ScanResultViewModel()
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
 
    var body: some View {
        NavigationStack {
            ZStack { Color.theme.baseBg.ignoresSafeArea(); content }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle().fill(Color.theme.mutedBg).frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.theme.cardFg)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Produkt erkannt")
                        .font(.headline).foregroundColor(Color.theme.cardFg)
                }
            }
        }
        .task { await vm.loadProduct(barcode: result.value, barcodeType: result.type, batchId: batchID, store: historyStore) }
    }
 
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading: loadingView
        case .notFound:        notFoundView
        case .error(let e):    errorView(e)
        case .loaded(let p):   ProductSheetContent(product: p, barcode: result.value, batchID: batchID)
        }
    }
 
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.2).tint(Color.theme.cardFg)
            Text("Produkt wird geladen…").font(.subheadline).foregroundColor(Color.theme.mutedFg)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
 
    private var notFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass").font(.system(size: 44)).foregroundColor(Color.theme.mutedFg.opacity(0.35))
            Text("Produkt nicht gefunden").font(.headline).foregroundColor(Color.theme.cardFg)
            Text(result.value).font(.caption).foregroundColor(Color.theme.mutedFg)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
 
    private func errorView(_ error: TomapoApiError) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundColor(Color.theme.mutedFg.opacity(0.5))
            Text("Ladefehler").font(.headline).foregroundColor(Color.theme.cardFg)
            Text(error.localizedDescription)
                .font(.caption).foregroundColor(Color.theme.mutedFg)
                .multilineTextAlignment(.center).padding(.horizontal)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
 
// MARK: - Sheet Content
 
private struct ProductSheetContent: View {
    let product: TomapoResponse
    var barcode: String? = nil
    var batchID: String? = nil
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ProductHeroHeader(product: product, barcode: barcode, batchID: batchID).padding(.bottom, 8)
 
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
                        NutritionCardView(nutriments: n, servingSize: product.servingSize)
                    }
                    // Kühlkette
                    if product.requiresColdChain {
                        ColdChainCardView(summary: product.coldChainSummary, stations: product.stations)
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
    var barcode: String? = nil
    var batchID: String? = nil
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.theme.mutedBg)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: productIcon)
                            .font(.system(size: 28))
                            .foregroundColor(Color.theme.mutedFg.opacity(0.35))
                    )
                VStack(alignment: .leading, spacing: 5) {
                    Text(product.productName ?? "Unbekanntes Produkt")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color.theme.cardFg).lineLimit(2)
                    if let brands = product.brands {
                        Text(brands).font(.subheadline).foregroundColor(Color.theme.mutedFg)
                    }
                    if let qty = product.quantity {
                        Text(qty).font(.caption).foregroundColor(Color.theme.mutedFg)
                    }
                    TraceabilityPill(score: product.traceabilityScore).padding(.top, 2)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16)

            // Barcode + Batch ID Info
            if barcode != nil || batchID != nil {
                HStack(spacing: 12) {
                    if let barcode {
                        HStack(spacing: 4) {
                            Image(systemName: "barcode")
                                .font(.caption2)
                                .foregroundColor(Color.theme.mutedFg)
                            Text(barcode)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.theme.mutedFg)
                        }
                    }
                    if let batchID {
                        HStack(spacing: 4) {
                            Image(systemName: "number")
                                .font(.caption2)
                                .foregroundColor(Color.theme.mutedFg)
                            Text(batchID)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.theme.mutedFg)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.theme.mutedFg.opacity(0.08))
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 16)
            }
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
            Text(alert.description).font(.caption).foregroundColor(Color.theme.cardFg)
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
            ForEach(errors, id: \.self) { Text(label(for: $0)).font(.caption2).foregroundColor(Color.theme.mutedFg) }
            Text("Nährwertangaben auf Verpackung prüfen.").font(.caption2).foregroundColor(Color.theme.mutedFg)
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
                Text("NOVA \(nova) – \(product.nova.label)").font(.caption).foregroundColor(Color.theme.mutedFg)
            } else if product.novaGroupError == "missing_ingredients" {
                Text("NOVA nicht berechenbar – Zutaten fehlen").font(.caption).foregroundColor(Color.theme.mutedFg)
            }
            if product.ecoscoreGrade == "not-applicable" {
                Text("Eco-Score gilt nicht für diese Kategorie").font(.caption).foregroundColor(Color.theme.mutedFg)
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
        case "a": return Color.theme.success
        case "b": return Color.theme.chartDustyOlive
        case "c": return Color.theme.warning
        case "d": return Color.theme.chartTerracottaRose
        case "e": return Color.theme.error
        case "not-applicable", "unknown", nil: return Color.theme.mutedBg
        default:
            if style == .nova, let n = Int(grade ?? "") {
                switch n {
                case 1: return Color.theme.success; case 2: return Color.theme.chartDustyOlive
                case 3: return Color.theme.warning; case 4: return Color.theme.error
                default: return Color.theme.mutedBg
                }
            }
            return Color.theme.mutedBg
        }
    }
    private var textColor: Color {
        let g = grade?.lowercased()
        if g == "unknown" || g == "not-applicable" || g == nil { return Color.theme.mutedFg }
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
            Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
        }
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
        score.completeness >= 0.8 ? Color.theme.success : score.completeness >= 0.5 ? Color.theme.warning : Color.theme.error
    }
}
 
// MARK: - Shared Components (öffentlich für andere Views)
 
struct SheetSection<Content: View>: View {
    let title: String; let icon: String
    @ViewBuilder let content: () -> Content
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundColor(Color.theme.mutedFg)
                Text(title.uppercased()).font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.mutedFg).tracking(0.5)
            }
            content()
        }
    }
}
 
struct InfoRow: View {
    let label: String; let value: String
    var valueColor: Color = Color.theme.cardFg
    var body: some View {
        HStack(spacing: 8) {
            Text(label).font(.subheadline).foregroundColor(Color.theme.mutedFg)
                .layoutPriority(1)
            Spacer(minLength: 4)
            Text(value).font(.subheadline).foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16).padding(.vertical, 11)
    }
}
 
struct PlaceholderRow: View {
    let text: String
    var body: some View {
        Text(text).font(.caption).foregroundColor(Color.theme.mutedFg.opacity(0.5)).padding(.vertical, 4)
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
        switch status { case .yes: return Color.theme.success; case .no: return Color.theme.error; case .maybe: return Color.theme.warning; case .unknown: return Color.theme.mutedFg.opacity(0.4) }
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
