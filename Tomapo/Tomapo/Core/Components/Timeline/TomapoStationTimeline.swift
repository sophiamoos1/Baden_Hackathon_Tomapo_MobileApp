//
//  TomapoStationTimeline.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
internal import PhosphorSwift

// MARK: - Timeline Main View

struct TomapoStationTimeline: View {
    let stations: [TomapoStation]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section header
            HStack(spacing: 8) {
                Text("Supply Chain")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.cardFg)
                Spacer()
                Text("\(stations.count) Stations")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.theme.mutedFg)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.theme.mutedBg)
                    .clipShape(Capsule())
            }

            // Timeline rows
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
                    StationTimelineRow(
                        station: station,
                        isLast: index == stations.count - 1
                    )
                }
            }
        }
        .padding(16)
        .background(Color.theme.cardBg)
        .cornerRadius(16)
    }
}

// MARK: - Station Row

private struct StationTimelineRow: View {
    let station: TomapoStation
    let isLast: Bool

    @State private var navigateToDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left column: Icon box + connecting line
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(stationStatusColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                    stationIcon
                        .frame(width: 22, height: 22)
                        .foregroundColor(stationStatusColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.theme.mutedFg.opacity(0.35))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 48)

            // Right column: Content card
            VStack(alignment: .leading, spacing: 8) {
                // Name + status badge
                HStack(spacing: 8) {
                    Text(station.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.cardFg)
                        .lineLimit(2)
                    Spacer()
                    StationStatusBadge(status: station.status)
                }

                // Meta row: date, duration
                HStack(spacing: 10) {
                    if let start = station.startedAt {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(start.formatted(.dateTime.day().month(.abbreviated).year()))
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Color.theme.mutedFg)
                    }
                    if let dur = station.durationHours {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(formatDuration(dur))
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Color.theme.mutedFg)
                    }
                }

                // Location
                if let loc = station.location, let country = loc.country {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text([loc.city, loc.region, countryName(country)]
                            .compactMap { $0 }
                            .joined(separator: ", "))
                            .font(.system(size: 11))
                            .lineLimit(1)
                    }
                    .foregroundColor(Color.theme.mutedFg)
                }

                // Footer: QC pills + Details button
                HStack(spacing: 6) {
                    if !station.qualityChecks.isEmpty {
                        QCPillRow(checks: station.qualityChecks)
                    }
                    Spacer()
                    Button {
                        navigateToDetail = true
                    } label: {
                        HStack(spacing: 3) {
                            Text("Details")
                                .font(.system(size: 11, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(Color.theme.mutedFg)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .overlay(
                            Capsule()
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }
                    .fullScreenCover(isPresented: $navigateToDetail) {
                        TomapoStationDetailView(
                            station: station,
                            onBack: { navigateToDetail = false }
                        )
                    }
                }
            }
            .padding(12)
            .background(Color.theme.mutedBg.opacity(0.5))
            .cornerRadius(14)
        }
        .padding(.bottom, isLast ? 0 : 6)
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
        case .pending:    return Color.theme.mutedFg.opacity(0.4)
        case .skipped:    return Color.theme.mutedFg.opacity(0.3)
        case .unknown:    return Color.theme.mutedFg.opacity(0.35)
        }
    }

    // MARK: Helpers

    private func formatDuration(_ hours: Double) -> String {
        if hours < 1 { return "\(Int(hours * 60)) min" }
        if hours < 24 { return "\(Int(hours)) hrs" }
        let days = Int(hours / 24)
        let rem = Int(hours.truncatingRemainder(dividingBy: 24))
        return rem > 0 ? "\(days)d \(rem)h" : "\(days) days"
    }

    private func countryName(_ code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

// MARK: - Status Badge Pill

private struct StationStatusBadge: View {
    let status: TomapoStationStatus

    var body: some View {
        Text(statusLabel)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var statusLabel: String {
        switch status {
        case .completed:  return "Completed"
        case .warning:    return "Warning"
        case .failed:     return "Failed"
        case .active:     return "Active"
        case .pending:    return "Pending"
        case .skipped:    return "Skipped"
        case .unknown:    return "Unknown"
        }
    }

    private var statusColor: Color {
        switch status {
        case .completed:  return Color.theme.success
        case .warning:    return Color.theme.warning
        case .failed:     return Color.theme.error
        case .active:     return Color.theme.infso
        case .pending:    return Color.theme.mutedFg
        case .skipped:    return Color.theme.mutedFg
        case .unknown:    return Color.theme.mutedFg
        }
    }
}

// MARK: - Quality Check Pills

private struct QCPillRow: View {
    let checks: [TomapoQualityCheck]

    private var passed: Int { checks.filter { $0.status == .passed }.count }
    private var warnings: Int { checks.filter { $0.status == .warning }.count }
    private var failed: Int { checks.filter { $0.status == .failed }.count }

    var body: some View {
        HStack(spacing: 6) {
            if passed > 0 {
                QCPill(icon: "checkmark", count: passed, color: Color.theme.success)
            }
            if warnings > 0 {
                QCPill(icon: "exclamationmark.triangle.fill", count: warnings, color: Color.theme.warning)
            }
            if failed > 0 {
                QCPill(icon: "xmark", count: failed, color: Color.theme.error)
            }
        }
    }
}

private struct QCPill: View {
    let icon: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text("\(count)")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        TomapoStationTimeline(stations: TomapoMockData.trace(for: "4316268651288")?.stations ?? [])
            .padding()
    }
    .background(Color.theme.baseBg)
}
