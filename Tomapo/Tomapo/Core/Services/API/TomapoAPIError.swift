//
//  TomapoAPIError.swift
//  Tomapo
//
//  Error types for the Tomapo API service.
//

internal import Foundation

enum TomapoAPIError: LocalizedError {
    case unauthorized
    case notFound
    case serverError(Int)
    case decodingError(Error)
    case networkError(Error)
    case noToken
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unauthorized:       return "Session expired. Please log in again."
        case .notFound:           return "The requested resource was not found."
        case .serverError(let c): return "Server error (\(c)). Please try again later."
        case .decodingError:      return "Failed to parse server response."
        case .networkError:       return "Connection failed. Please check your internet."
        case .noToken:            return "Not authenticated. Please log in."
        case .invalidResponse:    return "Invalid server response."
        }
    }
}
