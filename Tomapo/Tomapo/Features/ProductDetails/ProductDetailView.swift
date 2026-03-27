//
//  ProductDetailView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
struct ProductDetailView: View {
    let entry: ScanHistoryEntry
    var onBack: () -> Void
 
    @State private var vm = ProductDetailViewModel()
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
    @EnvironmentObject private var userStore: TomapoUserStore
 
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.warmPearl.ignoresSafeArea()
 
            switch vm.state {
            case .idle, .loading:
                loadingView
            case .notFound:
                notFoundView
            case .error(let e):
                errorView(e)
            case .loaded(let product):
                productContent(product)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackNavigationBar(
                title: entry.displayName,
                onBack: onBack
            )
        }
        .task {
            await vm.load(entry: entry, store: historyStore)
        }
    }
 
    // MARK: - Loaded Content
 
    private func productContent(_ product: TomapoResponse) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: 60)
 
                // Hero
                ProductDetailHero(product: product).padding(.bottom, 8)
 
                // Recall Banner
                if let recall = product.officialRecalls.first {
                    DetailRecallBanner(alert: recall)
                        .padding(.horizontal, 16).padding(.bottom, 12)
                }
 
                // Data errors banner
                if product.hasDataErrors {
                    DetailDataQualityBanner(errors: product.dataQualityErrorsTags ?? [])
                        .padding(.horizontal, 16).padding(.bottom, 12)
                }
 
                VStack(alignment: .leading, spacing: 20) {
                    // Score Triplet
                    DetailScoreSection(product: product)
 
                    // Nährwerte
                    if let n = product.nutriments, product.hasReliableNutritionData {
                        DetailNutritionSection(nutriments: n, product: product)
                    }
 
                    // Meldung erfassen (nur wenn canSubmitReport)
                    if entry.canSubmitReport {
                        SubmitAlertPrompt(product: product)
                            .environmentObject(userMessageStore)
                            .environmentObject(userStore)
                    }
 
                    // 4 Boxen
                    ProductDetailBoxesView(product: product)
                        .environmentObject(userMessageStore)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 48)
            }
        }
    }
 
    // MARK: - States
 
    private var loadingView: some View {
        VStack(spacing: 20) {
            Color.clear.frame(height: 60)
            ProgressView().scaleEffect(1.3).tint(Color.theme.mutedSage)
            Text("Produktdaten werden geladen…")
                .font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
 
    private var notFoundView: some View {
        VStack(spacing: 16) {
            Color.clear.frame(height: 60)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44)).foregroundColor(Color.theme.bodyText.opacity(0.3))
            Text("Produkt nicht gefunden").font(.headline).foregroundColor(Color.theme.bodyText)
            Text(entry.barcode).font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
 
    private func errorView(_ error: TomapoApiError) -> some View {
        VStack(spacing: 12) {
            Color.clear.frame(height: 60)
            Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundColor(Color.theme.bodyText.opacity(0.4))
            Text("Ladefehler").font(.headline).foregroundColor(Color.theme.bodyText)
            Text(error.localizedDescription ?? "Unbekannter Fehler")
                .font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
                .multilineTextAlignment(.center).padding(.horizontal)
            Button("Nochmal versuchen") {
                Task { await vm.load(entry: entry, store: historyStore) }
            }
            .font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.infso)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
 
// MARK: - ViewModel
 
@MainActor
@Observable
final class ProductDetailViewModel {
    var state: TomapoApiState = .idle
 
    func load(entry: ScanHistoryEntry, store: ScanHistoryStore) async {
        state = .loading
        try? await Task.sleep(nanoseconds: 500_000_000)
 
        // Mock – in Produktion: TomapoService.shared.fetchProduct(barcode:batchId:)
        let barcode = entry.barcode
        let mock = TomapoMockData.trace(for: barcode) ?? TomapoMockData.bioEier()
        state = .loaded(mock)
 
        // Gecachte Felder in Store aktualisieren
        store.update(
            barcode: barcode,
            batchId: entry.batchId,
            imageUrl: mock.displayImageUrl,
            nutriscoreGrade: mock.nutriscoreGrade,
            ecoscoreGrade: mock.ecoscoreGrade,
            co2KgPerKg: mock.environmentSummary.co2TotalKgPerKg,
            bestBeforeDate: nil,
            hasActiveRecall: mock.hasActiveRecall
        )
    }
 
    var loadedProduct: TomapoResponse? {
        if case .loaded(let p) = state { return p }
        return nil
    }
}
 
// MARK: - Sub-Views
 
private struct ProductDetailHero: View {
    let product: TomapoResponse
 
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.theme.warmPearl)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: categoryIcon)
                        .font(.system(size: 28))
                        .foregroundColor(Color.theme.bodyText.opacity(0.3))
                )
 
            VStack(alignment: .leading, spacing: 5) {
                Text(product.productName ?? "Unbekanntes Produkt")
                    .font(.title3.weight(.bold))
                    .foregroundColor(Color.theme.bodyText)
                    .lineLimit(2)
                if let brands = product.brands {
                    Text(brands).font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.6))
                }
                if let qty = product.quantity {
                    Text(qty).font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.45))
                }
                // Traceability pill
                HStack(spacing: 4) {
                    Image(systemName: product.traceabilityScore.isThirdPartyVerified ? "checkmark.seal.fill" : "clock.fill")
                        .font(.caption2).foregroundColor(pillColor)
                    Text("\(Int(product.traceabilityScore.completeness * 100))% rückverfolgbar")
                        .font(.caption2).foregroundColor(pillColor)
                }
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(pillColor.opacity(0.12)).cornerRadius(20)
                .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 16)
    }
 
    private var pillColor: Color {
        let c = product.traceabilityScore.completeness
        return c >= 0.8 ? .green : c >= 0.5 ? .orange : .red
    }
 
    private var categoryIcon: String {
        let cats = product.categoriesTags ?? []
        if cats.contains(where: { $0.contains("water") })                            { return "drop.fill" }
        if cats.contains(where: { $0.contains("fish") || $0.contains("seafood") })  { return "fish.fill" }
        if cats.contains(where: { $0.contains("egg") })                              { return "circle.fill" }
        if cats.contains(where: { $0.contains("beverage") || $0.contains("soda") }) { return "cup.and.saucer.fill" }
        if cats.contains(where: { $0.contains("chocolate") })                        { return "birthday.cake.fill" }
        return "cart.fill"
    }
}
 
