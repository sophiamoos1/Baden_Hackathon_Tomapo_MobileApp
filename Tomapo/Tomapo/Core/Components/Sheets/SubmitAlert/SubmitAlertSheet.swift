//
//  AlertSheet.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//
internal import SwiftUI

// MARK: - Draft Struct

struct AlertDraft {
    var title: String = ""
    var body: String = ""
    var category: AlertCategory = .qualityDefect
    var severity: AlertSeverity = .medium
}

// MARK: - Submit Alert Sheet

struct SubmitAlertSheet: View {
    let product: TomapoResponse
    let onSubmit: (AlertDraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userStore: TomapoUserStore
    @State private var draft = AlertDraft()
    @State private var showValidationError = false

    private let selectableCategories: [AlertCategory] = [
        .mold, .qualityDefect, .foreignObject, .packagingDefect,
        .allergenWarning, .labelingError, .foodSafety, .generalInfo
    ]
    private let selectableSeverities: [AlertSeverity] = [.low, .medium, .high, .critical]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Product Preview
                    productPreview.padding(.horizontal, 16).padding(.top, 16)

                    // Title
                    formField(label: "Titel *", hint: "Kurze Beschreibung des Problems") {
                        TextField("z.B. Schimmel auf der Verpackung entdeckt", text: $draft.title)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                            .foregroundColor(Color.theme.cardFg)
                            .padding(12)
                            .background(Color.theme.cardBg)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)

                    // Category
                    formField(label: "Kategorie *", hint: nil) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectableCategories, id: \.self) { cat in
                                    CategoryChip(category: cat, isSelected: draft.category == cat) {
                                        draft.category = cat
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.leading, 16)

                    // Severity
                    formField(label: "Schweregrad *", hint: nil) {
                        HStack(spacing: 8) {
                            ForEach(selectableSeverities, id: \.self) { sev in
                                SeverityChip(severity: sev, isSelected: draft.severity == sev) {
                                    draft.severity = sev
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.leading, 16)

                    // Body
                    formField(label: "Beschreibung *", hint: "Beschreibe den Mangel so genau wie möglich. Wann gekauft, wo, was genau ist aufgefallen?") {
                        ZStack(alignment: .topLeading) {
                            if draft.body.isEmpty {
                                Text("z.B. Schimmelflecken auf 3 von 10 Eiern, obwohl MHD noch 5 Tage entfernt. Gekauft am 15.02 bei Netto Basel.")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.mutedFg)
                                    .padding(12)
                            }
                            TextEditor(text: $draft.body)
                                .font(.subheadline)
                                .foregroundColor(Color.theme.cardFg)
                                .frame(minHeight: 120)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color.theme.cardBg)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)

                    // Validation error
                    if showValidationError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.theme.error).font(.caption)
                            Text("Bitte Titel und Beschreibung ausfüllen.").font(.caption).foregroundColor(Color.theme.error)
                        }
                        .padding(.horizontal, 16)
                    }

                    // Disclaimer
                    Text("Deine Meldung wird geprüft und kann danach für andere User sichtbar werden. Dein Nickname wird angezeigt.")
                        .font(.caption2).foregroundColor(Color.theme.mutedFg)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
            }
            .background(Color.theme.baseBg)
            .navigationTitle("Meldung erfassen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(Color.theme.mutedFg)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        guard !draft.title.trimmingCharacters(in: .whitespaces).isEmpty,
                              !draft.body.trimmingCharacters(in: .whitespaces).isEmpty else {
                            showValidationError = true
                            return
                        }
                        onSubmit(draft)
                    } label: {
                        Text("Einreichen")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.theme.accentFg)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private var productPreview: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.theme.cardBg).frame(width: 44, height: 44)
                Image(systemName: "cart.fill").font(.system(size: 20)).foregroundColor(Color.theme.mutedFg.opacity(0.35))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(product.productName ?? product.barcode).font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg).lineLimit(1)
                if let brand = product.brands { Text(brand).font(.caption).foregroundColor(Color.theme.mutedFg) }
                if let batch = product.batchId { Text("Charge: \(batch)").font(.caption2).foregroundColor(Color.theme.mutedFg) }
            }
            Spacer()
        }
        .padding(12).background(Color.theme.cardBg).cornerRadius(12)
    }

    private func formField<Content: View>(label: String, hint: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption.weight(.semibold)).foregroundColor(Color.theme.mutedFg)
            content()
            if let h = hint {
                Text(h).font(.caption2).foregroundColor(Color.theme.mutedFg)
            }
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: AlertCategory; let isSelected: Bool; let onTap: () -> Void

    private var label: String {
        switch category {
        case .mold:            return "Schimmel"
        case .qualityDefect:   return "Qualitätsmangel"
        case .foreignObject:   return "Fremdkörper"
        case .packagingDefect: return "Verpackungsschaden"
        case .allergenWarning: return "Allergen"
        case .labelingError:   return "Etikettierfehler"
        case .foodSafety:      return "Lebensmittelsicherheit"
        case .generalInfo:     return "Allgemeine Info"
        default:               return category.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(label).font(.caption.weight(.semibold))
                .foregroundColor(isSelected ? .white : Color.theme.cardFg)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(isSelected ? Color.theme.accentFg : Color.theme.cardBg)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Severity Chip

private struct SeverityChip: View {
    let severity: AlertSeverity; let isSelected: Bool; let onTap: () -> Void

    private var label: String {
        switch severity {
        case .low: return "Niedrig"; case .medium: return "Mittel"
        case .high: return "Hoch"; case .critical: return "Kritisch"; default: return "Info"
        }
    }
    private var color: Color {
        switch severity {
        case .low: return Color.theme.infso; case .medium: return Color.theme.warning
        case .high: return Color.theme.warning; case .critical: return Color.theme.error; default: return Color.theme.mutedFg
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(label).font(.caption.weight(.semibold))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(isSelected ? color : color.opacity(0.12))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
