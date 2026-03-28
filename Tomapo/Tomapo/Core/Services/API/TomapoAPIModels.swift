//
//  TomapoAPIModels.swift
//  Tomapo
//
//  Request/Response models for the Tomapo API.
//

internal import Foundation

// MARK: - Auth

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: String

    enum CodingKeys: String, CodingKey {
        case accessToken  = "accessToken"
        case refreshToken = "refreshToken"
        case userId       = "userId"
    }
}

struct RegisterRequest: Encodable {
    let fullName: String
    let email: String
    let nickname: String
    let password: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

// MARK: - Scan History (Server)

struct ServerScanEntry: Codable, Identifiable {
    let id: String
    let userId: String?
    let barcode: String
    let barcodeType: String?
    let productName: String?
    let brand: String?
    let nutriscoreGrade: String?
    let ecoscoreGrade: String?
    let co2KgPerKg: Double?
    let productStatus: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, barcode, brand
        case userId          = "userId"
        case barcodeType     = "barcodeType"
        case productName     = "productName"
        case nutriscoreGrade = "nutriscoreGrade"
        case ecoscoreGrade   = "ecoscoreGrade"
        case co2KgPerKg      = "co2KgPerKg"
        case productStatus   = "productStatus"
        case createdAt       = "createdAt"
        case updatedAt       = "updatedAt"
    }
}

struct CreateScanEntryRequest: Encodable {
    let barcode: String
    let barcodeType: String
    let productName: String?
    let brand: String?
    let nutriscoreGrade: String?
    let ecoscoreGrade: String?
    let co2KgPerKg: Double?
    let productStatus: String?
}

// MARK: - User

struct UserProfileResponse: Codable {
    let id: String
    let fullName: String?
    let email: String?
    let nickname: String?
    let avatarUrl: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName  = "fullName"
        case email
        case nickname
        case avatarUrl = "avatarUrl"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

struct UpdateProfileRequest: Encodable {
    let fullName: String?
    let nickname: String?
}

struct UpdateAvatarRequest: Encodable {
    let avatarUrl: String
}

// MARK: - User Messages (Server)

struct ServerUserMessage: Codable, Identifiable {
    let id: String
    let userId: String?
    let category: String?
    let title: String?
    let body: String?
    let severity: String?
    let submissionStatus: String?
    let productSnapshot: ServerProductSnapshot?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, category, title, body, severity
        case userId           = "userId"
        case submissionStatus = "submissionStatus"
        case productSnapshot  = "productSnapshot"
        case createdAt        = "createdAt"
        case updatedAt        = "updatedAt"
    }
}

struct ServerProductSnapshot: Codable {
    let barcode: String?
    let batchId: String?
    let productName: String?
    let brand: String?
    let quantity: String?
    let imageUrl: String?
    let nutriscoreGrade: String?
    let ecoscoreGrade: String?
    let categoriesTags: [String]?
    let scannedAt: String?
    let scannedAtStoreName: String?
}

struct CreateMessageRequest: Encodable {
    let category: String
    let title: String
    let body: String
    let severity: String
    let productSnapshot: CreateMessageProductSnapshot
}

struct CreateMessageProductSnapshot: Encodable {
    let barcode: String
    let batchId: String?
    let productName: String?
    let brand: String?
    let quantity: String?
    let imageUrl: String?
    let nutriscoreGrade: String?
    let ecoscoreGrade: String?
    let categoriesTags: [String]?
    let scannedAt: String
    let scannedAtStoreName: String?
}

struct UpdateMessageStatusRequest: Encodable {
    let submissionStatus: String
}

// MARK: - Alert

struct CreateAlertRequest: Encodable {
    let barcode: String
    let batchId: String?
    let source: String
    let category: String
    let severity: String
    let title: String
    let description: String
    let actionRequired: String?
    let status: String
    let confirmationCount: Int
    let rejectionCount: Int
}

// MARK: - Intelligence / AI

struct AnalyzeTraceResponse: Codable {
    let analysis: String?
    let riskScore: Double?
    let findings: [AnalysisFinding]?
    let recommendations: [String]?

    enum CodingKeys: String, CodingKey {
        case analysis
        case riskScore       = "riskScore"
        case findings
        case recommendations
    }
}

struct AnalysisFinding: Codable, Identifiable {
    var id: String { category + (detail ?? "") }
    let category: String
    let severity: String?
    let detail: String?
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Encodable {
    let batchId: String?
    let chatHistory: [ChatMessage]
    let batchContext: [String: String]?
}