private struct DetailScoreSection: View {
    let product: TomapoResponse
    var body: some View {
        SheetSection(title: "Bewertungen", icon: "chart.bar.fill") {
            HStack(spacing: 12) {
                DetailScorePill(label: "Nutri", grade: product.nutriscoreGrade)
                DetailScorePill(label: "Eco",   grade: product.ecoscoreGrade)
                DetailScorePill(label: "NOVA",  grade: product.novaGroup.map { "\($0)" })
                Spacer()
            }
            if let nova = product.novaGroup, product.nova.isKnown {
                Text("NOVA \(nova) – \(product.nova.label)")
                    .font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.55))
            }
        }
    }
}
 
private struct DetailScorePill: View {
    let label: String; let grade: String?
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(bgColor).frame(width: 44, height: 44)
                Text((grade?.uppercased() ?? "?"))
                    .font(.system(size: (grade?.count ?? 1) > 2 ? 10 : 18, weight: .black))
                    .foregroundColor(textColor)
            }
            Text(label).font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.55))
        }
    }
    private var bgColor: Color {
        switch grade?.lowercased() {
        case "a": return .green.opacity(0.85); case "b": return Color(red: 0.53, green: 0.77, blue: 0.15)
        case "c": return .orange.opacity(0.8); case "d": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "e": return .red.opacity(0.85);  default:   return Color.theme.oatMilk
        }
    }
    private var textColor: Color {
        switch grade?.lowercased() {
        case "a","b","c","d","e": return .white; default: return Color.theme.bodyText.opacity(0.5)
        }
    }
}
 
