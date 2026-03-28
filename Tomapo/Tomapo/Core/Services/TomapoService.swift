//
//  TomapoService.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Typen:
//  • TomapoApiState   – idle / loading / loaded / notFound / error
//  • TomapoApiError   – invalidBarcode / networkError / decodingError / serverError / timeout
//  • TomapoService    – Singleton · alle API-Endpunkte des Tomapo-Backends
//
//  Architektur:
//  Ein einziger Backend-Call liefert alles:
//    GET /v1/trace/{barcode}          → TomapoResponse (OFF-Daten + Lieferkette)
//    GET /v1/trace/{barcode}/{batchId}→ batch-spezifisch
//    GET /v1/alerts/{barcode}         → nur Alerts (schneller Pfad)
//    GET /v1/chemicals/{identifier}   → Chemikalie-Datenblatt
//    POST /v1/alerts                  → User-Meldung einreichen
//

internal import Foundation

// MARK: - TomapoApiState

enum TomapoApiState {
    case idle
    case loading
    case loaded(TomapoResponse)
    case notFound
    case error(TomapoApiError)
}

// MARK: - TomapoApiError

enum TomapoApiError: LocalizedError {
    case invalidBarcode
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidBarcode:       return "Ungültiger Barcode"
        case .networkError(let e):  return "Netzwerkfehler: \(e.localizedDescription)"
        case .decodingError(let e): return "Datenfehler: \(e.localizedDescription)"
        case .serverError(let c):   return "Server-Fehler \(c)"
        case .timeout:              return "Zeitüberschreitung"
        }
    }
}

// MARK: - TomapoService

final class TomapoService {

    static let shared = TomapoService()
    private init() {}

    private let baseURL = "https://api.wheresmytomato.app/v1"

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: Haupt-Endpunkt

    func fetchTrace(barcode: String) async -> Result<TomapoResponse, TomapoApiError> {
        guard !barcode.isEmpty else { return .failure(.invalidBarcode) }
        return await get(path: "trace/\(barcode)")
    }

    func fetchTrace(barcode: String,
                    batchId: String) async -> Result<TomapoResponse, TomapoApiError> {
        guard !barcode.isEmpty else { return .failure(.invalidBarcode) }
        return await get(path: "trace/\(barcode)/\(batchId)")
    }

    // MARK: Nur Alerts (schneller Pfad)

    func fetchAlerts(barcode: String) async -> Result<[TomapoProductAlert], TomapoApiError> {
        return await get(path: "alerts/\(barcode)")
    }

    // MARK: Chemikalie

    func fetchChemical(identifier: String) async -> Result<ChemicalIngredient, TomapoApiError> {
        return await get(path: "chemicals/\(identifier.lowercased())")
    }

    // MARK: User-Meldung einreichen

    func submitAlert(_ message: TomapoUserMessage) async -> Result<TomapoProductAlert, TomapoApiError> {
        guard let url = URL(string: "\(baseURL)/alerts") else {
            return .failure(.invalidBarcode)
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 15
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        do { req.httpBody = try enc.encode(message) }
        catch { return .failure(.decodingError(error)) }
        return await perform(req)
    }

    // MARK: Privat

    private func get<T: Decodable>(path: String) async -> Result<T, TomapoApiError> {
        guard let url = URL(string: "\(baseURL)/\(path)") else {
            return .failure(.invalidBarcode)
        }
        var req = URLRequest(url: url)
        req.setValue("WheresMyTomato/1.0 (contact@wheresmytomato.dev)",
                     forHTTPHeaderField: "User-Agent")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 15
        return await perform(req)
    }

    private func perform<T: Decodable>(_ request: URLRequest) async -> Result<T, TomapoApiError> {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            return .failure(.networkError(error))
        }
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            return http.statusCode == 404
                ? .failure(.invalidBarcode)
                : .failure(.serverError(http.statusCode))
        }
        do {
            return .success(try decoder.decode(T.self, from: data))
        } catch {
            return .failure(.decodingError(error))
        }
    }
}
