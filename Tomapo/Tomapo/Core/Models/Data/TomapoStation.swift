//
//  TomapoStation.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Typen:
//  • TomapoStation        – Einzelne Station in der Produktionskette
//  • TomapoStationType    – 35 Stationstypen (farming … veterinaryCheck)
//  • TomapoStationStatus  – pending / active / completed / warning / failed / skipped
//  • TomapoStationDetail  – Enum mit 12 typisierten Detail-Cases
//  • TomapoLocation       – Standort einer Station (Koordinaten, GLN, EMB)
//  • GenericStationDetail – Fallback für unbekannte Stationstypen
//
//  Detail-Structs (FarmingDetail … RetailDetail) sind ausgelagert:
//  → TomapoStationDetailsPrimary.swift    (Farming, Fishing, Harvest, Processing)
//  → TomapoStationDetailsProcessing.swift (Packaging, Storage, Transport, Distribution,
//                                          Retail, Laboratory, GenericStationDetail)
//

internal import Foundation

// MARK: - TomapoStation

struct TomapoStation: Codable, Identifiable {
    let id: String
    let type: TomapoStationType
    let status: TomapoStationStatus
    let title: String
    let subtitle: String?
    let location: TomapoLocation?
    let startedAt: Date?
    let completedAt: Date?
    let durationHours: Double?
    let qualityChecks: [TomapoQualityCheck]
    let certificationIds: [String]
    /// CO₂ dieser Station in kg CO₂eq/kg – Shortcut für schnellen Zugriff
    let co2KgPerKg: Double?
    /// Vollständige Umweltkennzahlen dieser Station (optional)
    let environmentSummary: TomapoEnvironmentSummary?
    let detail: TomapoStationDetail
    let isVerified: Bool
    let verifiedBy: String?
    let notes: String?
    /// War das Produkt an dieser Station gekühlt?
    let wasRefrigerated: Bool
    /// Ø/Zieltemperatur – nil wenn unbekannt oder wasRefrigerated = false
    let refrigerationTemperatureCelsius: Double?

    enum CodingKeys: String, CodingKey {
        case id, type, status, title, subtitle, location, detail, notes
        case startedAt                       = "started_at"
        case completedAt                     = "completed_at"
        case durationHours                   = "duration_hours"
        case qualityChecks                   = "quality_checks"
        case certificationIds                = "certification_ids"
        case co2KgPerKg                      = "co2_kg_per_kg"
        case environmentSummary              = "environment_summary"
        case isVerified                      = "is_verified"
        case verifiedBy                      = "verified_by"
        case wasRefrigerated                 = "was_refrigerated"
        case refrigerationTemperatureCelsius = "refrigeration_temperature_celsius"
    }

    /// "2°C" / "Gekühlt" / "–" für Kühlketten-Zeitstrahl
    var refrigerationLabel: String {
        guard wasRefrigerated else { return "–" }
        if let t = refrigerationTemperatureCelsius { return String(format: "%.0f°C", t) }
        return "Gekühlt"
    }
}

// MARK: - TomapoStationType

enum TomapoStationType: String, Codable, CaseIterable {
    // Primärproduktion
    case farming           = "farming"
    case fishing           = "fishing"
    case harvest           = "harvest"
    case sorting           = "sorting"
    // Verarbeitung
    case processing        = "processing"
    case cleaning          = "cleaning"
    case cutting           = "cutting"
    case cooking           = "cooking"
    case fermenting        = "fermenting"
    case drying            = "drying"
    case freezing          = "freezing"
    // Verpackung
    case packaging         = "packaging"
    case labeling          = "labeling"
    case sealing           = "sealing"
    // Lagerung
    case storage           = "storage"
    case coldStorage       = "cold_storage"
    case frozenStorage     = "frozen_storage"
    case ripening          = "ripening"
    case aging             = "aging"
    // Transport
    case truckTransport    = "truck_transport"
    case railTransport     = "rail_transport"
    case shipTransport     = "ship_transport"
    case airTransport      = "air_transport"
    case refrigeratedTruck = "refrigerated_truck"
    case localDelivery     = "local_delivery"
    // Distribution
    case distribution      = "distribution"
    case customsClearance  = "customs_clearance"
    case importInspection  = "import_inspection"
    // Retail
    case retailStorage     = "retail_storage"
    case retailDisplay     = "retail_display"
    case pointOfSale       = "point_of_sale"
    // Qualität
    case qualityInspection  = "quality_inspection"
    case laboratoryTest     = "laboratory_test"
    case certificationCheck = "certification_check"
    case veterinaryCheck    = "veterinary_check"
    case unknown            = "unknown"

