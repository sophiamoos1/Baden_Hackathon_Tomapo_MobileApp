//
//  TomapoTrace.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Enthält alle Metadaten-Typen rund um Rückverfolgbarkeit und Datenquellen.
//
//  Typen:
//  • TomapoTraceabilityScore  – Vollständigkeit und Verifikation der Kette
//  • TomapoDataSource         – Herkunft der Daten (OFF, Hersteller, Labor…)
//  • DataSourceType / DataSourceReliability
//  • TomapoRecallStatus       – Legacy-Rückruf-Struct (via alerts abgelöst)
//  • RecallSeverity
//

internal import Foundation

// MARK: - TomapoTraceabilityScore

struct TomapoTraceabilityScore: Codable {
    /// 0.0–1.0 – Wie vollständig ist die Kette dokumentiert?
    let completeness: Double
    let verifiedStations: Int
    let unknownStations: Int
    let hasGaps: Bool
    let isThirdPartyVerified: Bool
    let blockchainHash: String?

    enum CodingKeys: String, CodingKey {
        case completeness
        case verifiedStations     = "verified_stations"
        case unknownStations      = "unknown_stations"
        case hasGaps              = "has_gaps"
        case isThirdPartyVerified = "is_third_party_verified"
        case blockchainHash       = "blockchain_hash"
    }
}

// MARK: - TomapoDataSource

struct TomapoDataSource: Codable {
    let id: String
    let name: String
    let type: DataSourceType
    let lastSynced: Date?
    let reliability: DataSourceReliability

    enum CodingKeys: String, CodingKey {
        case id, name, type
        case lastSynced  = "last_synced"
        case reliability
    }
}

// MARK: - DataSourceType

enum DataSourceType: String, Codable {
    case openFoodFacts = "open_food_facts"
    case manufacturer  = "manufacturer"
    case logistics     = "logistics"
    case laboratory    = "laboratory"
    case certification = "certification_body"
    case government    = "government"
    case retailer      = "retailer"
    case iot           = "iot_sensor"
    case blockchain    = "blockchain"
}

// MARK: - DataSourceReliability

enum DataSourceReliability: String, Codable {
    case verified  = "verified"
    case official  = "official"
    case community = "community"
    case estimated = "estimated"
    case unknown   = "unknown"
}

// MARK: - TomapoRecallStatus (Legacy)
//
// Ersetzt durch alerts: [TomapoProductAlert] auf TomapoResponse.
// Bleibt für Legacy-UI-Code der noch .recallStatus nutzt.
// Wird via Array<TomapoProductAlert>.legacyRecallStatus computed.

struct TomapoRecallStatus: Codable {
    let isRecalled: Bool
    let severity: RecallSeverity
    let recallId: String?
    let affectedBatches: [String]?
    let reason: String?
    let issuedBy: String?
    let issuedAt: Date?
    let actionRequired: String?
    let moreInfoUrl: String?

    enum CodingKeys: String, CodingKey {
        case isRecalled      = "is_recalled"
        case severity
        case recallId        = "recall_id"
        case affectedBatches = "affected_batches"
        case reason
        case issuedBy        = "issued_by"
        case issuedAt        = "issued_at"
        case actionRequired  = "action_required"
        case moreInfoUrl     = "more_info_url"
    }
}

// MARK: - RecallSeverity

enum RecallSeverity: String, Codable {
    case none     = "none"
    case advisory = "advisory"
    case warning  = "warning"
    case critical = "critical"
    case unknown  = "unknown"
}
