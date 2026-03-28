//
//  ColdChainCardView.swift
//  Tomapo
//
//  Created by Sophia Moos on 28.03.2026.
//

internal import SwiftUI
internal import PhosphorSwift

// MARK: - Public API

struct ColdChainCardView: View {
    let summary: TomapoColdChainSummary
    let stations: [TomapoStation]

    private var refrigeratedStations: [TomapoStation] {
        stations.filter { $0.wasRefrigerated }
    }

    private var avgTemp: Double? {
        let temps = refrigeratedStations.compactMap { $0.refrigerationTemperatureCelsius }
        guard !temps.isEmpty else { return nil }
        return temps.reduce(0, +) / Double(temps.count)
    }

    private var avgTempOk: Bool {
        guard let avg = avgTemp else { return true }
        return avg <= 5.0
    }

    private var peakTempExceeded: Bool {
        guard let peak = summary.highestTemperatureCelsius else { return false }
        return peak > 5.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Cold Chain")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.cardFg)
                Spacer()
                if summary.hadColdChainBreak {
                    Text("\(summary.coldChainBreakCount) Warning\(summary.coldChainBreakCount == 1 ? "" : "s")")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.theme.warning)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 2)
                        .background(Color.theme.warning.opacity(0.13))
                        .clipShape(Capsule())
                } else {
                    Text("Intact")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.theme.success)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 2)
                        .background(Color.theme.success.opacity(0.13))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Rectangle().fill(Color.theme.border).frame(height: 0.5).padding(.horizontal, 18)

            // Summary stats
            HStack(spacing: 8) {
                SummaryStatBox(
                    label: "Avg. Temp.",
                    value: avgTemp.map { String(format: "%.1f°C", $0) } ?? "–",
                    subtitle: avgTempOk ? "in range" : "elevated",
                    valueColor: avgTempOk ? Color.theme.success : Color.theme.error
                )
                SummaryStatBox(
                    label: "Max. Temp.",
                    value: summary.highestTemperatureCelsius.map { String(format: "%.1f°C", $0) } ?? "–",
                    subtitle: peakTempExceeded ? "exceeded" : "in range",
                    valueColor: peakTempExceeded ? Color.theme.error : Color.theme.success
                )
                SummaryStatBox(
                    label: "Interruptions",
                    value: "\(summary.coldChainBreakCount)",
                    subtitle: breakDurationText,
                    valueColor: summary.hadColdChainBreak ? Color.theme.warning : Color.theme.success
                )
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 12)

            // Mini temperature chart
            if refrigeratedStations.count >= 2 {
                MiniTempChart(
                    stations: refrigeratedStations,
                    peakTemp: summary.highestTemperatureCelsius
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 12)
            }

            Rectangle().fill(Color.theme.border).frame(height: 0.5).padding(.horizontal, 18).padding(.bottom, 12)

            // Station rows
            VStack(spacing: 8) {
                ForEach(refrigeratedStations) { station in
                    ColdChainStationRow(station: station)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .background(Color.theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.theme.border, lineWidth: 0.5)
        )
    }

    private var breakDurationText: String {
        guard let mins = summary.totalBreakDurationMinutes, mins > 0 else {
            return summary.hadColdChainBreak ? "unknown" : "none"
        }
        if mins < 60 { return "\(mins) Min." }
        let h = mins / 60
        let m = mins % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h Dauer"
    }
}

// MARK: - Summary Stat Box

private struct SummaryStatBox: View {
    let label: String
    let value: String
    let subtitle: String
    let valueColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(0.5)
                .foregroundColor(Color.theme.mutedFg.opacity(0.6))
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(valueColor)
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(Color.theme.mutedFg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.theme.mutedBg)
        .cornerRadius(10)
    }
}

// MARK: - Mini Temperature Chart

private struct MiniTempChart: View {
    let stations: [TomapoStation]
    let peakTemp: Double?

    var body: some View {
        let temps = stations.compactMap { $0.refrigerationTemperatureCelsius }
        let minT = (temps.min() ?? 0) - 1
        let maxT = max((temps.max() ?? 8) + 1, (peakTemp ?? 0) + 1)
        let range = maxT - minT

        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.mutedBg)
                .frame(height: 52)

