//
//  ScanHistoryEntry.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

// TODO: Anpassen wenn wir gemergtes Datenmodell haben

internal import Foundation

// MARK: - ProductStatus

enum ProductStatus: String, Codable, Equatable {
    /// Alles in Ordnung
    case ok              = "ok"
    /// MHD abgelaufen → gelbe Warnung
    case mhdExpired      = "mhd_expired"
    /// MHD läuft in ≤3 Tagen ab → gelbe Vorwarnung
    case mhdSoonExpiring = "mhd_soon_expiring"
    /// Aktiver Rückruf → rote Error-Warnung
    case recallActive    = "recall_active"
    case unknown         = "unknown"

    var uiSeverity: ProductStatusSeverity {
        switch self {
        case .recallActive:                 return .error
        case .mhdExpired, .mhdSoonExpiring: return .warning
        case .ok:                           return .ok
        case .unknown:                      return .neutral
        }
    }

    var displayLabel: String {
        switch self {
        case .recallActive:    return "Recall Active"
        case .mhdExpired:      return "Best Before Expired"
        case .mhdSoonExpiring: return "Expiring Soon"
        case .ok, .unknown:    return ""
        }
    }
}

enum ProductStatusSeverity {
    case error    // rot   – Rückruf
    case warning  // gelb  – MHD-Problem
    case ok       // grün
    case neutral  // grau  – unbekannt
}

// MARK: - ScanHistoryEntry

struct ScanHistoryEntry: Identifiable, Codable, Equatable {

    // MARK: Identität
    let id: UUID

    // MARK: API-Keys – reichen für vollständigen Re-Fetch
    /// EAN-8 / EAN-13 / UPC → OFFFoodService + TomapoService
    let barcode: String
    let barcodeType: String
    /// Chargen-ID → GET /api/v1/trace/{barcode}/batch/{batchId}
    let batchId: String?

    // MARK: Gecachte Anzeige-Daten
    let productName: String?
    let brand: String?
    /// Produktbild-URL für Thumbnail (kein API-Call nötig)
    let imageUrl: String?
    let nutriscoreGrade: String?
    let ecoscoreGrade: String?
    /// Gecacht aus TomapoResponse.environmentSummary.co2TotalKgPerKg
    let co2KgPerKg: Double?

    // MARK: Status & MHD
    var productStatus: ProductStatus
    let bestBeforeDate: Date?

    // MARK: Zeitstempel
    let scannedAt: Date

    // MARK: Init
    init(
        id: UUID = UUID(),
        barcode: String,
        barcodeType: String,
        batchId: String? = nil,
        productName: String?,
        brand: String?,
        imageUrl: String? = nil,
        nutriscoreGrade: String? = nil,
        ecoscoreGrade: String? = nil,
        co2KgPerKg: Double? = nil,
        productStatus: ProductStatus = .unknown,
        bestBeforeDate: Date? = nil,
        scannedAt: Date = Date()
    ) {
        self.id              = id
        self.barcode         = barcode
        self.barcodeType     = barcodeType
        self.batchId         = batchId
        self.productName     = productName
        self.brand           = brand
        self.imageUrl        = imageUrl
        self.nutriscoreGrade = nutriscoreGrade
        self.ecoscoreGrade   = ecoscoreGrade
        self.co2KgPerKg      = co2KgPerKg
        self.productStatus   = productStatus
        self.bestBeforeDate  = bestBeforeDate
        self.scannedAt       = scannedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, barcode, brand
        case barcodeType     = "barcode_type"
        case batchId         = "batch_id"
        case productName     = "product_name"
        case imageUrl        = "image_url"
        case nutriscoreGrade = "nutriscore_grade"
        case ecoscoreGrade   = "ecoscore_grade"
        case co2KgPerKg      = "co2_kg_per_kg"
        case productStatus   = "product_status"
        case bestBeforeDate  = "best_before_date"
        case scannedAt       = "scanned_at"
    }

    // MARK: Computed
    var displayName: String {
        productName?.isEmpty == false ? productName! : barcode
    }
    var displaySubtitle: String? {
        brand?.isEmpty == false ? brand : nil
    }
    /// Meldungserfassung gesperrt wenn MHD abgelaufen
    var canSubmitReport: Bool {
        guard let mhd = bestBeforeDate else { return true }
        return mhd > Date()
    }

    static func computeStatus(bestBeforeDate: Date?, hasActiveRecall: Bool) -> ProductStatus {
        if hasActiveRecall { return .recallActive }
        guard let mhd = bestBeforeDate else { return .ok }
        let now = Date()
        if mhd < now { return .mhdExpired }
        if mhd.timeIntervalSince(now) <= 3 * 24 * 3600 { return .mhdSoonExpiring }
        return .ok
    }
}
