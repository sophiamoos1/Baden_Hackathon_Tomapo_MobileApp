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
                    formField(label: "Title *", hint: "Short description of the issue") {
                        TextField("e.g. Mold found on packaging", text: $draft.title)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                            .foregroundColor(Color.theme.cardFg)
                            .padding(12)
                            .background(Color.theme.cardBg)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)

                    // Category
                    formField(label: "Category *", hint: nil) {
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
                    formField(label: "Severity *", hint: nil) {
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
                    formField(label: "Description *", hint: "Describe the issue in as much detail as possible. When purchased, where, and what exactly was noticed?") {
                        ZStack(alignment: .topLeading) {
                            if draft.body.isEmpty {
                                Text("e.g. Mold spots on 3 out of 10 eggs, even though best-before date is still 5 days away. Purchased on Feb 15 at Netto Basel.")
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
                            Text("Please fill in title and description.").font(.caption).foregroundColor(Color.theme.error)
                        }
                        .padding(.horizontal, 16)
                    }

                    // Disclaimer
                    Text("Your report will be reviewed and may become visible to other users. Your nickname will be displayed.")
                        .font(.caption2).foregroundColor(Color.theme.mutedFg)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
            }
            .background(Color.theme.baseBg)
            .navigationTitle("Submit Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
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
                        Text("Submit")
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
                if let batch = product.batchId { Text("Batch: \(batch)").font(.caption2).foregroundColor(Color.theme.mutedFg) }
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
        case .mold:            return "Mold"
        case .qualityDefect:   return "Quality Defect"
        case .foreignObject:   return "Foreign Object"
        case .packagingDefect: return "Packaging Defect"
        case .allergenWarning: return "Allergen"
        case .labelingError:   return "Labeling Error"
        case .foodSafety:      return "Food Safety"
        case .generalInfo:     return "General Info"
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
        case .low: return "Low"; case .medium: return "Medium"
        case .high: return "High"; case .critical: return "Critical"; default: return "Info"
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