    /// Per Definition immer gekühlt – unabhängig von wasRefrigerated
    var isInherentlyCold: Bool {
        switch self {
        case .coldStorage, .frozenStorage, .refrigeratedTruck: return true
        default: return false
        }
    }
}

// MARK: - TomapoStationStatus

enum TomapoStationStatus: String, Codable {
    case pending   = "pending"
    case active    = "active"
    case completed = "completed"
    case warning   = "warning"
    case failed    = "failed"
    case skipped   = "skipped"
    case unknown   = "unknown"
}

// MARK: - TomapoStationDetail

enum TomapoStationDetail: Codable {
    case farming(FarmingDetail)
    case fishing(FishingDetail)
    case harvest(HarvestDetail)
    case processing(ProcessingDetail)
    case packaging(PackagingDetail)
    case storage(StorageDetail)
    case coldStorage(ColdStorageDetail)
    case transport(TransportDetail)
    case laboratory(LaboratoryDetail)
    case distribution(DistributionDetail)
    case retail(RetailDetail)
    case generic(GenericStationDetail)

    enum CodingKeys: String, CodingKey { case type, data }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "farming":      self = .farming(try c.decode(FarmingDetail.self,      forKey: .data))
        case "fishing":      self = .fishing(try c.decode(FishingDetail.self,      forKey: .data))
        case "harvest":      self = .harvest(try c.decode(HarvestDetail.self,      forKey: .data))
        case "processing":   self = .processing(try c.decode(ProcessingDetail.self, forKey: .data))
        case "packaging":    self = .packaging(try c.decode(PackagingDetail.self,  forKey: .data))
        case "storage":      self = .storage(try c.decode(StorageDetail.self,      forKey: .data))
        case "cold_storage": self = .coldStorage(try c.decode(ColdStorageDetail.self, forKey: .data))
        case "transport":    self = .transport(try c.decode(TransportDetail.self,  forKey: .data))
        case "laboratory":   self = .laboratory(try c.decode(LaboratoryDetail.self, forKey: .data))
        case "distribution": self = .distribution(try c.decode(DistributionDetail.self, forKey: .data))
        case "retail":       self = .retail(try c.decode(RetailDetail.self,        forKey: .data))
        default:             self = .generic(try c.decode(GenericStationDetail.self, forKey: .data))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .farming(let d):      try c.encode("farming",      forKey: .type); try c.encode(d, forKey: .data)
        case .fishing(let d):      try c.encode("fishing",      forKey: .type); try c.encode(d, forKey: .data)
        case .harvest(let d):      try c.encode("harvest",      forKey: .type); try c.encode(d, forKey: .data)
        case .processing(let d):   try c.encode("processing",   forKey: .type); try c.encode(d, forKey: .data)
        case .packaging(let d):    try c.encode("packaging",    forKey: .type); try c.encode(d, forKey: .data)
        case .storage(let d):      try c.encode("storage",      forKey: .type); try c.encode(d, forKey: .data)
        case .coldStorage(let d):  try c.encode("cold_storage", forKey: .type); try c.encode(d, forKey: .data)
        case .transport(let d):    try c.encode("transport",    forKey: .type); try c.encode(d, forKey: .data)
        case .laboratory(let d):   try c.encode("laboratory",   forKey: .type); try c.encode(d, forKey: .data)
        case .distribution(let d): try c.encode("distribution", forKey: .type); try c.encode(d, forKey: .data)
        case .retail(let d):       try c.encode("retail",       forKey: .type); try c.encode(d, forKey: .data)
        case .generic(let d):      try c.encode("generic",      forKey: .type); try c.encode(d, forKey: .data)
        }
    }
}

// MARK: - TomapoLocation

struct TomapoLocation: Codable {
    let name: String?
    let country: String?      // ISO 3166-1 alpha-2
    let region: String?
    let city: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let embCode: String?      // EU Betriebszulassungsnummer
    let gln: String?          // GS1 Global Location Number

    enum CodingKeys: String, CodingKey {
        case name, country, region, city, address, latitude, longitude
        case embCode = "emb_code"
        case gln
    }
}

// MARK: - GenericStationDetail

struct GenericStationDetail: Codable {
    let description: String?
    let operatorName: String?

    enum CodingKeys: String, CodingKey {
        case description
        case operatorName = "operator_name"
    }
}
