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
    @State private var isSyncing: Bool = false

    enum ChartRange: String, CaseIterable {
        case week  = "7 Days"
        case month = "30 Days"
        case all   = "All"
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

                // MARK: CO2 Chart
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

                // MARK: Product List
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
        .task { await syncWithServer() }
    }

    private func syncWithServer() async {
        isSyncing = true
        defer { isSyncing = false }
        do {
            let serverEntries = try await TomapoAPIService.shared.getMyScanHistory()

            if historyStore.entries.isEmpty {
                // First load or after clear: use server as source of truth
                historyStore.replaceWithServerEntries(serverEntries)
            } else {
                // Merge: add server entries missing locally (preserves timestamps)
                historyStore.mergeServerEntries(serverEntries)
            }
        } catch {
            // Silent — local store is the fallback
        }
    }

    private func clearAllWithServer() {
        withAnimation { historyStore.clearAll() }
        Task {
            try? await TomapoAPIService.shared.clearMyScanHistory()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(.largeTitle).fontWeight(.heavy)
                    .foregroundColor(Color.theme.cardFg)
                HStack(spacing: 6) {
                    Text("\(historyStore.entries.count) scanned products")
                        .font(.subheadline).foregroundColor(Color.theme.cardFg)
                    if isSyncing {
                        ProgressView().scaleEffect(0.6)
                    }
                }
            }
            Spacer()
            if !historyStore.entries.isEmpty {
                Button {
                    clearAllWithServer()
                } label: {
                    Text("Clear All")
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
                        Label("Delete", systemImage: "trash")
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
            Text("Nothing scanned yet")
                .font(.headline).foregroundColor(Color.theme.cardFg)
            Text("Scan a product to see it here.")
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
                Text("\(count) product\(count == 1 ? "" : "s") with active recall")
                    .font(.caption.weight(.bold)).foregroundColor(Color.theme.error)
                Text("Please do not consume the affected products.")
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

// MARK: - CO2 Section

private struct CO2Section: View {
    let entries: [ScanHistoryEntry]
    let filteredEntries: [ScanHistoryEntry]
    let co2Total: Double
    @Binding var range: ScannedProductsHistoryView.ChartRange

    // Aggregated daily data for chart
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
                    Text("CO\u{2082} Footprint").font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                    Text(String(format: "%.2f kg CO\u{2082}eq", co2Total))
                        .font(.title3.weight(.bold)).foregroundColor(co2Color)
                }
                Spacer()
                // Range Picker
                Picker("Period", selection: $range) {
                    ForEach(ScannedProductsHistoryView.ChartRange.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }

            if chartData.isEmpty {
                Text("No CO\u{2082} data for this period")
                    .font(.caption).foregroundColor(Color.theme.mutedFg)
                    .padding(.vertical, 20).frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Bar Chart
                Chart {
                    ForEach(chartData, id: \.0) { day, co2 in
                        BarMark(
                            x: .value("Date", day, unit: .day),
                            y: .value("CO\u{2082} kg", co2)
                        )
                        .foregroundStyle(Color.theme.chartSoftMossTeal.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: range == .week ? 1 : 7)) { _ in
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
                    StatItem(label: "Avg/Product", value: String(format: "%.2f kg", avg))
                }
                StatItem(label: "Period", value: range.rawValue)
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
