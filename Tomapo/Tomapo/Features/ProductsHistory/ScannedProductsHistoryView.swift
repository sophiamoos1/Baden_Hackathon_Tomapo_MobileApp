//
//  ScannedProductsHistoryView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
internal import Charts
 
struct ScannedProductsHistoryView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
    @EnvironmentObject private var userStore: TomapoUserStore
 
    @State private var selectedEntry: ScanHistoryEntry? = nil
    @State private var chartRange: ChartRange = .week
 
    enum ChartRange: String, CaseIterable {
        case week  = "7 Tage"
        case month = "30 Tage"
        case all   = "Alle"
    }
 
    private var fromDate: Date {
        let cal = Calendar.current
        switch chartRange {
        case .week:  return cal.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month: return cal.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        case .all:   return Date.distantPast
        }
    }
 
    private var filteredEntries: [ScanHistoryEntry] {
        historyStore.entries.filter { $0.scannedAt >= fromDate }
    }
 
    private var co2Total: Double {
        historyStore.co2InRange(from: fromDate)
    }
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
 
                // MARK: Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
 
                // MARK: Recall Warning
                if !historyStore.recallEntries.isEmpty {
                    RecallWarningBanner(count: historyStore.recallEntries.count)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
 
                // MARK: CO₂ Diagramm
                if !historyStore.entries.isEmpty {
                    CO2Section(
                        entries: historyStore.entries,
                        filteredEntries: filteredEntries,
                        co2Total: co2Total,
                        range: $chartRange
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
 
                // MARK: Produktliste
                if historyStore.entries.isEmpty {
                    emptyState
                } else {
                    productList
                }
            }
            .padding(.bottom, 40)
        }
        .fullScreenCover(item: $selectedEntry) { entry in
            ProductDetailView(entry: entry, onBack: { selectedEntry = nil })
                .environmentObject(historyStore)
                .environmentObject(userMessageStore)
                .environmentObject(userStore)
        }
    }
 
    // MARK: - Header
 
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(.largeTitle).fontWeight(.heavy)
                    .foregroundColor(Color.theme.cardFg)
                Text("\(historyStore.entries.count) gescannte Produkte")
                    .font(.subheadline).foregroundColor(Color.theme.cardFg)
            }
            Spacer()
            if !historyStore.entries.isEmpty {
                Button {
                    withAnimation { historyStore.clearAll() }
                } label: {
                    Text("Alles löschen")
                        .font(.caption).foregroundColor(Color.theme.mutedFg)
                }
            }
        }
    }
 
    // MARK: - Product List
 
    private var productList: some View {
        LazyVStack(spacing: 10) {
            ForEach(historyStore.entries) { entry in
                ScanHistoryRow(entry: entry) {
                    selectedEntry = entry
                }
                .padding(.horizontal, 16)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation { historyStore.remove(entry) }
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
        }
    }
 
    // MARK: - Empty State
 
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("IllustrationScan")
                .resizable().scaledToFit()
                .frame(width: 140, height: 140)
            Text("Noch nichts gescannt")
                .font(.headline).foregroundColor(Color.theme.cardFg)
            Text("Scanne ein Produkt um es hier zu sehen.")
                .font(.subheadline).foregroundColor(Color.theme.cardFg)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80).padding(.horizontal, 40)
    }
}
 
// MARK: - Recall Warning Banner
 
private struct RecallWarningBanner: View {
    let count: Int
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.theme.error)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count) Produkt\(count == 1 ? "" : "e") mit aktivem Rückruf")
                    .font(.caption.weight(.bold)).foregroundColor(Color.theme.error)
                Text("Bitte die betroffenen Produkte nicht verwenden.")
                    .font(.caption2).foregroundColor(Color.theme.mutedFg)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.theme.error.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.error.opacity(0.25), lineWidth: 1))
        .cornerRadius(12)
    }
}
 
// MARK: - CO₂ Section
 
