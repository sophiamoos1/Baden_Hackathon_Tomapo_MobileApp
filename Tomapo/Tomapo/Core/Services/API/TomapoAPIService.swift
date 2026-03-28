//
//  TomapoAPIService.swift
//  Tomapo
//
//  Main API service with all backend endpoints.
//  Token management with auto-refresh on 401.
//

internal import Foundation
internal import SwiftUI

@MainActor
final class TomapoAPIService {

    static let shared = TomapoAPIService()

    @AppStorage(TomapoAPIConfig.tokenAccessKey)  private var accessToken: String = TomapoAPIConfig.defaultAccessToken
    @AppStorage(TomapoAPIConfig.tokenRefreshKey) private var refreshToken: String = TomapoAPIConfig.defaultRefreshToken
    @AppStorage(TomapoAPIConfig.tokenUserIdKey)  private var userId: String = TomapoAPIConfig.defaultUserId

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private init() {}

    // MARK: - Generic Request Helper

    private func request<T: Decodable>(
        _ path: String,
        baseURL: String = TomapoAPIConfig.baseURL,
        method: String = "GET",
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard var components = URLComponents(string: "\(baseURL)/\(path)") else {
            throw TomapoAPIError.invalidResponse
        }
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw TomapoAPIError.invalidResponse
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 30

        if requiresAuth {
            guard !accessToken.isEmpty else { throw TomapoAPIError.noToken }
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw TomapoAPIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw TomapoAPIError.invalidResponse
        }

        // Auto-refresh on 401
        if http.statusCode == 401 && requiresAuth {
            do {
                try await refreshAccessToken()
                return try await request(path, baseURL: baseURL, method: method,
                                         body: body, queryItems: queryItems, requiresAuth: true)
            } catch {
                throw TomapoAPIError.unauthorized
            }
        }

        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 404 { throw TomapoAPIError.notFound }
            throw TomapoAPIError.serverError(http.statusCode)
        }

