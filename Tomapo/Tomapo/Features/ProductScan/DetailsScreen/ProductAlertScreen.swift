//
//  ProductAlertScreen.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct ProductAlertsScreen: View {
    let product: TomapoResponse
    var onBack: () -> Void

    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
    @EnvironmentObject private var userStore: TomapoUserStore
    @State private var showSubmitSheet = false
    @State private var filter: AlertFilter = .all

    enum AlertFilter: String, CaseIterable {
        case all        = "All"
        case recalls    = "Recalls"
        case community  = "Community"
        case official   = "Official"
        case own        = "My Reports"
    }

    private var filteredAlerts: [TomapoProductAlert] {
        switch filter {
        case .all:       return product.alerts
        case .recalls:   return product.alerts.filter { $0.isRecall }
        case .community: return product.alerts.filter { $0.source == .user || $0.source == .community }
        case .official:  return product.alerts.filter { $0.isOfficial }
        case .own:       return product.alerts.filter { $0.isOwnUserReport }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.baseBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Color.clear.frame(height: 60 + 60) // BackBar + Filter

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        // Neue Meldung Button
                        newAlertButton.padding(.horizontal, 16)

                        if product.alerts.isEmpty {
                            emptyState
                        } else {
                            if filteredAlerts.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "line.3.horizontal.decrease").font(.system(size: 32)).foregroundColor(Color.theme.mutedFg.opacity(0.25))
                                    Text("No alerts in this category").font(.subheadline).foregroundColor(Color.theme.mutedFg)
                                }
                                .frame(maxWidth: .infinity).padding(.top, 40)
                            } else {
                                ForEach(filteredAlerts) { alert in
                                    AlertCard(alert: alert).padding(.horizontal, 16)
                                }
                            }
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16).padding(.bottom, 32)
                }
            }

            // BackBar + Filter (fixiert oben)
            VStack(spacing: 0) {
                BackNavigationBar(title: "Alerts", onBack: onBack)
                filterBar
            }
        }
        .sheet(isPresented: $showSubmitSheet) {
            SubmitAlertSheet(product: product, onSubmit: { message in
                userMessageStore.add(
                    authorId: userStore.currentUser?.id ?? "guest",
                    authorNickname: userStore.currentUser?.nickname ?? "Anonymous",
                    productSnapshot: TomapoMessageProductSnapshot(
                        barcode: product.barcode, batchId: product.batchId,
                        productName: product.productName, brand: product.brands,
                        quantity: product.quantity, imageUrl: product.displayImageUrl,
                        nutriscoreGrade: product.nutriscoreGrade, ecoscoreGrade: product.ecoscoreGrade,
                        categoriesTags: product.categoriesTags, scannedAt: Date(), scannedAtStoreName: nil),
                    category: message.category, title: message.title,
                    body: message.body, severity: message.severity)
                showSubmitSheet = false
            })
            .environmentObject(userStore)
        }
    }

    // MARK: - Subviews

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AlertFilter.allCases, id: \.self) { f in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { filter = f }
                    } label: {
                        HStack(spacing: 4) {
                            Text(f.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(filter == f ? .white : Color.theme.cardFg)
                            if f == .recalls && product.hasActiveRecall {
                                Circle().fill(Color.theme.error).frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(filter == f ? Color.theme.infso : Color.theme.cardBg)
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Color.theme.baseBg)
        .overlay(Divider(), alignment: .bottom)
    }

    private var newAlertButton: some View {
        Button {
            showSubmitSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill").font(.system(size: 20)).foregroundColor(Color.theme.accentFg)
                Text("Submit New Alert").font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                Spacer()
                Image(systemName: "chevron.right").font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.35))
            }
            .padding(14).background(Color.theme.cardBg).cornerRadius(14)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).foregroundColor(Color.theme.success.opacity(0.6))
            Text("No Alerts").font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
            Text("No alerts have been reported for this product.").font(.caption).foregroundColor(Color.theme.mutedFg).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 60).padding(.horizontal, 40)
    }
}

// MARK: - Alert Card

