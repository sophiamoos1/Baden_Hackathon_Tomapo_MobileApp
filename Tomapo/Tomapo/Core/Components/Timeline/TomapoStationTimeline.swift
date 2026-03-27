//
//  TomapoStationTimeline.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
import PhosphorSwift

// MARK: - Timeline Hauptview

struct TomapoStationTimeline: View {
    let stations: [TomapoStation]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
                TomapoStationRow(
                    station: station,
                    isLast: index == stations.count - 1
                )
            }
        }
    }
}

// MARK: - Station Row

struct TomapoStationRow: View {
    let station: TomapoStation
    let isLast: Bool

    @State private var navigateToDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // ── Linke Spalte: Linie + Badge ─────────────────────────
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(stationStatusColor.opacity(0.15))
                        .frame(width: 38, height: 38)
                    Circle()
                        .strokeBorder(stationStatusColor, lineWidth: 2)
                        .frame(width: 38, height: 38)
                    stationIcon
                        .frame(width: 20, height: 20)
                        .foregroundColor(stationStatusColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 3)
                }
            }
            .frame(width: 38)

            // ── Rechte Spalte: Inhalt ──────────────────────────────
            VStack(alignment: .leading, spacing: 6) {

                // Titel + Status-Dot
                HStack(spacing: 6) {
                    Text(station.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.theme.secondaryText)
                        .lineLimit(2)
                    Circle()
                        .fill(stationStatusColor)
                        .frame(width: 7, height: 7)
                    Spacer()
                }

                // Subtitle
                if let sub = station.subtitle {
                    Text(sub)
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.65))
                        .lineLimit(2)
                }

                // Datum & Dauer
                HStack(spacing: 12) {
                    if let start = station.startedAt {
                        Label(start.formatted(.dateTime.day().month(.abbreviated).year()),
                              systemImage: "calendar")
                            .font(.caption2)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                    }
                    if let dur = station.durationHours {
                        Label(formatDuration(dur), systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                    }
                }

                // Standort
                if let loc = station.location, let country = loc.country {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text([loc.city, loc.region, countryName(country)]
                            .compactMap { $0 }
                            .joined(separator: ", "))
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                }

                // CO₂
                if let co2 = station.co2KgPerKg {
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .font(.caption2)
                            .foregroundColor(.green.opacity(0.7))
                        Text("\(String(format: "%.3f", co2)) kg CO₂/kg")
                            .font(.caption2)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                    }
                }

                // Qualitätschecks Mini-Badges
                if !station.qualityChecks.isEmpty {
                    QualityCheckMiniRow(checks: station.qualityChecks)
                }

                // Verifiziert
                if station.isVerified, let by = station.verifiedBy {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("Verifiziert: \(by)")
                            .font(.caption2)
                            .foregroundColor(.green.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                // Notiz
                if let notes = station.notes {
                    Text(notes)
                        .font(.caption2)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.45))
                        .lineLimit(2)
                        .padding(.top, 1)
                }
            }
            .padding(.vertical, 6)
            .padding(.bottom, isLast ? 0 : 18)

            // ── Detail-Button ──────────────────────────────────────
            Button {
                navigateToDetail = true
            } label: {
                Ph.magnifyingGlass.duotone
                    .frame(width: 22, height: 22)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.3))
            }
            .padding(.top, 6)
            .fullScreenCover(isPresented: $navigateToDetail) {
                TomapoStationDetailView(
                    station: station,
                    onBack: { navigateToDetail = false }
                )
            }
        }
    }

    // MARK: Station Icon

    @ViewBuilder
    private var stationIcon: some View {
        switch station.type {
        case .farming:          Ph.plant.duotone
        case .fishing:          Ph.fish.duotone
        case .harvest:          Ph.knife.duotone
        case .sorting:          Ph.funnel.duotone
        case .processing:       Ph.gear.duotone
        case .cleaning:         Ph.dropHalf.duotone
        case .cutting:          Ph.scissors.duotone
        case .cooking:          Ph.thermometerHot.duotone
        case .fermenting:       Ph.flask.duotone
        case .drying:           Ph.sun.duotone
        case .freezing:         Ph.snowflake.duotone
        case .packaging:        Ph.package.duotone
        case .labeling:         Ph.tag.duotone
        case .sealing:          Ph.seal.duotone
        case .storage:          Ph.warehouse.duotone
        case .coldStorage:      Ph.thermometerCold.duotone
        case .frozenStorage:    Ph.snowflake.duotone
        case .ripening:         Ph.timer.duotone
        case .aging:            Ph.hourglass.duotone
        case .truckTransport:   Ph.truck.duotone
        case .railTransport:    Ph.train.duotone
        case .shipTransport:    Ph.boat.duotone
        case .airTransport:     Ph.airplane.duotone
        case .refrigeratedTruck: Ph.truck.duotone
        case .localDelivery:    Ph.van.duotone
        case .distribution:     Ph.arrowsOutLineHorizontal.duotone
        case .customsClearance: Ph.seal.duotone
        case .importInspection: Ph.magnifyingGlass.duotone
        case .retailStorage:    Ph.storefront.duotone
        case .retailDisplay:    Ph.storefront.duotone
        case .pointOfSale:      Ph.shoppingCart.duotone
        case .qualityInspection: Ph.clipboardText.duotone
        case .laboratoryTest:   Ph.flask.duotone
        case .certificationCheck: Ph.certificate.duotone
        case .veterinaryCheck:  Ph.firstAid.duotone
        case .unknown:          Ph.question.duotone
        }
    }

    // MARK: Status Color

    private var stationStatusColor: Color {
        switch station.status {
        case .completed:  return Color.theme.success
        case .warning:    return Color.theme.warning
        case .failed:     return Color.theme.error
        case .active:     return Color.theme.infso
        case .pending:    return Color.theme.stoneGreenGrey.opacity(0.4)
        case .skipped:    return Color.theme.stoneGreenGrey.opacity(0.3)
        case .unknown:    return Color.theme.stoneGreenGrey.opacity(0.35)
        }
    }

    // MARK: Helpers

    private func formatDuration(_ hours: Double) -> String {
        if hours < 1 { return "\(Int(hours * 60)) Min." }
        if hours < 24 { return "\(Int(hours)) Std." }
        let days = Int(hours / 24)
        let rem = Int(hours.truncatingRemainder(dividingBy: 24))
        return rem > 0 ? "\(days)d \(rem)h" : "\(days) Tage"
    }

    private func countryName(_ code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

// MARK: - Qualitätschecks Mini-Badges

private struct QualityCheckMiniRow: View {
    let checks: [TomapoQualityCheck]

    private var passed: Int { checks.filter { $0.status == .passed }.count }
    private var failed: Int { checks.filter { $0.status == .failed }.count }
    private var warnings: Int { checks.filter { $0.status == .warning }.count }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checklist")
                .font(.caption2)
                .foregroundColor(Color.theme.bodyText.opacity(0.45))

            if passed > 0 {
                StatusCountPill(count: passed, color: .green, icon: "checkmark")
            }
            if warnings > 0 {
                StatusCountPill(count: warnings, color: Color.theme.warning, icon: "exclamationmark")
            }
            if failed > 0 {
                StatusCountPill(count: failed, color: Color.theme.error, icon: "xmark")
            }
        }
    }
}

private struct StatusCountPill: View {
    let count: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text("\(count)")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        TomapoStationTimeline(stations: TomapoMockData.trace(for: "4316268651288")?.stations ?? [])
            .padding()
    }
    .background(Color.theme.oatMilk)
}
