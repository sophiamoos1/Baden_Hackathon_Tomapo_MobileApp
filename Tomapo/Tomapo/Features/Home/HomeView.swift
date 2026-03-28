//
//  HomeView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var historyStore: ScanHistoryStore

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: ── Greeting + Carousel ───────────────────────
                    HomeGreetingSection()
                        .padding(.top, geo.safeAreaInsets.top + 16)
                        .background(Color.theme.baseBg)
                        .padding(.bottom, 20)

                    // MARK: ── Content Sections ──────────────────────────
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: Sustainability Score
                        HomeSustainabilitySection()

                        // MARK: Recent Scans
                        HomeRecentScansSection(
                            entries: Array(historyStore.entries.prefix(2)),
                            onSeeAll: { selectedTab = .history }
                        )

                        // MARK: Community
                        HomeCommunitySection()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Sustainability Score Section

private struct HomeSustainabilitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sustainability score")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.cardFg)

            VStack(spacing: 12) {
                // Top row: score + trend
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("78")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.success)
                        Text("out of 100 · this month")
                            .font(.caption2)
                            .foregroundColor(Color.theme.mutedFg)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("↑ +5 vs last month")
                            .font(.caption2)
                            .foregroundColor(Color.theme.success)
                        Text("Top 22% of users")
                            .font(.caption2)
                            .foregroundColor(Color.theme.mutedFg)
                    }
                }

                // Sub-score grid
                HStack(spacing: 8) {
                    SustainabilitySubScore(label: "LOCAL", value: "82", color: Color.theme.success)
                    SustainabilitySubScore(label: "ORGANIC", value: "61", color: Color.theme.warning)
                    SustainabilitySubScore(label: "CO₂", value: "88", color: Color.theme.success)
                }
            }
            .padding(14)
            .background(Color.theme.mutedBg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.theme.border, lineWidth: 0.5)
            )
        }
    }
}

private struct SustainabilitySubScore: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(Color.theme.mutedFg)
                .tracking(0.4)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.theme.primaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Recent Scans Section

private struct HomeRecentScansSection: View {
    let entries: [ScanHistoryEntry]
    let onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent scans")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.cardFg)
                Spacer()
                Button(action: onSeeAll) {
                    Text("See all →")
                        .font(.caption2)
                        .foregroundColor(Color.theme.mutedFg)
                }
            }

            if entries.isEmpty {
                // Placeholder when no scans yet
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.theme.success.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text("🍅")
                            .font(.system(size: 14))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No scans yet")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.theme.cardFg)
                        Text("Scan a barcode to get started")
                            .font(.caption2)
                            .foregroundColor(Color.theme.mutedFg)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color.theme.mutedBg)
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Color.theme.border, lineWidth: 0.5)
                )
            } else {
                VStack(spacing: 6) {
                    ForEach(entries) { entry in
                        HomeRecentScanRow(entry: entry)
                    }
                }
            }
        }
    }
}

private struct HomeRecentScanRow: View {
    let entry: ScanHistoryEntry

    private var timeAgoText: String {
        let interval = Date().timeIntervalSince(entry.scannedAt)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "just now" }
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }

    private var scoreValue: Int? {
        // Use ecoscore as a rough sustainability proxy if available
        guard let grade = entry.ecoscoreGrade?.lowercased() else { return nil }
        switch grade {
        case "a": return 91
        case "b": return 78
        case "c": return 61
        case "d": return 44
        case "e": return 27
        default: return nil
        }
    }

    private var scoreColor: Color {
        guard let score = scoreValue else { return Color.theme.mutedFg }
        if score >= 70 { return Color.theme.success }
        if score >= 50 { return Color.theme.warning }
        return Color.theme.error
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.theme.success.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text("🍅")
                    .font(.system(size: 14))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.cardFg)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    if let score = scoreValue {
                        Text("Score \(score)")
                            .font(.caption2)
                            .foregroundColor(Color.theme.mutedFg)
                        Text("·")
                            .font(.caption2)
                            .foregroundColor(Color.theme.mutedFg)
                    }
                    Text(timeAgoText)
                        .font(.caption2)
                        .foregroundColor(Color.theme.mutedFg)
                }
            }

            Spacer()

            if let score = scoreValue {
                Text("\(score)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(scoreColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.theme.mutedBg)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(Color.theme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Community Section

private struct HomeCommunitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Community")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.cardFg)
                Spacer()
                Text("See all →")
                    .font(.caption2)
                    .foregroundColor(Color.theme.mutedFg)
            }

            VStack(spacing: 6) {
                CommunityRow(
                    initial: "L",
                    color: Color.theme.success,
                    text: "**Lisa** rated Bio Apfelsaft 5 stars",
                    time: "3m"
                )
                CommunityRow(
                    initial: "M",
                    color: Color.theme.error,
                    text: "**Max** flagged cold chain issue on Lachs",
                    time: "12m"
                )
            }
        }
    }
}

private struct CommunityRow: View {
    let initial: String
    let color: Color
    let text: LocalizedStringKey
    let time: String

    var body: some View {
        HStack(spacing: 8) {
            Text(initial)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .frame(width: 22, height: 22)
                .background(color.opacity(0.2))
                .clipShape(Circle())

            Text(text)
                .font(.caption2)
                .foregroundColor(Color.theme.mutedFg)
                .lineLimit(1)

            Spacer()

            Text(time)
                .font(.caption2)
                .foregroundColor(Color.theme.mutedFg)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.theme.mutedBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.theme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        GeometryReader { geo in
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .ignoresSafeArea()
        HomeView(selectedTab: .constant(.home))
            .environmentObject(ThemeManager())
            .environmentObject(ScanHistoryStore())
    }
}
