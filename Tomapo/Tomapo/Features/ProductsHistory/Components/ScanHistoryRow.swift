//
//  ScanHistoryRow.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
 
struct ScanHistoryRow: View {
    let entry: ScanHistoryEntry
 
    var body: some View {
        HStack(spacing: 14) {
 
            // MARK: Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.theme.softOliveFog.opacity(0.35))
                    .frame(width: 46, height: 46)
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(Color.theme.mutedSage)
            }
 
            // MARK: Text-Inhalt
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.importantText)
                    .lineLimit(1)
 
                if let subtitle = entry.displaySubtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Color.theme.bodyText)
                        .lineLimit(1)
                }
 
                Text(entry.barcode)
                    .font(.caption2)
                    .foregroundColor(Color.theme.bodyText.opacity(0.5))
                    .lineLimit(1)
            }
 
            Spacer()
 
            // MARK: Zeitstempel
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.scannedAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(Color.theme.bodyText.opacity(0.6))
                Text(entry.scannedAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(Color.theme.bodyText.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.theme.bottomBarBackground.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
 
// MARK: - Preview
 
#Preview {
    VStack(spacing: 10) {
        ScanHistoryRow(entry: ScanHistoryEntry(
            barcode: "4316268651288",
            barcodeType: "EAN13",
            productName: "BioBio Bio-Eier Freilandhaltung",
            brand: "BioBio"
        ))
        ScanHistoryRow(entry: ScanHistoryEntry(
            barcode: "3274080005003",
            barcodeType: "EAN13",
            productName: nil,
            brand: nil
        ))
    }
    .padding()
    .background(Color.theme.oatMilk)
}
