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
 
    func loadProduct(
        barcode: String,
        barcodeType: String = "EAN13",
        store: ScanHistoryStore
    ) async {
        state = .loading
        try? await Task.sleep(nanoseconds: 600_000_000)
 
        // Mock – fällt auf bioEier zurück falls kein Mock gefunden
        let demoBarcode = TomapoMockData.trace(for: barcode) != nil ? barcode : "4316268651288"
        guard let product = TomapoMockData.trace(for: demoBarcode) else {
            state = .notFound
            return
        }
        state = .loaded(product)
        store.add(
            barcode: barcode,
            barcodeType: barcodeType,
            batchId: product.batchId,
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
 
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    var loadedProduct: TomapoResponse? {
        if case .loaded(let p) = state { return p }
        return nil
    }
}
