//
//  TomapoUser.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Typen:
//  • TomapoUser                 – User-Profil (fullName, nickname, email, avatar)
//  • TomapoUserMessageSummary   – Lightweight-Referenz auf eine Meldung
//  • TomapoUserStore            – @MainActor ObservableObject, UserDefaults-Persistence
//

internal import Foundation
internal import Combine

// MARK: - TomapoUser

struct TomapoUser: Codable, Equatable {

    let id: String
    var fullName: String
    var email: String
    var nickname: String
    var avatarUrl: String?
    var passwordHash: String?

    /// Lightweight-Summaries aller Meldungen – für Badge + Listenansicht.
    /// Vollständige Meldungen → TomapoUserMessageStore
    var messages: [TomapoUserMessageSummary]

    let createdAt: Date
    var updatedAt: Date
    var isSyncedWithBackend: Bool

    enum CodingKeys: String, CodingKey {
        case id, messages, email, nickname
        case fullName            = "full_name"
        case avatarUrl           = "avatar_url"
        case passwordHash        = "password_hash"
        case createdAt           = "created_at"
        case updatedAt           = "updated_at"
        case isSyncedWithBackend = "is_synced_with_backend"
    }

    init(id: String = UUID().uuidString,
         fullName: String, email: String, nickname: String,
         avatarUrl: String? = nil, passwordHash: String? = nil,
         messages: [TomapoUserMessageSummary] = [],
         createdAt: Date = Date(), updatedAt: Date = Date(),
         isSyncedWithBackend: Bool = false) {
        self.id = id; self.fullName = fullName; self.email = email
        self.nickname = nickname; self.avatarUrl = avatarUrl
        self.passwordHash = passwordHash
        self.messages = messages; self.createdAt = createdAt
        self.updatedAt = updatedAt; self.isSyncedWithBackend = isSyncedWithBackend
    }

    // MARK: Computed

    var firstName: String {
        fullName.components(separatedBy: " ").first ?? fullName
    }
    var initials: String {
        let parts = fullName.components(separatedBy: " ").filter { !$0.isEmpty }
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(f)\(l)".uppercased()
    }
    var messageCount: Int        { messages.count }
    var pendingMessageCount: Int {
        messages.filter {
            $0.submissionStatus == .draft || $0.submissionStatus == .submitted
        }.count
    }
    func messages(for barcode: String) -> [TomapoUserMessageSummary] {
        messages.filter { $0.barcode == barcode }
    }
    func messages(forBatch batchId: String) -> [TomapoUserMessageSummary] {
        messages.filter { $0.batchId == batchId }
    }
}

// MARK: - TomapoUserMessageSummary

/// Lightweight-Referenz – direkt in TomapoUser.messages gespeichert.
/// Für Listenansicht und Badge-Zählung ohne vollständiges Meldungsobjekt.
struct TomapoUserMessageSummary: Codable, Identifiable, Equatable {

    let id: String              // = TomapoUserMessage.id
    let barcode: String
    let batchId: String?
    let productName: String?
    let productBrand: String?
    let productCategoryTag: String?
    let messageTitle: String
    let messageCategory: AlertCategory
    let messageSeverity: AlertSeverity
    var submissionStatus: MessageSubmissionStatus
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, barcode
        case batchId            = "batch_id"
        case productName        = "product_name"
        case productBrand       = "product_brand"
        case productCategoryTag = "product_category_tag"
        case messageTitle       = "message_title"
        case messageCategory    = "message_category"
        case messageSeverity    = "message_severity"
        case submissionStatus   = "submission_status"
        case createdAt          = "created_at"
        case updatedAt          = "updated_at"
    }

    var displayProductName: String  { productName ?? barcode }
    var canRefreshProductData: Bool { !barcode.isEmpty }
}

// MARK: - TomapoUserStore

@MainActor
final class TomapoUserStore: ObservableObject {

    @Published private(set) var currentUser: TomapoUser?

    private let key = "tomapo_user"
    private let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }()

    init() { load() }

    var hasUser: Bool { currentUser != nil }

    // MARK: User CRUD

    func createUser(fullName: String, email: String, nickname: String,
                    passwordHash: String? = nil) {
        currentUser = TomapoUser(fullName: fullName, email: email, nickname: nickname,
                                  passwordHash: passwordHash)
        save()
    }

    func updateUser(fullName: String? = nil, email: String? = nil,
                    nickname: String? = nil, avatarUrl: String? = nil,
                    passwordHash: String? = nil) {
        guard var u = currentUser else { return }
        if let v = fullName     { u.fullName     = v }
        if let v = email        { u.email        = v }
        if let v = nickname     { u.nickname     = v }
        if let v = avatarUrl    { u.avatarUrl    = v }
        if let v = passwordHash { u.passwordHash = v }
        u.updatedAt = Date()
        currentUser = u; save()
    }

    func deleteUser() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: Message Summary Management

    func addMessageSummary(messageId: String, barcode: String, batchId: String?,
                           productName: String?, productBrand: String?,
                           productCategoryTag: String?, title: String,
                           category: AlertCategory, severity: AlertSeverity) {
        guard var u = currentUser else { return }
        let s = TomapoUserMessageSummary(
            id: messageId, barcode: barcode, batchId: batchId,
            productName: productName, productBrand: productBrand,
            productCategoryTag: productCategoryTag, messageTitle: title,
            messageCategory: category, messageSeverity: severity,
            submissionStatus: .draft, createdAt: Date(), updatedAt: Date())
        u.messages.insert(s, at: 0)
        u.updatedAt = Date()
        currentUser = u; save()
    }

    func updateMessageStatus(messageId: String, status: MessageSubmissionStatus) {
        guard var u = currentUser,
              let i = u.messages.firstIndex(where: { $0.id == messageId })
        else { return }
        u.messages[i].submissionStatus = status
        u.messages[i].updatedAt = Date()
        u.updatedAt = Date()
        currentUser = u; save()
    }

    func removeMessageSummary(messageId: String) {
        guard var u = currentUser else { return }
        u.messages.removeAll { $0.id == messageId }
        u.updatedAt = Date()
        currentUser = u; save()
    }

    // MARK: Persistence

    private func save() {
        guard let u = currentUser,
              let d = try? encoder.encode(u) else { return }
        UserDefaults.standard.set(d, forKey: key)
    }

    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let u = try? decoder.decode(TomapoUser.self, from: d)
        else { return }
        currentUser = u
    }
}

// MARK: - Mock

extension TomapoUser {
    static let mock = TomapoUser(
        id: "mock-user-001",
        fullName: "Sophia Moos",
        email: "sophia@wheresmytomato.app",
        nickname: "sophia_m",
        messages: TomapoUserMessageSummary.mockSummaries
    )
}

extension TomapoUserMessageSummary {
    static let mockSummaries: [TomapoUserMessageSummary] = {
        let cal = Calendar.current
        func ago(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: -n, to: Date()) ?? Date()
        }
        return [
            TomapoUserMessageSummary(
                id: "mock-msg-001", barcode: "4316268651288",
                batchId: "DE-031107-26046",
                productName: "BioBio Bio-Eier", productBrand: "BioBio",
                productCategoryTag: "en:eggs",
                messageTitle: "Schimmel an Eierschale",
                messageCategory: .mold, messageSeverity: .high,
                submissionStatus: .published,
                createdAt: ago(3), updatedAt: ago(3))
        ]
    }()
}