private struct AlertCard: View {
    let alert: TomapoProductAlert

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                // Severity Icon
                ZStack {
                    Circle().fill(severityColor.opacity(0.12)).frame(width: 36, height: 36)
                    Image(systemName: severityIcon).font(.system(size: 15)).foregroundColor(severityColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(alert.title).font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg).lineLimit(2)
                    HStack(spacing: 6) {
                        SeverityBadge(severity: alert.severity)
                        SourceBadge(source: alert.source)
                    }
                }
                Spacer()
                StatusDot(status: alert.status)
            }

            Text(alert.description).font(.caption).foregroundColor(Color.theme.mutedFg)
                .lineLimit(3).fixedSize(horizontal: false, vertical: true)

            if let action = alert.actionRequired {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill").font(.caption2).foregroundColor(severityColor)
                    Text(action).font(.caption.weight(.semibold)).foregroundColor(severityColor).lineLimit(2)
                }
            }

            // Footer: Autor + Datum + Bestätigungen
            HStack(spacing: 10) {
                if let avatar = alert.authorAvatarUrl {
                    AsyncImage(url: URL(string: avatar)) { img in img.resizable().scaledToFill() } placeholder: { Color.theme.cardBg }
                        .frame(width: 18, height: 18).clipShape(Circle())
                } else {
                    Image(systemName: alert.isOfficial ? "building.2.fill" : "person.fill")
                        .font(.caption2).foregroundColor(Color.theme.mutedFg)
                }
                Text(alert.displayAuthor).font(.caption2).foregroundColor(Color.theme.mutedFg)
                Spacer()
                if alert.confirmationCount > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "hand.thumbsup.fill").font(.system(size: 9)).foregroundColor(Color.theme.success)
                        Text("\(alert.confirmationCount)").font(.caption2).foregroundColor(Color.theme.success)
                    }
                }
                Text(alert.createdAt.formatted(.dateTime.day().month(.abbreviated).year()))
                    .font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.5))
            }
        }
        .padding(14).background(Color.theme.cardBg).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(alert.isRecall ? severityColor.opacity(0.3) : Color.clear, lineWidth: 1))
    }

    private var severityColor: Color {
        switch alert.severity {
        case .critical: return Color.theme.error
        case .high:     return Color.theme.warning
        case .medium:   return Color.theme.warning
        case .low:      return Color.theme.infso
        default:        return Color.theme.mutedFg
        }
    }

    private var severityIcon: String {
        switch alert.severity {
        case .critical: return "exclamationmark.triangle.fill"
        case .high:     return "exclamationmark.circle.fill"
        case .medium:   return "exclamationmark.circle"
        case .low:      return "info.circle"
        default:        return "info.circle"
        }
    }
}

private struct SeverityBadge: View {
    let severity: AlertSeverity
    var body: some View {
        Text(label).font(.caption2).foregroundColor(color)
            .padding(.horizontal, 7).padding(.vertical, 2).background(color.opacity(0.1)).cornerRadius(8)
    }
    private var label: String {
        switch severity {
        case .critical: return "Critical"; case .high: return "High"
        case .medium: return "Medium"; case .low: return "Low"; case .info: return "Info"
        }
    }
    private var color: Color {
        switch severity {
        case .critical: return Color.theme.error; case .high: return Color.theme.warning
        case .medium: return Color.theme.warning; case .low: return Color.theme.infso; default: return Color.theme.mutedFg
        }
    }
}

private struct SourceBadge: View {
    let source: AlertSource
    var body: some View {
        Text(label).font(.caption2).foregroundColor(color)
            .padding(.horizontal, 7).padding(.vertical, 2).background(color.opacity(0.1)).cornerRadius(8)
    }
    private var label: String {
        switch source {
        case .ownUser: return "My Report"; case .official: return "Manufacturer"
        case .government: return "Authority"; case .user: return "Community"
        case .community: return "Community"; case .system: return "System"
        }
    }
    private var color: Color {
        switch source {
        case .ownUser: return Color.theme.chartMutedPlumEarth; case .official, .government: return Color.theme.infso
        case .user, .community: return Color.theme.warning; case .system: return Color.theme.mutedFg
        }
    }
}

private struct StatusDot: View {
    let status: AlertStatus
    var body: some View {
        Circle().fill(color).frame(width: 8, height: 8)
    }
    private var color: Color {
        switch status {
        case .active, .verified: return Color.theme.success
        case .pending:           return Color.theme.warning
        case .rejected, .expired, .resolved: return Color.theme.mutedFg.opacity(0.35)
        }
    }
}
