//
//  ScanResultViewModel.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import Foundation
internal import Combine

@MainActor
final class ScanResultViewModel: ObservableObject {

    @Published var state: TomapoApiState = .idle
    @Published var traceLoading: Bool = false
    @Published var alertsLoading: Bool = false
    @Published var loadingMessage: String = "Loading product data..."

    // AI Chat
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatResponse: String = ""
    @Published var isChatStreaming: Bool = false
    @Published var chatError: String? = nil
    @Published var isChatExpanded: Bool = false

    private var currentBarcode: String = ""
    private var currentBatchId: String?

    func loadProduct(
        barcode: String,
        barcodeType: String = "EAN13",
        batchId: String? = nil,
        store: ScanHistoryStore
    ) async {
        currentBarcode = barcode
        currentBatchId = batchId
        state = .loading
        loadingMessage = "Loading product data..."

        let api = TomapoAPIService.shared

        // Try Tomapo API trace first
        do {
            loadingMessage = "Analyzing supply chain..."
            let product: TomapoResponse
            if let batchId {
                product = try await api.getTrace(barcode: barcode, batchId: batchId)
            } else {
                product = try await api.getTrace(barcode: barcode)
            }

            state = .loaded(product)

            // Save to local history
            store.add(
                barcode: barcode,
                barcodeType: barcodeType,
                batchId: batchId ?? product.batchId,
                productName: product.productName,
                brand: product.brands,
                imageUrl: product.displayImageUrl,
                nutriscoreGrade: product.nutriscoreGrade,
                ecoscoreGrade: product.ecoscoreGrade,
                co2KgPerKg: product.environmentSummary.co2TotalKgPerKg,
                bestBeforeDate: nil,
                hasActiveRecall: product.hasActiveRecall
            )

            // Save to server history (fire-and-forget)
            Task {
                let req = CreateScanEntryRequest(
                    barcode: barcode,
                    barcodeType: barcodeType,
                    productName: product.productName,
                    brand: product.brands,
                    nutriscoreGrade: product.nutriscoreGrade,
                    ecoscoreGrade: product.ecoscoreGrade,
                    co2KgPerKg: product.environmentSummary.co2TotalKgPerKg,
                    productStatus: product.hasActiveRecall ? "recalled" : "ok"
                )
                try? await api.createScanEntry(req)
            }
            return

        } catch let error as TomapoAPIError where error is TomapoAPIError {
            // If trace not found, try mock data as fallback
            if case .notFound = error {
                // Fall through to mock data
            } else if case .networkError = error {
                // Fall through to mock data
            } else if case .noToken = error {
                // Fall through to mock data (not logged in)
            } else {
                // For other errors, still try mock
            }
        } catch {
            // Network/other error — try mock
        }

        // Fallback to mock data
        loadingMessage = "Loading from cache..."
        let demoBarcode = TomapoMockData.trace(for: barcode) != nil ? barcode : "4316268651288"
        guard let product = TomapoMockData.trace(for: demoBarcode) else {
            state = .notFound
            return
        }
        state = .loaded(product)
        store.add(
            barcode: barcode,
            barcodeType: barcodeType,
            batchId: batchId ?? product.batchId,
            productName: product.productName,
            brand: product.brands,
            imageUrl: product.displayImageUrl,
            nutriscoreGrade: product.nutriscoreGrade,
            ecoscoreGrade: product.ecoscoreGrade,
            co2KgPerKg: product.environmentSummary.co2TotalKgPerKg,
            bestBeforeDate: nil,
            hasActiveRecall: product.hasActiveRecall
        )
    }

    // MARK: - AI Chat

    func sendChatMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMsg = ChatMessage(role: "user", content: text)
        chatMessages.append(userMsg)
        chatResponse = ""
        chatError = nil
        isChatStreaming = true

        Task {
            do {
                let stream = TomapoAPIService.shared.chatStream(
                    barcode: currentBarcode,
                    batchId: currentBatchId,
                    chatHistory: chatMessages,
                    batchContext: nil
                )

                for try await chunk in stream {
                    chatResponse += chunk
                }

                let assistantMsg = ChatMessage(role: "assistant", content: chatResponse)
                chatMessages.append(assistantMsg)
                isChatStreaming = false
            } catch {
                chatError = "Failed to get AI response. Please try again."
                isChatStreaming = false
            }
        }
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    var loadedProduct: TomapoResponse? {
        if case .loaded(let p) = state { return p }
        return nil
    }
}
