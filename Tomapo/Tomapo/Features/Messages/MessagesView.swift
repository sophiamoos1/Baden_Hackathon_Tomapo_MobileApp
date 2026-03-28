//
//  MessagesView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
struct MessagesView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore
    @EnvironmentObject private var historyStore: ScanHistoryStore
 
    @State private var filter: MessageFilter = .all
    @State private var selectedMessage: TomapoUserMessage? = nil
 
    enum MessageFilter: String, CaseIterable {
        case all     = "Alle"
        case own     = "Meine"
        case pending = "Ausstehend"
    }
 
    private var filteredMessages: [TomapoUserMessage] {
        switch filter {
        case .all:     return userMessageStore.messages
        case .own:     return userMessageStore.messages
        case .pending: return userMessageStore.messages.filter {
            $0.submissionStatus == .draft || $0.submissionStatus == .submitted
        }
        }
    }
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
 
                // Header
                header
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 16)
 
                // Filter
                filterBar.padding(.bottom, 12)
 
                // Inhalt
                if filteredMessages.isEmpty {
                    emptyState
                } else {
                    messageList
                }
            }
            .padding(.bottom, 40)
        }
        .fullScreenCover(item: $selectedMessage) { msg in
            MessageDetailView(message: msg, onBack: { selectedMessage = nil })
                .environmentObject(historyStore)
        }
    }
 
    // MARK: - Header
 
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Meldungen")
                .font(.largeTitle).fontWeight(.heavy)
                .foregroundColor(Color.theme.cardFg)
            HStack(spacing: 12) {
                Text("\(userMessageStore.messages.count) Meldung\(userMessageStore.messages.count == 1 ? "" : "en")")
                    .font(.subheadline).foregroundColor(Color.theme.cardFg)
                let pending = userMessageStore.messages.filter { $0.submissionStatus == .draft }.count
                if pending > 0 {
                    HStack(spacing: 4) {
                        Circle().fill(Color.theme.warning).frame(width: 6, height: 6)
                        Text("\(pending) Entwurf\(pending == 1 ? "" : "e")")
                            .font(.caption).foregroundColor(Color.theme.warning)
                    }
                }
            }
        }
    }
 
    // MARK: - Filter Bar
 
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MessageFilter.allCases, id: \.self) { f in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { filter = f }
                    } label: {
                        Text(f.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(filter == f ? .white : Color.theme.cardFg)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(filter == f ? Color.theme.infso : Color.theme.cardBg)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
 
    // MARK: - Message List
 
    private var messageList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filteredMessages) { msg in
                MessageRow(message: msg) { selectedMessage = msg }
                    .padding(.horizontal, 16)
            }
        }
    }
 
    // MARK: - Empty State
 
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(Color.theme.mutedFg.opacity(0.35))
            Text("Keine Meldungen")
                .font(.headline).foregroundColor(Color.theme.cardFg)
            Text("Du hast noch keine Meldungen erfasst. Scanne ein Produkt und melde einen Mangel.")
                .font(.subheadline).foregroundColor(Color.theme.cardFg)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 80).padding(.horizontal, 40)
    }
}
 
// MARK: - Message Row
 
private struct MessageRow: View {
    let message: TomapoUserMessage
    let onTap: () -> Void
 
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    // Severity Icon
                    ZStack {
                        Circle().fill(severityColor.opacity(0.12)).frame(width: 38, height: 38)
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.system(size: 16)).foregroundColor(severityColor)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(message.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.theme.cardFg).lineLimit(2)
                        Text(message.displayProductName)
                            .font(.caption).foregroundColor(Color.theme.mutedFg).lineLimit(1)
                    }
                    Spacer()
                    StatusPill(status: message.submissionStatus)
                }
 
                Text(message.displayBodyPreview)
                    .font(.caption).foregroundColor(Color.theme.mutedFg)
                    .lineLimit(2)
 
                HStack(spacing: 10) {
                    SeverityChipSmall(severity: message.severity)
                    CategoryChipSmall(category: message.category)
                    Spacer()
                    Text(message.createdAt.formatted(.dateTime.day().month(.abbreviated).year()))
                        .font(.caption2).foregroundColor(Color.theme.mutedFg)
                }
            }
            .padding(14)
            .background(Color.theme.cardBg)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
 
    private var severityColor: Color {
        switch message.severity {
        case .critical: return Color.theme.error
        case .high:     return Color.theme.warning
        case .medium:   return Color.theme.warning
        case .low:      return Color.theme.infso
        default:        return Color.theme.mutedFg
        }
    }
}
 
private struct StatusPill: View {
    let status: MessageSubmissionStatus
    var body: some View {
        Text(label).font(.caption2).foregroundColor(color)
            .padding(.horizontal, 7).padding(.vertical, 3).background(color.opacity(0.1)).cornerRadius(8)
    }
    private var label: String {
        switch status {
        case .draft:     return "Entwurf"
        case .submitted: return "Gesendet"
        case .published: return "Veröffentlicht"
        case .rejected:  return "Abgelehnt"
        }
    }
    private var color: Color {
        switch status {
        case .draft:     return Color.theme.mutedFg
        case .submitted: return Color.theme.warning
        case .published: return Color.theme.success
        case .rejected:  return Color.theme.error
        }
    }
}
 
