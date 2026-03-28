//
//  TomapoUserMessage.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Typen:
//  • MessageSubmissionStatus      – draft / submitted / published / rejected
//  • TomapoMessageProductSnapshot – Produkt-Datensatz eingebettet in Meldung
//  • TomapoUserMessage            – Vollständiges Meldungsobjekt (lokal gespeichert)
//  • TomapoUserMessageStore       – @MainActor ObservableObject, UserDefaults-Persistence
//

internal import Foundation
internal import Combine

// MARK: - MessageSubmissionStatus

enum MessageSubmissionStatus: String, Codable, Equatable {
    case draft     = "draft"       // Nur lokal, noch nicht gesendet
    case submitted = "submitted"   // Gesendet, wartet auf Moderation
    case published = "published"   // Öffentlich sichtbar
    case rejected  = "rejected"    // Abgelehnt
}

// MARK: - TomapoMessageProductSnapshot

/// Minimaler Produkt-Datensatz eingebettet in jede Meldung.
/// Reicht für Listenansicht (offline) und erneuten vollständigen API-Call.
struct TomapoMessageProductSnapshot: Codable, Equatable {

    let barcode: String       // → GET /api/v1/trace/{barcode}
    let batchId: String?
    let productName: String?
    let brand: String?
    let quantity: String?
    let imageUrl: String?
    let nutriscoreGrade: String?
    let ecoscoreGrade: String?
    let categoriesTags: [String]?
    let scannedAt: Date
    let scannedAtStoreName: String?

    enum CodingKeys: String, CodingKey {
        case barcode, brand, quantity
        case batchId            = "batch_id"
        case productName        = "product_name"
        case imageUrl           = "image_url"
        case nutriscoreGrade    = "nutriscore_grade"
        case ecoscoreGrade      = "ecoscore_grade"
        case categoriesTags     = "categories_tags"
        case scannedAt          = "scanned_at"
        case scannedAtStoreName = "scanned_at_store_name"
    }

    var displayName: String {
        productName?.isEmpty == false ? productName! : barcode
    }
    var displaySubtitle: String? {
        let parts = [brand, quantity].compactMap { $0?.isEmpty == false ? $0 : nil }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
    var canReloadTrace: Bool  { true }
    var hasBatchContext: Bool { batchId != nil }
}

// MARK: - TomapoUserMessage

struct TomapoUserMessage: Codable, Identifiable, Equatable {

    let id: String
    let authorId: String        // → TomapoUser.id
    let authorNickname: String
    let productSnapshot: TomapoMessageProductSnapshot
    let category: AlertCategory
    let title: String
    let body: String
    let severity: AlertSeverity
    var submissionStatus: MessageSubmissionStatus
    /// Falls moderiert und veröffentlicht → ID des resultierenden TomapoProductAlert
    var linkedAlertId: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, body, severity, category
        case authorId         = "author_id"
        case authorNickname   = "author_nickname"
        case productSnapshot  = "product_snapshot"
        case submissionStatus = "submission_status"
        case linkedAlertId    = "linked_alert_id"
        case createdAt        = "created_at"
        case updatedAt        = "updated_at"
    }

    // Passthrough auf productSnapshot
    var barcode: String          { productSnapshot.barcode }
    var batchId: String?         { productSnapshot.batchId }
    var displayProductName: String { productSnapshot.displayName }
    var displayAuthor: String    { "@\(authorNickname)" }
    var displayBodyPreview: String {
        body.count > 80 ? String(body.prefix(80)) + "…" : body
    }
    var isSubmittedToBackend: Bool {
        submissionStatus == .submitted || submissionStatus == .published
    }
}

// MARK: - TomapoUserMessageStore

@MainActor
final class TomapoUserMessageStore: ObservableObject {

    @Published private(set) var messages: [TomapoUserMessage] = []

    private let key = "tomapo_user_messages"
    private let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }()

    init() { load() }

    // MARK: Add

    @discardableResult
    func add(authorId: String, authorNickname: String,
             productSnapshot: TomapoMessageProductSnapshot,
             category: AlertCategory, title: String,
             body: String, severity: AlertSeverity) -> TomapoUserMessage {
        let msg = TomapoUserMessage(
            id: UUID().uuidString,
            authorId: authorId, authorNickname: authorNickname,
            productSnapshot: productSnapshot,
            category: category, title: title, body: body, severity: severity,
            submissionStatus: .draft, linkedAlertId: nil,
            createdAt: Date(), updatedAt: Date())
        messages.insert(msg, at: 0)
        save()
        return msg
    }

    func remove(_ message: TomapoUserMessage) {
        messages.removeAll { $0.id == message.id }
        save()
    }

    func updateStatus(id: String, status: MessageSubmissionStatus,
                      linkedAlertId: String? = nil) {
        guard let i = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[i].submissionStatus = status
        if let aid = linkedAlertId { messages[i].linkedAlertId = aid }
        messages[i].updatedAt = Date()
        save()
    }

    // MARK: Queries

    func messages(for barcode: String) -> [TomapoUserMessage] {
        messages.filter { $0.barcode == barcode }
    }
    func messages(forBatch batchId: String) -> [TomapoUserMessage] {
        messages.filter { $0.batchId == batchId }
    }
    func messageCount(for barcode: String) -> Int {
        messages(for: barcode).count
    }

    // MARK: Mock Data Fallback

    /// Seeds the store with mock user messages when backend is unreachable.
    /// Only populates if the store is currently empty.
    func seedWithMockData() {
        guard messages.isEmpty else { return }
        messages = MockUserMessages.all
        save()
    }

    // MARK: Persistence

    private func save() {
        guard let d = try? encoder.encode(messages) else { return }
        UserDefaults.standard.set(d, forKey: key)
    }

    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? decoder.decode([TomapoUserMessage].self, from: d)
        else { return }
        messages = decoded
    }
}
