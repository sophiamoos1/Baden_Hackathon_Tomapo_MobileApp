//
//  ProductInfoScreen.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct ProductInfoScreen: View {
    let product: TomapoResponse
    var onBack: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.baseBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 60)
                    EnvironmentSection(env: product.environmentSummary, certs: product.certifications).padding(.horizontal, 16)
                    if !product.certifications.isEmpty {
                        CertificationsDetailSection(certifications: product.certifications).padding(.horizontal, 16)
                    }
                    OriginSection(product: product).padding(.horizontal, 16)
                    if let pkgs = product.packagings, !pkgs.isEmpty {
                        PackagingSection(packagings: pkgs, text: product.packagingText).padding(.horizontal, 16)
                    }
                    if let storage = product.conservationConditions, !storage.isEmpty {
                        StorageSection(text: storage).padding(.horizontal, 16)
                    }
                    DataQualitySection(product: product).padding(.horizontal, 16)
                    BarcodeSection(product: product).padding(.horizontal, 16)
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackNavigationBar(title: "Details", onBack: onBack)
        }
    }
}

// MARK: - Environment Section

private struct EnvironmentSection: View {
    let env: TomapoEnvironmentSummary
    let certs: [TomapoCertification]

    var body: some View {
        SheetSection(title: "Environment & Sustainability", icon: "leaf.fill") {
            VStack(spacing: 12) {
                if let total = env.co2TotalKgPerKg {
                    CO2BarView(total: total, phases: env.co2ByPhase)
                } else if env.ecoscoreGrade == "not-applicable" {
                    PlaceholderRow(text: "Eco-Score not applicable for this product category")
                } else {
                    PlaceholderRow(text: "CO\u{2082} data not available")
                }
                Divider()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    if let water = env.waterFootprintLiterPerKg {
                        EnvMetricCard(icon: "drop.fill", label: "Water Usage", value: "\(Int(water)) L/kg", color: Color.theme.infso)
                    }
                    if let forest = env.forestFootprintM2PerKg {
                        EnvMetricCard(icon: "tree.fill", label: "Forest Footprint", value: String(format: "%.2f m\u{00B2}/kg", forest), color: Color.theme.success)
                    }
                    if let dist = env.totalTransportDistanceKm {
                        EnvMetricCard(icon: "location.fill", label: "Transport Distance", value: "\(Int(dist)) km", color: Color.theme.cardFg)
                    }
                    if let recycle = env.recyclablePackagingPercent {
                        EnvMetricCard(icon: "arrow.3.trianglepath", label: "Recyclable", value: "\(Int(recycle))%", color: Color.theme.success)
                    }
                }
                if let risk = env.threatenedSpeciesRisk, let exp = risk.explanation {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.theme.warning).font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Threatened Species Risk").font(.caption.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                            Text(exp).font(.caption2).foregroundColor(Color.theme.mutedFg).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(10).background(Color.theme.warning.opacity(0.08)).cornerRadius(10)
                }
                if !certs.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Certificates").font(.caption).foregroundColor(Color.theme.mutedFg)
                        FlexTagCloud(tags: certs.filter(\.isCurrentlyValid).map(\.name), color: Color.theme.success)
                    }
                }
            }
        }
    }
}

private struct CO2BarView: View {
    let total: Double
    let phases: CO2ByPhase
    private var phaseData: [(String, Double, Color)] {
        let rows: [(String, Double, Color)] = [
            ("Agriculture", phases.agriculture ?? 0, Color.theme.success),
            ("Processing",   phases.processing ?? 0,  Color.theme.warning),
            ("Transport",    phases.transportation ?? 0, Color.theme.infso),
            ("Packaging",    phases.packaging ?? 0,   Color.theme.chartMutedPlumEarth),
            ("Distribution",   phases.distribution ?? 0, Color.theme.chartTerracottaRose)
        ]
        return rows.filter { $0.1 > 0 }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CO\u{2082} Footprint").font(.caption.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                Spacer()
                let lbl = total < 1 ? String(format: "%.2f", total) : String(format: "%.1f", total)
                Text("\(lbl) kg CO₂eq/kg").font(.caption.weight(.bold)).foregroundColor(total < 1 ? Color.theme.success : total < 3 ? Color.theme.warning : Color.theme.error)
            }
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(phaseData, id: \.0) { name, val, color in
                        RoundedRectangle(cornerRadius: 3).fill(color).frame(width: max(4, geo.size.width * (val / total)))
                    }
                }
            }
            .frame(height: 10).cornerRadius(5)
            FlexLayout {
                ForEach(phaseData, id: \.0) { name, val, color in
                    HStack(spacing: 4) {
                        Circle().fill(color).frame(width: 7, height: 7)
                        Text("\(name): \(String(format: "%.2f", val))kg").font(.caption2).foregroundColor(Color.theme.mutedFg)
                    }
                }
            }
        }
    }
}

private struct EnvMetricCard: View {
    let icon: String; let label: String; let value: String; let color: Color
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundColor(color).frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
                Text(value).font(.caption.weight(.semibold)).foregroundColor(Color.theme.cardFg)
            }
            Spacer()
        }
        .padding(10).background(Color.theme.cardBg).cornerRadius(10)
    }
}

// MARK: - Certifications Section