        // Handle empty response for Void-like calls
        if data.isEmpty, let empty = EmptyResponse() as? T {
            return empty
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw TomapoAPIError.decodingError(error)
        }
    }

    /// Fire-and-forget variant that discards the response body
    private func requestVoid(
        _ path: String,
        baseURL: String = TomapoAPIConfig.baseURL,
        method: String = "POST",
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let _: EmptyResponse = try await request(path, baseURL: baseURL, method: method,
                                                  body: body, requiresAuth: requiresAuth)
    }

    // MARK: - Auth

    func register(fullName: String, email: String, nickname: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(fullName: fullName, email: email, nickname: nickname, password: password)
        let auth: AuthResponse = try await request("auth/user/register", method: "POST", body: body, requiresAuth: false)
        saveTokens(auth)
        return auth
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let auth: AuthResponse = try await request("auth/user/login", method: "POST", body: body, requiresAuth: false)
        saveTokens(auth)
        return auth
    }

    func logout() async throws {
        try await requestVoid("auth/logout", method: "POST")
        clearTokens()
    }

    private func refreshAccessToken() async throws {
        guard !refreshToken.isEmpty else { throw TomapoAPIError.noToken }
        let body = RefreshRequest(refreshToken: refreshToken)
        let auth: AuthResponse = try await request("auth/refresh", method: "POST", body: body, requiresAuth: false)
        saveTokens(auth)
    }

    private func saveTokens(_ auth: AuthResponse) {
        accessToken  = auth.accessToken
        refreshToken = auth.refreshToken
        userId       = auth.userId
    }

    private func clearTokens() {
        // Reset to defaults so the user stays pre-authenticated
        accessToken  = TomapoAPIConfig.defaultAccessToken
        refreshToken = TomapoAPIConfig.defaultRefreshToken
        userId       = TomapoAPIConfig.defaultUserId
    }

    // MARK: - Trace

    func getTrace(barcode: String) async throws -> TomapoResponse {
        try await request("traces/\(barcode)")
    }

    func getTrace(barcode: String, batchId: String) async throws -> TomapoResponse {
        try await request("traces/\(barcode)/batch/\(batchId)")
    }

    func getTraceHistory(barcode: String) async throws -> [TomapoResponse] {
        try await request("traces/\(barcode)/history")
    }

    func updateTrace(traceId: String, fields: [String: String]) async throws -> TomapoResponse {
        try await request("traces/\(traceId)", method: "PATCH", body: fields)
    }

    // MARK: - Alerts

    func getAlerts(barcode: String) async throws -> [TomapoProductAlert] {
        try await request("alerts/\(barcode)")
    }

    func getAlerts(barcode: String, batchId: String) async throws -> [TomapoProductAlert] {
        try await request("alerts/\(barcode)/batch/\(batchId)")
    }

    func getAlert(alertId: String) async throws -> TomapoProductAlert {
        try await request("alerts/alerts/id/\(alertId)")
    }

    func createAlert(_ alert: CreateAlertRequest) async throws -> TomapoProductAlert {
        try await request("alerts", method: "POST", body: alert)
    }

    func updateAlert(alertId: String, fields: [String: String]) async throws -> TomapoProductAlert {
        try await request("alerts/\(alertId)", method: "PATCH", body: fields)
    }

    func confirmAlert(alertId: String) async throws {
        let _: EmptyResponse = try await request("alerts/\(alertId)/confirm", method: "POST",
                                                  body: EmptyBody())
    }

    func deleteAlert(alertId: String) async throws {
        let _: EmptyResponse = try await request("alerts/\(alertId)", method: "DELETE")
    }

    // MARK: - Scan History (Server)

    func getMyScanHistory() async throws -> [ServerScanEntry] {
        try await request("scan-history")
    }

    func createScanEntry(_ entry: CreateScanEntryRequest) async throws -> ServerScanEntry {
        try await request("scan-history", method: "POST", body: entry)
    }

    func getScanEntry(id: String) async throws -> ServerScanEntry {
        try await request("scan-history/\(id)")
    }

    func updateScanEntry(id: String, fields: [String: String]) async throws -> ServerScanEntry {
        try await request("scan-history/\(id)", method: "PATCH", body: fields)
    }

    func deleteScanEntry(id: String) async throws {
        let _: EmptyResponse = try await request("scan-history/\(id)", method: "DELETE")
    }

    func clearMyScanHistory() async throws {
        let _: EmptyResponse = try await request("scan-history", method: "DELETE")
    }

    // MARK: - Product Cache

    func getProduct(barcode: String) async throws -> TomapoResponse {
        try await request("products/\(barcode)")
    }

    // MARK: - User

    func getMyProfile() async throws -> UserProfileResponse {
        try await request("users/me")
    }

    func updateMyProfile(fullName: String?, nickname: String?) async throws -> UserProfileResponse {
        let body = UpdateProfileRequest(fullName: fullName, nickname: nickname)
        return try await request("users/me", method: "PATCH", body: body)
    }

    func updateAvatar(avatarUrl: String) async throws -> UserProfileResponse {
        let body = UpdateAvatarRequest(avatarUrl: avatarUrl)
        return try await request("users/me/avatar", method: "PATCH", body: body)
    }

    func getMyMessageSummary() async throws -> [ServerUserMessage] {
        try await request("users/me/messages")
    }

    func getUser(userId: String) async throws -> UserProfileResponse {
        try await request("users/\(userId)")
    }

    func deleteMyAccount() async throws {
        let _: EmptyResponse = try await request("users/me", method: "DELETE")
        clearTokens()
    }

    // MARK: - User Messages

    func getMyMessages() async throws -> [ServerUserMessage] {
        try await request("user-messages")
    }

    func getMessage(messageId: String) async throws -> ServerUserMessage {
        try await request("user-messages/\(messageId)")
    }

    func createMessage(_ message: CreateMessageRequest) async throws -> ServerUserMessage {
        try await request("user-messages", method: "POST", body: message)
    }

    func updateMessageStatus(messageId: String, status: String) async throws -> ServerUserMessage {
        let body = UpdateMessageStatusRequest(submissionStatus: status)
        return try await request("user-messages/\(messageId)/status", method: "PATCH", body: body)
    }

    func getMessages(barcode: String) async throws -> [ServerUserMessage] {
        try await request("user-messages/barcode/\(barcode)")
    }

    func deleteMessage(messageId: String) async throws {
        let _: EmptyResponse = try await request("user-messages/\(messageId)", method: "DELETE")
    }

    // MARK: - Intelligence

    func analyzeTrace(barcode: String, batchId: String? = nil) async throws -> AnalyzeTraceResponse {
        var queryItems: [URLQueryItem]? = nil
        if let batchId {
            queryItems = [URLQueryItem(name: "batchId", value: batchId)]
        }
        return try await request(
            "intelligence/analyze/\(barcode)",
            baseURL: TomapoAPIConfig.intelligenceBaseURL,
            method: "POST",
            body: EmptyBody(),
            queryItems: queryItems
        )
    }

    func chatStream(
        barcode: String,
        batchId: String?,
        chatHistory: [ChatMessage],
        batchContext: [String: String]?
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let path = "intelligence/chat/\(barcode)"
                    guard let url = URL(string: "\(TomapoAPIConfig.intelligenceBaseURL)/\(path)") else {
                        continuation.finish(throwing: TomapoAPIError.invalidResponse)
                        return
                    }

                    var req = URLRequest(url: url)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    req.timeoutInterval = 120

                    let chatReq = ChatRequest(
                        batchId: batchId,
                        chatHistory: chatHistory,
                        batchContext: batchContext
                    )
                    req.httpBody = try encoder.encode(chatReq)

                    let (bytes, response) = try await URLSession.shared.bytes(for: req)
                    guard let http = response as? HTTPURLResponse,
                          (200...299).contains(http.statusCode) else {
                        continuation.finish(throwing: TomapoAPIError.serverError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500))
                        return
                    }

                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

// MARK: - Helper Types

struct EmptyResponse: Codable {}
struct EmptyBody: Encodable {}

/// Type-erased Encodable wrapper
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        self._encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