private struct SeverityChipSmall: View {
    let severity: AlertSeverity
    var body: some View {
        Text(label).font(.caption2).foregroundColor(color)
            .padding(.horizontal, 6).padding(.vertical, 2).background(color.opacity(0.1)).cornerRadius(6)
    }
    private var label: String {
        switch severity { case .low: return "Niedrig"; case .medium: return "Mittel"; case .high: return "Hoch"; case .critical: return "Kritisch"; default: return "Info" }
    }
    private var color: Color {
        switch severity { case .low: return Color.theme.infso; case .medium: return Color.theme.warning; case .high: return Color.theme.warning; case .critical: return Color.theme.error; default: return Color.theme.mutedFg }
    }
}
 
private struct CategoryChipSmall: View {
    let category: AlertCategory
    var body: some View {
        Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
            .padding(.horizontal, 6).padding(.vertical, 2).background(Color.theme.cardBg).cornerRadius(6)
    }
    private var label: String {
        switch category {
        case .mold:            return "Schimmel"
        case .qualityDefect:   return "Qualität"
        case .foreignObject:   return "Fremdkörper"
        case .packagingDefect: return "Verpackung"
        case .allergenWarning: return "Allergen"
        case .labelingError:   return "Etikett"
        case .foodSafety:      return "Sicherheit"
        default:               return "Info"
        }
    }
}
 
// MARK: - Message Detail View
 
struct MessageDetailView: View {
    let message: TomapoUserMessage
    var onBack: () -> Void
 
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @State private var showProductDetail = false
 
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.baseBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 60)
 
                    // Meldungs-Header
                    alertHeader.padding(.horizontal, 16)
 
                    // Produkt-Verknüpfung
                    productCard.padding(.horizontal, 16)
 
                    // Details
                    messageDetails.padding(.horizontal, 16)
 
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackNavigationBar(title: "Meldungsdetails", onBack: onBack)
        }
        .fullScreenCover(isPresented: $showProductDetail) {
            // Produkt neu laden via ScanHistoryEntry
            let fakeEntry = ScanHistoryEntry(
                barcode: message.barcode,
                barcodeType: "EAN13",
                batchId: message.batchId,
                productName: message.productSnapshot.productName,
                brand: message.productSnapshot.brand
            )
            ProductDetailView(entry: fakeEntry, onBack: { showProductDetail = false })
                .environmentObject(historyStore)
                .environmentObject(TomapoUserMessageStore())
                .environmentObject(TomapoUserStore())
        }
    }
 
    private var alertHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(severityColor.opacity(0.12)).frame(width: 48, height: 48)
                    Image(systemName: "exclamationmark.bubble.fill").font(.system(size: 20)).foregroundColor(severityColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.title).font(.title3.weight(.bold)).foregroundColor(Color.theme.cardFg).lineLimit(2)
                    HStack(spacing: 8) {
                        SeverityChipSmall(severity: message.severity)
                        StatusPill(status: message.submissionStatus)
                    }
                }
                Spacer()
            }
            Text(message.body).font(.subheadline).foregroundColor(Color.theme.mutedFg)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14).background(Color.theme.cardBg).cornerRadius(14)
    }
 
    private var productCard: some View {
        Button { showProductDetail = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.theme.mutedBg).frame(width: 44, height: 44)
                    Image(systemName: "cart.fill").font(.system(size: 18)).foregroundColor(Color.theme.accentFg)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(message.displayProductName).font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg).lineLimit(1)
                    if let brand = message.productSnapshot.brand {
                        Text(brand).font(.caption).foregroundColor(Color.theme.mutedFg)
                    }
                    Text("Barcode: \(message.barcode)").font(.caption2).foregroundColor(Color.theme.mutedFg)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.35))
            }
            .padding(12).background(Color.theme.cardBg).cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
 
    private var messageDetails: some View {
        VStack(spacing: 0) {
            SheetSection(title: "Metadaten", icon: "info.circle") {
                VStack(spacing: 0) {
                    InfoRow(label: "Autor",    value: message.displayAuthor)
                    Divider().padding(.leading, 16)
                    InfoRow(label: "Kategorie", value: categoryLabel)
                    Divider().padding(.leading, 16)
                    InfoRow(label: "Erstellt",  value: message.createdAt.formatted(.dateTime.day().month(.wide).year().hour().minute()))
                    if message.createdAt != message.updatedAt {
                        Divider().padding(.leading, 16)
                        InfoRow(label: "Aktualisiert", value: message.updatedAt.formatted(.dateTime.day().month().year()))
                    }
                    if let batch = message.batchId {
                        Divider().padding(.leading, 16)
                        InfoRow(label: "Charge", value: batch)
                    }
                }
                .background(Color.theme.cardBg).cornerRadius(12)
            }
        }
    }
 
    private var severityColor: Color {
        switch message.severity {
        case .critical: return Color.theme.error; case .high: return Color.theme.warning
        case .medium: return Color.theme.warning; case .low: return Color.theme.infso; default: return Color.theme.mutedFg
        }
    }
 
    private var categoryLabel: String {
        switch message.category {
        case .mold: return "Schimmel"; case .qualityDefect: return "Qualitätsmangel"
        case .foreignObject: return "Fremdkörper"; case .packagingDefect: return "Verpackungsschaden"
        case .allergenWarning: return "Allergen-Warnung"; case .labelingError: return "Etikettierfehler"
        case .foodSafety: return "Lebensmittelsicherheit"; default: return message.category.rawValue.capitalized
        }
    }
}
 
// MARK: - Preview
 
#Preview {
    MessagesView(selectedTab: .constant(.messages))
        .environmentObject(ThemeManager())
        .environmentObject(TomapoUserMessageStore())
        .environmentObject(ScanHistoryStore())
        .background(Color.theme.baseBg)
}
