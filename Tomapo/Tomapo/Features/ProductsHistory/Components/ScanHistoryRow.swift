//
//  ScanHistoryRow.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
struct ScanHistoryRow: View {
    let entry: ScanHistoryEntry
    var onTap: (() -> Void)? = nil
 
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 14) {
 
                // MARK: Thumbnail / Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.softOliveFog.opacity(0.35))
                        .frame(width: 52, height: 52)
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(Color.theme.mutedSage)
                }
 
                // MARK: Text-Inhalt
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(entry.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.theme.importantText)
                            .lineLimit(1)
                        // Status Badge
                        if entry.productStatus != .ok && entry.productStatus != .unknown {
                            StatusBadge(status: entry.productStatus)
                        }
                    }
 
                    if let subtitle = entry.displaySubtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(Color.theme.bodyText)
                            .lineLimit(1)
                    }
 
                    // Scores + CO₂
                    HStack(spacing: 8) {
                        if let nutri = entry.nutriscoreGrade {
                            ScoreChip(label: "N", grade: nutri)
                        }
                        if let eco = entry.ecoscoreGrade {
                            ScoreChip(label: "E", grade: eco)
                        }
                        if let co2 = entry.co2KgPerKg {
                            HStack(spacing: 3) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.green.opacity(0.7))
                                Text(String(format: "%.2f kg", co2))
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.bodyText.opacity(0.6))
                            }
                        }
                    }
                }
 
                Spacer()
 
                // MARK: Datum + Chevron
                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.scannedAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(Color.theme.bodyText.opacity(0.6))
                    Text(entry.scannedAt, style: .time)
                        .font(.caption2)
                        .foregroundColor(Color.theme.bodyText.opacity(0.4))
                    if onTap != nil {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(Color.theme.bodyText.opacity(0.25))
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.theme.oatMilk.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
 
// MARK: - Status Badge
 
private struct StatusBadge: View {
    let status: ProductStatus
 
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 8, weight: .bold))
            Text(status.displayLabel).font(.system(size: 9, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(bgColor)
        .cornerRadius(20)
    }
 
    private var bgColor: Color {
        switch status.uiSeverity {
        case .error:   return Color.theme.error
        case .warning: return Color.theme.warning
        default:       return Color.theme.bodyText.opacity(0.4)
        }
    }
 
    private var icon: String {
        switch status.uiSeverity {
        case .error:   return "exclamationmark.triangle.fill"
        case .warning: return "clock.fill"
        default:       return "info.circle.fill"
        }
    }
}
 
// MARK: - Score Chip
 
private struct ScoreChip: View {
    let label: String
    let grade: String
 
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(color.opacity(0.8))
            Text(grade.uppercased())
                .font(.system(size: 9, weight: .black))
                .foregroundColor(color)
        }
        .padding(.horizontal, 5).padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
 
    private var color: Color {
        switch grade.lowercased() {
        case "a":              return .green
        case "b":              return Color(red: 0.53, green: 0.77, blue: 0.15)
        case "c":              return .orange
        case "d":              return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "e":              return .red
        case "not-applicable": return Color.theme.bodyText.opacity(0.4)
        default:               return Color.theme.bodyText.opacity(0.4)
        }
    }
}
 
// MARK: - Preview
 
#Preview {
    VStack(spacing: 10) {
        ScanHistoryRow(entry: ScanHistoryEntry(
            barcode: "4316268651288", barcodeType: "EAN13",
            productName: "BioBio Bio-Eier Freilandhaltung",
            brand: "BioBio",
            imageUrl: nil, nutriscoreGrade: "a", ecoscoreGrade: "b",
            co2KgPerKg: 3.167, productStatus: .ok, bestBeforeDate: nil
        ), onTap: {})
        ScanHistoryRow(entry: ScanHistoryEntry(
            barcode: "5000159461122", barcodeType: "EAN13",
            productName: "Snickers", brand: "Mars",
            imageUrl: nil, nutriscoreGrade: "e", ecoscoreGrade: "d",
            co2KgPerKg: 5.2, productStatus: .recallActive, bestBeforeDate: nil
        ), onTap: {})
        ScanHistoryRow(entry: ScanHistoryEntry(
            barcode: "3274080005003", barcodeType: "EAN13",
            productName: "Cristaline Quellwasser", brand: "Cristaline",
            imageUrl: nil, nutriscoreGrade: nil, ecoscoreGrade: "not-applicable",
            co2KgPerKg: 0.232, productStatus: .mhdSoonExpiring,
            bestBeforeDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
        ), onTap: {})
    }
    .padding()
    .background(Color.theme.oatMilk)
}
