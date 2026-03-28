//
//  TomapoAlerts.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//  Typen:
//  • TomapoProductAlert       – einzelne Meldung/Warnung/Rückruf
//  • AlertSource              – Quelle (ownUser, official, government, user, community, system)
//  • AlertCategory            – Kategorie (productRecall, mold, allergenWarning …)
//  • AlertSeverity            – Schweregrad (info < low < medium < high < critical) Comparable
//  • AlertStatus              – Status (pending, active, verified, rejected, resolved, expired)
//  • Array<TomapoProductAlert> Extension – legacyRecallStatus, Hilfsmethoden
//

internal import Foundation

// MARK: - TomapoProductAlert

struct TomapoProductAlert: Codable, Identifiable, Equatable {

    // MARK: Identität
    let id: String
    let barcode: String
    /// Betroffene Charge – nil = ganzes Produkt
    let batchId: String?

    // MARK: Klassifizierung
    let source: AlertSource
    let category: AlertCategory
    let severity: AlertSeverity

    // MARK: Inhalt
    let title: String
    let description: String
    let actionRequired: String?
    /// Offizielle Referenz (RAPEX-Nr., BLV-Nr., Hersteller-Rückrufnummer)
    let referenceId: String?
    let moreInfoUrl: String?

    // MARK: Autor
    let authorId: String?
    let authorNickname: String?
    /// Avatar-URL des Users (source == .user / .ownUser)
    let authorAvatarUrl: String?
    /// Logo-URL der Firma/Behörde (source == .official / .government)
    let authorLogoUrl: String?

    // MARK: Moderation
    let status: AlertStatus
    let confirmationCount: Int
    let rejectionCount: Int

    // MARK: Zeitstempel
    let createdAt: Date
    let updatedAt: Date
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, barcode, title, description, status, source, category, severity
        case batchId           = "batch_id"
        case actionRequired    = "action_required"
        case referenceId       = "reference_id"
        case moreInfoUrl       = "more_info_url"
        case authorId          = "author_id"
        case authorNickname    = "author_nickname"
        case authorAvatarUrl   = "author_avatar_url"
        case authorLogoUrl     = "author_logo_url"
        case confirmationCount = "confirmation_count"
        case rejectionCount    = "rejection_count"
        case createdAt         = "created_at"
        case updatedAt         = "updated_at"
        case expiresAt         = "expires_at"
    }

    // MARK: Computed

    var isActive: Bool {
        (status == .active || status == .verified) &&
        (expiresAt.map { $0 > Date() } ?? true)
    }
    var isFromUser: Bool      { source == .user || source == .ownUser }
    var isOwnUserReport: Bool { source == .ownUser }
    var isOfficial: Bool      { source == .official || source == .government }
    var isRecall: Bool        { category == .productRecall || category == .batchRecall }

    /// "@nickname" für User · Firmenname für Official/Government
    var displayAuthor: String {
        guard let nick = authorNickname else { return source.rawValue }
        return isFromUser ? "@\(nick)" : nick
    }
}

// MARK: - AlertSource

enum AlertSource: String, Codable, Equatable {
    /// Meldung des aktuell eingeloggten Users – nur lokal in der App
    case ownUser    = "own_user"
    /// Hersteller
    case official   = "official"
    /// BLV, RAPEX, EU-Behörden
    case government = "government"
    /// Fremde verifizierte User-Meldung (vom Backend)
    case user       = "user"
    /// Moderierte Community-Warnung
    case community  = "community"
    /// Automatisch (Datenqualitätsfehler etc.)
    case system     = "system"
}

// MARK: - AlertCategory

enum AlertCategory: String, Codable, Equatable {
    // Rückrufe
    case productRecall       = "product_recall"
    case batchRecall         = "batch_recall"
    // Warnungen
    case foodSafety          = "food_safety"
    case allergenWarning     = "allergen_warning"
    case foreignObject       = "foreign_object"
    case mold                = "mold"
    case qualityDefect       = "quality_defect"
    case packagingDefect     = "packaging_defect"
    case labelingError       = "labeling_error"
    // Informationen
    case recipeChange        = "recipe_change"
    case newCertification    = "new_certification"
    case productDiscontinued = "product_discontinued"
    case generalInfo         = "general_info"
    // System
    case dataQualityIssue    = "data_quality_issue"
}

// MARK: - AlertSeverity

enum AlertSeverity: String, Codable, Equatable, Comparable {
    case info     = "info"
    case low      = "low"
    case medium   = "medium"
    case high     = "high"
    case critical = "critical"

    private var order: Int {
        switch self {
        case .info: return 0; case .low: return 1; case .medium: return 2
        case .high: return 3; case .critical: return 4
        }
    }
    static func < (lhs: AlertSeverity, rhs: AlertSeverity) -> Bool {
        lhs.order < rhs.order
    }
}

// MARK: - AlertStatus

enum AlertStatus: String, Codable, Equatable {
    case pending  = "pending"
    case active   = "active"
    case verified = "verified"
    case rejected = "rejected"
    case resolved = "resolved"
    case expired  = "expired"
}

// MARK: - Array Extension

extension Array where Element == TomapoProductAlert {

    /// Legacy-Kompatibilität für UI-Code der noch TomapoRecallStatus verwendet.
    var legacyRecallStatus: TomapoRecallStatus {
        let top = self.filter { $0.isActive && $0.isRecall }
                      .sorted { $0.severity > $1.severity }.first
        guard let top else {
            return TomapoRecallStatus(isRecalled: false, severity: .none,
                recallId: nil, affectedBatches: nil, reason: nil,
                issuedBy: nil, issuedAt: nil, actionRequired: nil, moreInfoUrl: nil)
        }
        let sev: RecallSeverity
        switch top.severity {
        case .critical: sev = .critical
        case .high:     sev = .warning
        default:        sev = .advisory
        }
        return TomapoRecallStatus(isRecalled: true, severity: sev,
            recallId: top.referenceId,
            affectedBatches: top.batchId.map { [$0] },
            reason: top.description,
            issuedBy: top.authorNickname ?? top.source.rawValue,
            issuedAt: top.createdAt,
            actionRequired: top.actionRequired,
            moreInfoUrl: top.moreInfoUrl)
    }

    var activeNonRecallAlerts: [TomapoProductAlert] {
        self.filter { $0.isActive && !$0.isRecall }.sorted { $0.severity > $1.severity }
    }
    var highestSeverity: AlertSeverity? {
        self.filter { $0.isActive }.map { $0.severity }.max()
    }
}