            GeometryReader { geo in
                let w = geo.size.width
                let h: CGFloat = 52
                let padding: CGFloat = 10
                let usableW = w - padding * 2
                let usableH = h - 16

                // Green safe zone (0-5°C)
                let safeBottom = yPos(for: 0, minT: minT, range: range, height: usableH, topPad: 4)
                let safeTop = yPos(for: 5, minT: minT, range: range, height: usableH, topPad: 4)
                Rectangle()
                    .fill(Color.theme.success.opacity(0.07))
                    .frame(height: max(safeBottom - safeTop, 0))
                    .offset(x: 0, y: safeTop)

                // Temperature line
                if temps.count >= 2 {
                    Path { path in
                        for (i, temp) in temps.enumerated() {
                            let x = padding + usableW * CGFloat(i) / CGFloat(temps.count - 1)
                            let y = yPos(for: temp, minT: minT, range: range, height: usableH, topPad: 4)
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(Color.theme.infso, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))

                    // Gradient fill under line
                    Path { path in
                        for (i, temp) in temps.enumerated() {
                            let x = padding + usableW * CGFloat(i) / CGFloat(temps.count - 1)
                            let y = yPos(for: temp, minT: minT, range: range, height: usableH, topPad: 4)
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        let lastX = padding + usableW
                        path.addLine(to: CGPoint(x: lastX, y: h))
                        path.addLine(to: CGPoint(x: padding, y: h))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.theme.infso.opacity(0.35), Color.theme.infso.opacity(0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                    // Peak marker
                    if let peak = peakTemp, let maxIdx = temps.firstIndex(where: { $0 == temps.max() }) {
                        let px = padding + usableW * CGFloat(maxIdx) / CGFloat(temps.count - 1)
                        let py = yPos(for: peak, minT: minT, range: range, height: usableH, topPad: 4)
                        Circle()
                            .fill(Color.theme.error)
                            .frame(width: 7, height: 7)
                            .position(x: px, y: py)
                    }
                }

                // Station labels at bottom
                HStack {
                    ForEach(Array(stations.enumerated()), id: \.element.id) { i, station in
                        if i == 0 { Spacer().frame(width: 0) }
                        Text(shortStationLabel(station))
                            .font(.system(size: 8))
                            .foregroundColor(Color.theme.mutedFg.opacity(0.5))
                        if i < stations.count - 1 { Spacer() }
                    }
                }
                .padding(.horizontal, padding)
                .frame(height: h, alignment: .bottom)
                .offset(y: -4)
            }
        }
        .frame(height: 52)
    }

    private func yPos(for temp: Double, minT: Double, range: Double, height: CGFloat, topPad: CGFloat) -> CGFloat {
        guard range > 0 else { return topPad + height / 2 }
        return topPad + height * (1 - CGFloat((temp - minT) / range))
    }

    private func shortStationLabel(_ station: TomapoStation) -> String {
        switch station.type {
        case .coldStorage, .frozenStorage: return "Storage"
        case .truckTransport, .refrigeratedTruck, .localDelivery: return "Transport"
        case .railTransport: return "Rail"
        case .shipTransport: return "Ship"
        case .airTransport: return "Air"
        case .retailStorage, .retailDisplay, .pointOfSale: return "Retail"
        case .distribution: return "Distribution"
        default: return station.location?.city ?? "Station"
        }
    }
}

// MARK: - Station Row

private struct ColdChainStationRow: View {
    let station: TomapoStation

    private var isBreak: Bool {
        switch station.detail {
        case .coldStorage(let d): return d.coldChainBroken
        case .transport(let d): return d.coldStorageDetail?.coldChainBroken ?? false
        default: return false
        }
    }

    private var peakBreakTemp: Double? {
        switch station.detail {
        case .coldStorage(let d):
            return d.coldChainBreaks.map(\.maxTemperatureReached).max()
        case .transport(let d):
            return d.coldStorageDetail?.coldChainBreaks.map(\.maxTemperatureReached).max()
        default: return nil
        }
    }

    private var iconColor: Color {
        if isBreak { return Color.theme.error }
        switch station.type {
        case .truckTransport, .refrigeratedTruck, .railTransport, .shipTransport, .airTransport, .localDelivery:
            return Color.theme.infso
        default:
            return Color.theme.success
        }
    }

    @ViewBuilder
    private var stationIcon: some View {
        if isBreak {
            Ph.warning.duotone
        } else {
            switch station.type {
            case .coldStorage, .frozenStorage:
                Ph.snowflake.duotone
            case .truckTransport, .refrigeratedTruck, .localDelivery:
                Ph.truck.duotone
            case .railTransport:
                Ph.train.duotone
            case .shipTransport:
                Ph.boat.duotone
            case .airTransport:
                Ph.airplane.duotone
            case .retailStorage, .retailDisplay, .pointOfSale:
                Ph.storefront.duotone
            case .distribution:
                Ph.arrowsOutLineHorizontal.duotone
            default:
                Ph.thermometerCold.duotone
            }
        }
    }

    private var displayTemp: String {
        if isBreak, let peak = peakBreakTemp {
            return String(format: "%.1f°C", peak)
        }
        guard let temp = station.refrigerationTemperatureCelsius else { return "–" }
        return String(format: "%.1f°C", temp)
    }

    private var tempColor: Color {
        if isBreak { return Color.theme.error }
        guard let temp = station.refrigerationTemperatureCelsius else { return Color.theme.mutedFg }
        return temp <= 5.0 ? Color.theme.success : Color.theme.error
    }

    private var subtitle: String {
        var parts: [String] = []
        if let loc = station.location {
            let place = [loc.city, loc.country].compactMap { $0 }.joined(separator: ", ")
            if !place.isEmpty { parts.append(place) }
        }
        if let date = station.startedAt {
            parts.append(date.formatted(.dateTime.day().month(.abbreviated)))
        }
        if let dur = station.durationHours {
            parts.append(formatDuration(dur))
        } else if station.status == .active {
            parts.append("ongoing")
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.14))
                    .frame(width: 42, height: 42)
                stationIcon
                    .frame(width: 22, height: 22)
                    .foregroundColor(iconColor)
            }

            // Body
            VStack(alignment: .leading, spacing: 2) {
                Text(isBreak ? "Chain Interruption" : station.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isBreak ? Color.theme.error : Color.theme.cardFg)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.theme.mutedFg)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(Color.theme.mutedFg)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Temperature
            VStack(alignment: .trailing, spacing: 2) {
                Text(displayTemp)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(tempColor)
                Text(isBreak ? "max" : "Ø")
                    .font(.system(size: 9))
                    .foregroundColor(Color.theme.mutedFg.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.theme.mutedBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isBreak ? Color.theme.error.opacity(0.35) : Color.theme.border, lineWidth: 0.5)
        )
    }

    private func formatDuration(_ hours: Double) -> String {
        if hours < 1 { return "\(Int(hours * 60)) min" }
        if hours < 24 { return "\(Int(hours))h" }
        let days = Int(hours / 24)
        return "\(days) days"
    }
}