private struct DetailNutritionSection: View {
    let nutriments: ProductNutriments; let product: TomapoResponse
    var body: some View {
        SheetSection(title: "Nährwerte pro 100g", icon: "fork.knife") {
            VStack(spacing: 0) {
                NRow(name: "Energie", value: nutriments.energyKcal100g, unit: "kcal", isHeader: true)
                Divider().padding(.leading, 16)
                NRow(name: "Fett", value: nutriments.fat100g, unit: "g", level: product.nutrientLevels?.fat)
                Divider().padding(.leading, 16)
                NRow(name: "  davon gesättigt", value: nutriments.saturatedFat100g, unit: "g",
                     level: product.nutrientLevels?.saturatedFat, isSubRow: true)
                Divider().padding(.leading, 16)
                NRow(name: "Kohlenhydrate", value: nutriments.carbohydrates100g, unit: "g")
                Divider().padding(.leading, 16)
                NRow(name: "  davon Zucker", value: nutriments.sugars100g, unit: "g",
                     level: product.nutrientLevels?.sugars, isSubRow: true)
                Divider().padding(.leading, 16)
                NRow(name: "Proteine", value: nutriments.proteins100g, unit: "g")
                Divider().padding(.leading, 16)
                NRow(name: "Salz", value: nutriments.salt100g, unit: "g",
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
 
private struct NRow: View {
    let name: String; let value: Double?; let unit: String
    var level: String? = nil; var isHeader: Bool = false
    var isSubRow: Bool = false; var hasSuspicion: Bool = false
    private var trafficDot: Color? {
        switch level { case "low": return .green; case "moderate": return .orange; case "high": return .red; default: return nil }
    }
    var body: some View {
        HStack(spacing: 8) {
            if let d = trafficDot { Circle().fill(d).frame(width: 7, height: 7) }
            Text(name).font(isHeader ? .subheadline.weight(.semibold) : isSubRow ? .caption : .subheadline)
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
 
private struct DetailRecallBanner: View {
    let alert: TomapoProductAlert
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.theme.error)
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title).font(.caption.weight(.bold)).foregroundColor(Color.theme.error)
                Text(alert.description).font(.caption2).foregroundColor(Color.theme.bodyText).lineLimit(2)
            }
        }
        .padding(12)
        .background(Color.theme.error.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.error.opacity(0.3), lineWidth: 1))
        .cornerRadius(12)
    }
}
 
private struct DetailDataQualityBanner: View {
    let errors: [String]
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.theme.warning).font(.caption)
            Text("Datenfehler erkannt – Nährwertangaben auf Verpackung prüfen.")
                .font(.caption).foregroundColor(Color.theme.warning)
        }
        .padding(12)
        .background(Color.theme.warning.opacity(0.07))
        .cornerRadius(12)
    }
}
 
// MARK: - Submit Alert Prompt
 
private struct SubmitAlertPrompt: View {
    let product: TomapoResponse
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
    @EnvironmentObject private var userStore: TomapoUserStore
    @State private var showSheet = false
 
    var body: some View {
        Button { showSheet = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 18)).foregroundColor(Color.theme.accentTerracotta)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meldung erfassen").font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.bodyText)
                    Text("Problem melden: Schimmel, Fremdkörper, Qualitätsmangel…")
                        .font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.3))
            }
            .padding(14).background(Color.theme.oatMilk).cornerRadius(14)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            SubmitAlertSheet(product: product) { draft in
                userMessageStore.add(
                    authorId: userStore.currentUser?.id ?? "guest",
                    authorNickname: userStore.currentUser?.nickname ?? "Anonym",
                    productSnapshot: TomapoMessageProductSnapshot(
                        barcode: product.barcode, batchId: product.batchId,
                        productName: product.productName, brand: product.brands,
                        quantity: product.quantity, imageUrl: product.displayImageUrl,
                        nutriscoreGrade: product.nutriscoreGrade, ecoscoreGrade: product.ecoscoreGrade,
                        categoriesTags: product.categoriesTags,
                        scannedAt: Date(), scannedAtStoreName: nil),
                    category: draft.category, title: draft.title,
                    body: draft.body, severity: draft.severity)
                showSheet = false
            }
            .environmentObject(userStore)
        }
    }
}