private struct CO2Section: View {
    let entries: [ScanHistoryEntry]
    let filteredEntries: [ScanHistoryEntry]
    let co2Total: Double
    @Binding var range: ScannedProductsHistoryView.ChartRange
 
    // Aggregierte Tages-Daten für das Diagramm
    private var chartData: [(Date, Double)] {
        let cal = Calendar.current
        var dict: [Date: Double] = [:]
        for entry in filteredEntries {
            guard let co2 = entry.co2KgPerKg else { continue }
            let day = cal.startOfDay(for: entry.scannedAt)
            dict[day, default: 0] += co2
        }
        return dict.sorted { $0.key < $1.key }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CO₂ Fussabdruck").font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                    Text(String(format: "%.2f kg CO₂eq", co2Total))
                        .font(.title3.weight(.bold)).foregroundColor(co2Color)
                }
                Spacer()
                // Range Picker
                Picker("Zeitraum", selection: $range) {
                    ForEach(ScannedProductsHistoryView.ChartRange.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
 
            if chartData.isEmpty {
                Text("Keine CO₂-Daten für diesen Zeitraum")
                    .font(.caption).foregroundColor(Color.theme.mutedFg)
                    .padding(.vertical, 20).frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Balkendiagramm
                Chart {
                    ForEach(chartData, id: \.0) { day, co2 in
                        BarMark(
                            x: .value("Datum", day, unit: .day),
                            y: .value("CO₂ kg", co2)
                        )
                        .foregroundStyle(Color.theme.chartSoftMossTeal.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: range == .week ? 1 : 7)) { value in
                        AxisValueLabel(format: range == .week ? .dateTime.weekday(.abbreviated) : .dateTime.day().month(.abbreviated))
                            .foregroundStyle(Color.theme.mutedFg)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(String(format: "%.1f", v)).font(.caption2)
                                    .foregroundStyle(Color.theme.mutedFg)
                            }
                        }
                    }
                }
                .frame(height: 130)
            }
 
            // Stats
            HStack(spacing: 20) {
                StatItem(label: "Scans", value: "\(filteredEntries.count)")
                if let avg = chartData.isEmpty ? nil : co2Total / Double(max(filteredEntries.filter { $0.co2KgPerKg != nil }.count, 1)) {
                    StatItem(label: "Ø/Produkt", value: String(format: "%.2f kg", avg))
                }
                StatItem(label: "Zeitraum", value: range.rawValue)
            }
        }
        .padding(16)
        .background(Color.theme.cardBg)
        .cornerRadius(16)
    }
 
    private var co2Color: Color {
        co2Total < 5 ? Color.theme.success : co2Total < 15 ? Color.theme.warning : Color.theme.error
    }
}
 
private struct StatItem: View {
    let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.subheadline.weight(.bold)).foregroundColor(Color.theme.cardFg)
            Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
        }
    }
}
 /*
// MARK: - Preview
 
#Preview {
    let store = ScanHistoryStore()
    store.add(barcode: "4316268651288", barcodeType: "EAN13", batchId: "DE-031107-26046",
              productName: "BioBio Bio-Eier Freilandhaltung", brand: "BioBio",
              imageUrl: nil, nutriscoreGrade: "a", ecoscoreGrade: "b",
              co2KgPerKg: 3.167, bestBeforeDate: nil, hasActiveRecall: false)
    store.add(barcode: "5000159461122", barcodeType: "EAN13", batchId: nil,
              productName: "Snickers", brand: "Mars",
              imageUrl: nil, nutriscoreGrade: "e", ecoscoreGrade: "d",
              co2KgPerKg: 5.2, bestBeforeDate: nil, hasActiveRecall: true)
    return ZStack {
        GeometryReader { geo in
            Image("TomapBackground").resizable().scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height).clipped()
        }.ignoresSafeArea()
        ScannedProductsHistoryView(selectedTab: .constant(.history))
            .environmentObject(ThemeManager())
            .environmentObject(store)
            .environmentObject(TomapoUserMessageStore())
            .environmentObject(TomapoUserStore())
    }
}
*/
