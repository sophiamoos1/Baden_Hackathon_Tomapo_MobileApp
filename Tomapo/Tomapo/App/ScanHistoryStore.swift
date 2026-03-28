//
//  ScanHistoryStore.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import Foundation
internal import SwiftUI
internal import Combine

@MainActor
final class ScanHistoryStore: ObservableObject {
    @Published private(set) var entries: [ScanHistoryEntry] = []

    private let key = "scan_history_v2"
    private let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }()

    init() { load() }

    // MARK: - Add

    func add(
        barcode: String,
        barcodeType: String,
        batchId: String? = nil,
        productName: String?,
        brand: String?,
        imageUrl: String? = nil,
        nutriscoreGrade: String? = nil,
        ecoscoreGrade: String? = nil,
        co2KgPerKg: Double? = nil,
        bestBeforeDate: Date? = nil,
        hasActiveRecall: Bool = false
    ) {
        // Duplikat-Schutz: gleicher Barcode innerhalb 5 Sekunden
        if let last = entries.first, last.barcode == barcode,
           Date().timeIntervalSince(last.scannedAt) < 5 { return }

        let entry = ScanHistoryEntry(
            barcode: barcode,
            barcodeType: barcodeType,
            batchId: batchId,
            productName: productName,
            brand: brand,
            imageUrl: imageUrl,
            nutriscoreGrade: nutriscoreGrade,
            ecoscoreGrade: ecoscoreGrade,
            co2KgPerKg: co2KgPerKg,
            productStatus: ScanHistoryEntry.computeStatus(
                bestBeforeDate: bestBeforeDate,
                hasActiveRecall: hasActiveRecall
            ),
            bestBeforeDate: bestBeforeDate
        )
        entries.insert(entry, at: 0)
        save()
    }

    /// Adds a server entry preserving the original timestamp. Skips if barcode already exists locally.
    func addFromServer(_ serverEntry: ServerScanEntry) {
        let existsLocally = entries.contains { $0.barcode == serverEntry.barcode }
        if existsLocally { return }

        let status: ProductStatus
        switch serverEntry.productStatus {
        case "recall_active", "recalled": status = .recallActive
        case "mhd_expired":               status = .mhdExpired
        case "mhd_soon_expiring":         status = .mhdSoonExpiring
        case "ok":                         status = .ok
        default:                           status = .unknown
        }

        let entry = ScanHistoryEntry(
            barcode: serverEntry.barcode,
            barcodeType: serverEntry.barcodeType ?? "EAN13",
            productName: serverEntry.productName,
            brand: serverEntry.brand,
            nutriscoreGrade: serverEntry.nutriscoreGrade,
            ecoscoreGrade: serverEntry.ecoscoreGrade,
            co2KgPerKg: serverEntry.co2KgPerKg,
            productStatus: status,
            scannedAt: serverEntry.createdAt ?? Date()
        )
        entries.append(entry)
    }

    /// Replaces the entire local history with server data and persists.
    func replaceWithServerEntries(_ serverEntries: [ServerScanEntry]) {
        var newEntries: [ScanHistoryEntry] = []
        for serverEntry in serverEntries {
            let status: ProductStatus
            switch serverEntry.productStatus {
            case "recall_active", "recalled": status = .recallActive
            case "mhd_expired":               status = .mhdExpired
            case "mhd_soon_expiring":         status = .mhdSoonExpiring
            case "ok":                         status = .ok
            default:                           status = .unknown
            }
            newEntries.append(ScanHistoryEntry(
                barcode: serverEntry.barcode,
                barcodeType: serverEntry.barcodeType ?? "EAN13",
                productName: serverEntry.productName,
                brand: serverEntry.brand,
                nutriscoreGrade: serverEntry.nutriscoreGrade,
                ecoscoreGrade: serverEntry.ecoscoreGrade,
                co2KgPerKg: serverEntry.co2KgPerKg,
                productStatus: status,
                scannedAt: serverEntry.createdAt ?? Date()
            ))
        }
        // Sort newest first
        entries = newEntries.sorted { $0.scannedAt > $1.scannedAt }
        save()
    }

    /// Merges server entries into local store, adding missing ones and preserving timestamps.
    func mergeServerEntries(_ serverEntries: [ServerScanEntry]) {
        var didChange = false
        for serverEntry in serverEntries {
            let existsLocally = entries.contains { $0.barcode == serverEntry.barcode }
            if !existsLocally {
                addFromServer(serverEntry)
                didChange = true
            }
        }
        if didChange {
            entries.sort { $0.scannedAt > $1.scannedAt }
            save()
        }
    }

    // MARK: - Update (nach Produktdetail API-Call)

    /// Aktualisiert gecachte Daten eines Eintrags nach einem frischen API-Call.
    func update(
        barcode: String,
        batchId: String? = nil,
        imageUrl: String? = nil,
        nutriscoreGrade: String? = nil,
        ecoscoreGrade: String? = nil,
        co2KgPerKg: Double? = nil,
        bestBeforeDate: Date? = nil,
        hasActiveRecall: Bool = false
    ) {
        guard let idx = entries.firstIndex(where: {
            $0.barcode == barcode && (batchId == nil || $0.batchId == batchId)
        }) else { return }

        let old = entries[idx]
        entries[idx] = ScanHistoryEntry(
            id: old.id,
            barcode: old.barcode,
            barcodeType: old.barcodeType,
            batchId: old.batchId ?? batchId,
            productName: old.productName,
            brand: old.brand,
            imageUrl: imageUrl ?? old.imageUrl,
            nutriscoreGrade: nutriscoreGrade ?? old.nutriscoreGrade,
            ecoscoreGrade: ecoscoreGrade ?? old.ecoscoreGrade,
            co2KgPerKg: co2KgPerKg ?? old.co2KgPerKg,
            productStatus: ScanHistoryEntry.computeStatus(
                bestBeforeDate: bestBeforeDate ?? old.bestBeforeDate,
                hasActiveRecall: hasActiveRecall
            ),
            bestBeforeDate: bestBeforeDate ?? old.bestBeforeDate,
            scannedAt: old.scannedAt
        )
        save()
    }

    /// Schnell-Update: nur Status + MHD
    func updateStatus(barcode: String, batchId: String? = nil,
                      bestBeforeDate: Date?, hasActiveRecall: Bool) {
        guard let idx = entries.firstIndex(where: {
            $0.barcode == barcode && (batchId == nil || $0.batchId == batchId)
        }) else { return }
        entries[idx].productStatus = ScanHistoryEntry.computeStatus(
            bestBeforeDate: bestBeforeDate, hasActiveRecall: hasActiveRecall)
        save()
    }

    // MARK: - Remove

    func remove(_ entry: ScanHistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
    func remove(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }
    func clearAll() { entries.removeAll(); save() }

    // MARK: - CO₂ Aggregation

    var totalCo2KgPerKg: Double {
        entries.compactMap(\.co2KgPerKg).reduce(0, +)
    }
    func co2InRange(from: Date, to: Date = Date()) -> Double {
        entries.filter { $0.scannedAt >= from && $0.scannedAt <= to }
               .compactMap(\.co2KgPerKg).reduce(0, +)
    }
    func scanCount(from: Date, to: Date = Date()) -> Int {
        entries.filter { $0.scannedAt >= from && $0.scannedAt <= to }.count
    }

    // MARK: - Filtered Views

    var recallEntries: [ScanHistoryEntry] {
        entries.filter { $0.productStatus == .recallActive }
    }
    var mhdWarningEntries: [ScanHistoryEntry] {
        entries.filter { $0.productStatus == .mhdExpired || $0.productStatus == .mhdSoonExpiring }
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? encoder.encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? decoder.decode([ScanHistoryEntry].self, from: data)
        else { return }
        entries = decoded
    }
}