private struct CertificationsDetailSection: View {
    let certifications: [TomapoCertification]
    var body: some View {
        SheetSection(title: "Certificates (\(certifications.count))", icon: "checkmark.seal.fill") {
            VStack(spacing: 0) {
                ForEach(certifications) { cert in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(cert.name).font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                                    if cert.isCurrentlyValid {
                                        Image(systemName: "checkmark.seal.fill").font(.caption2).foregroundColor(Color.theme.success)
                                    }
                                }
                                if let body = cert.issuingBody {
                                    Text(body).font(.caption2).foregroundColor(Color.theme.mutedFg)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 3) {
                                Text(cert.scope.rawValue.capitalized).font(.caption2).foregroundColor(Color.theme.infso)
                                    .padding(.horizontal, 7).padding(.vertical, 2).background(Color.theme.infso.opacity(0.1)).cornerRadius(8)
                                if let until = cert.validUntil {
                                    Text("until \(until.formatted(.dateTime.day().month(.abbreviated).year()))").font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.5))
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        if cert.id != certifications.last?.id { Divider().padding(.leading, 16) }
                    }
                }
            }
            .background(Color.theme.cardBg).cornerRadius(12)
        }
    }
}

// MARK: - Origin Section

private struct OriginSection: View {
    let product: TomapoResponse
    private func fmt(_ tag: String) -> String {
        tag.replacingOccurrences(of: "en:", with: "").replacingOccurrences(of: "de:", with: "")
           .replacingOccurrences(of: "fr:", with: "").replacingOccurrences(of: "-", with: " ").capitalized
    }
    var body: some View {
        SheetSection(title: "Origin & Production", icon: "globe.europe.africa.fill") {
            VStack(spacing: 0) {
                if let origins = product.originsTags, !origins.isEmpty {
                    InfoRow(label: "Origin", value: origins.map { fmt($0) }.joined(separator: ", "))
                    Divider().padding(.leading, 16)
                }
                if let countries = product.countriesTags, !countries.isEmpty {
                    InfoRow(label: "Sales Country", value: countries.map { fmt($0) }.joined(separator: ", "))
                    Divider().padding(.leading, 16)
                }
                if let mfg = product.manufacturingPlaces, !mfg.isEmpty {
                    InfoRow(label: "Manufacturing", value: mfg)
                    Divider().padding(.leading, 16)
                }
                if let stores = product.storesTags, !stores.isEmpty {
                    InfoRow(label: "Available at", value: stores.prefix(4).map { fmt($0) }.joined(separator: ", "))
                }
                if product.isOrganic {
                    Divider().padding(.leading, 16)
                    InfoRow(label: "Production", value: "Organic certified (EU Organic)")
                }
            }
            .background(Color.theme.cardBg).cornerRadius(12)
        }
    }
}

// MARK: - Packaging Section

private struct PackagingSection: View {
    let packagings: [ProductPackaging]; let text: String?
    private func fmt(_ s: String?) -> String {
        (s ?? "–").replacingOccurrences(of: "en:", with: "").replacingOccurrences(of: "-", with: " ").capitalized
    }
    var body: some View {
        SheetSection(title: "Packaging", icon: "shippingbox.fill") {
            VStack(spacing: 0) {
                ForEach(Array(packagings.enumerated()), id: \.offset) { i, pkg in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(fmt(pkg.shape)).font(.subheadline).foregroundColor(Color.theme.cardFg)
                            Text(fmt(pkg.material)).font(.caption).foregroundColor(Color.theme.mutedFg)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if let r = pkg.recycling {
                                Text(r.contains("recycle") ? "♻ Recyclable" : "Not recyclable")
                                    .font(.caption2).foregroundColor(r.contains("recycle") ? Color.theme.success : Color.theme.error)
                            }
                            if let w = pkg.weightMeasured {
                                Text(String(format: "%.1fg", w)).font(.caption2).foregroundColor(Color.theme.mutedFg)
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if i < packagings.count - 1 { Divider().padding(.leading, 16) }
                }
            }
            .background(Color.theme.cardBg).cornerRadius(12)
            if let t = text, !t.isEmpty {
                Text(t).font(.caption).foregroundColor(Color.theme.mutedFg)
            }
        }
    }
}

// MARK: - Storage Section

private struct StorageSection: View {
    let text: String
    var body: some View {
        SheetSection(title: "Storage", icon: "thermometer.medium") {
            Text(text).font(.subheadline).foregroundColor(Color.theme.cardFg.opacity(0.8))
                .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.cardBg).cornerRadius(12)
        }
    }
}

// MARK: - Data Quality Section

private struct DataQualitySection: View {
    let product: TomapoResponse
    private func completenessColor(_ c: Double) -> Color { c >= 0.8 ? Color.theme.success : c >= 0.5 ? Color.theme.warning : Color.theme.error }
    var body: some View {
        SheetSection(title: "Data Quality", icon: "checkmark.shield") {
            VStack(spacing: 0) {
                if let c = product.completeness {
                    InfoRow(label: "Completeness", value: "\(Int(c * 100))%", valueColor: completenessColor(c))
                    Divider().padding(.leading, 16)
                }
                InfoRow(label: "Data Sources", value: product.dataSources.map(\.name).joined(separator: ", "))
                if !(product.dataQualityWarningsTags?.isEmpty ?? true) {
                    Divider().padding(.leading, 16)
                    InfoRow(label: "Warnings",
                            value: "\(product.dataQualityWarningsTags!.count) issues",
                            valueColor: Color.theme.warning)
                }
            }
            .background(Color.theme.cardBg).cornerRadius(12)
        }
    }
}

// MARK: - Barcode Section

private struct BarcodeSection: View {
    let product: TomapoResponse
    @State private var copied = false
    var body: some View {
        SheetSection(title: "Barcode", icon: "barcode") {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.barcode).font(.system(.subheadline, design: .monospaced)).foregroundColor(Color.theme.cardFg)
                    if let batch = product.batchId {
                        Text("Batch: \(batch)").font(.caption2).foregroundColor(Color.theme.mutedFg)
                    }
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = product.barcode
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc").font(.subheadline).foregroundColor(Color.theme.mutedFg)
                }
            }
            .padding(14).background(Color.theme.cardBg).cornerRadius(12)
        }
    }
}

