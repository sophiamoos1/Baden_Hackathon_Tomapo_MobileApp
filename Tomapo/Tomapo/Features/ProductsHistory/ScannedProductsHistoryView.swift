//
//  ScannedProductsHistoryView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
 
struct ScannedProductsHistoryView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var historyStore: ScanHistoryStore
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
 
                // MARK: Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
 
                // MARK: Inhalt
                if historyStore.entries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }
            .padding(.bottom, 40)
        }
    }
 
    // MARK: - Header
 
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.theme.importantText)
 
                Text("\(historyStore.entries.count) gescannte Produkte")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.bodyText)
            }
 
            Spacer()
 
            // Alles löschen – nur anzeigen wenn Einträge vorhanden
            if !historyStore.entries.isEmpty {
                Button {
                    withAnimation { historyStore.clearAll() }
                } label: {
                    Text("Alles löschen")
                        .font(.caption)
                        .foregroundColor(Color.theme.bodyText.opacity(0.6))
                }
            }
        }
    }
 
    // MARK: - Entry List
 
    private var entryList: some View {
        LazyVStack(spacing: 10) {
            ForEach(historyStore.entries) { entry in
                ScanHistoryRow(entry: entry)
                    .padding(.horizontal, 16)
                    // Swipe-to-delete
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation { historyStore.remove(entry) }
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
            }
        }
    }
 
    // MARK: - Empty State
 
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundColor(Color.theme.bodyText.opacity(0.3))
 
            Text("Noch nichts gescannt")
                .font(.headline)
                .foregroundColor(Color.theme.importantText)
 
            Text("Scanne ein Produkt um es hier zu sehen.")
                .font(.subheadline)
                .foregroundColor(Color.theme.bodyText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 40)
    }
}
 
// MARK: - Preview

/*
 
#Preview {
    let store: ScanHistoryStore = {
        let s = ScanHistoryStore()
        s.add(barcode: "4316268651288", productName: "BioBio Bio-Eier Freilandhaltung", brand: "BioBio", barcodeType: "EAN13")
        s.add(barcode: "3274080005003", productName: "Cristaline Quellwasser", brand: "Cristaline", barcodeType: "EAN13")
        s.add(barcode: "5000159461122", productName: nil, brand: nil, barcodeType: "EAN13")
        return s
    }()
 
    return ZStack {
        GeometryReader { geo in
            Image("TomapBackground")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .ignoresSafeArea()
 
        ScannedProductsHistoryView(selectedTab: .constant(.history))
            .environmentObject(ThemeManager())
            .environmentObject(store)
    }
}
*/
