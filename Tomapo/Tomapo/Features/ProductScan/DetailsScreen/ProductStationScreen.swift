//
//  ProductSt.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
struct ProductStationsScreen: View {
    let product: TomapoResponse
    var onBack: () -> Void
 
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.baseBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 60)
 
                    // Traceability Score
                    TraceabilityScoreCard(score: product.traceabilityScore)
                        .padding(.horizontal, 16)
 
                    // Kühlketten-Summary (wenn relevant)
                    if product.requiresColdChain {
                        ColdChainCardView(summary: product.coldChainSummary, stations: product.stations)
                            .padding(.horizontal, 16)
                    }
 
                    // Timeline
                    if product.stations.isEmpty {
                        emptyState
                    } else {
                        TomapoStationTimeline(stations: product.stations)
                            .padding(.horizontal, 16)
                    }
 
                    // Datenquellen
                    if !product.dataSources.isEmpty {
                        DataSourcesCard(sources: product.dataSources).padding(.horizontal, 16)
                    }
 
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackNavigationBar(title: "Produktionskette", onBack: onBack)
        }
    }
 
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.triangle.branch").font(.system(size: 40)).foregroundColor(Color.theme.mutedFg.opacity(0.25))
            Text("Keine Stationsdaten verfügbar").font(.subheadline).foregroundColor(Color.theme.mutedFg)
        }
        .frame(maxWidth: .infinity).padding(.top, 60)
    }
}
 
// MARK: - Traceability Score Card
 
private struct TraceabilityScoreCard: View {
    let score: TomapoTraceabilityScore
 
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().stroke(Color.theme.mutedFg.opacity(0.2), lineWidth: 5).frame(width: 52, height: 52)
                    Circle().trim(from: 0, to: score.completeness)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 52, height: 52).rotationEffect(.degrees(-90))
                    Text("\(Int(score.completeness * 100))%")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(Color.theme.cardFg)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rückverfolgbarkeit").font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                    HStack(spacing: 10) {
                        if score.verifiedStations > 0 {
                            Label("\(score.verifiedStations) verifiziert", systemImage: "checkmark.seal.fill")
                                .font(.caption2).foregroundColor(Color.theme.success)
                        }
                        if score.unknownStations > 0 {
                            Label("\(score.unknownStations) unbekannt", systemImage: "questionmark.circle")
                                .font(.caption2).foregroundColor(Color.theme.mutedFg)
                        }
                    }
                    if score.hasGaps {
                        Text("⚠ Lücken in der Rückverfolgbarkeit").font(.caption2).foregroundColor(Color.theme.warning)
                    }
                }
                Spacer()
                if score.isThirdPartyVerified {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(Color.theme.success).font(.title3)
                }
            }
        }
        .padding(14)
        .background(Color.theme.cardBg).cornerRadius(14)
    }
 
    private var scoreColor: Color {
        score.completeness >= 0.8 ? Color.theme.success : score.completeness >= 0.5 ? Color.theme.warning : Color.theme.error
    }
}
 

 
// MARK: - Data Sources Card
 
private struct DataSourcesCard: View {
    let sources: [TomapoDataSource]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "database.fill").font(.caption).foregroundColor(Color.theme.mutedFg)
                Text("DATENQUELLEN".uppercased()).font(.caption.weight(.semibold))
                    .foregroundColor(Color.theme.mutedFg).tracking(0.5)
            }
            VStack(spacing: 0) {
                ForEach(sources, id: \.id) { source in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(source.name).font(.subheadline).foregroundColor(Color.theme.cardFg)
                            Text(source.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption2).foregroundColor(Color.theme.mutedFg)
                        }
                        Spacer()
                        ReliabilityBadge(reliability: source.reliability)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    if source.id != sources.last?.id { Divider().padding(.leading, 14) }
                }
            }
            .background(Color.theme.cardBg).cornerRadius(12)
        }
    }
}
 
private struct ReliabilityBadge: View {
    let reliability: DataSourceReliability
    var body: some View {
        Text(reliability.rawValue.capitalized).font(.caption2)
            .foregroundColor(color).padding(.horizontal, 7).padding(.vertical, 3)
            .background(color.opacity(0.1)).cornerRadius(8)
    }
    private var color: Color {
        switch reliability {
        case .verified, .official: return Color.theme.success
        case .community:           return Color.theme.warning
        case .estimated, .unknown: return Color.theme.mutedFg
        }
    }
}
 

