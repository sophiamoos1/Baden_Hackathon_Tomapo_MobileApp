//
//  ProductIngridientScreen.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
struct ProductIngredientsScreen: View {
    let product: TomapoResponse
    var onBack: () -> Void
 
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.baseBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Diät + Badges
                    DietSummarySection(product: product).padding(.horizontal, 16)
 
                    // Allergene
                    if let allergens = product.allergensTags, !allergens.isEmpty {
                        AllergenSection(allergens: allergens, traces: product.tracesTags ?? [])
                            .padding(.horizontal, 16)
                    }
 
                    // Strukturierte Zutaten (SubProducts + Chemicals)
                    if !product.ingredients.isEmpty {
                        StructuredIngredientsSection(ingredients: product.ingredients)
                            .padding(.horizontal, 16)
                    }
 
                    // Rohliste
                    if let text = product.ingredientsText, !text.isEmpty {
                        RawIngredientsSection(text: text, count: product.ingredientCount,
                                              additivesN: product.additivesN ?? 0)
                            .padding(.horizontal, 16)
                    }
 
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackNavigationBar(title: "Ingredients", onBack: onBack)
        }
    }
}
 
// MARK: - Diet Summary
 
private struct DietSummarySection: View {
    let product: TomapoResponse
    var body: some View {
        SheetSection(title: "Diet & Labeling", icon: "leaf.fill") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    DietBadge(label: "Vegan", status: product.veganStatus)
                    if product.isGlutenFree   { PillBadge(label: "Gluten Free", color: Color.theme.infso) }
                    if product.containsPalmOil { PillBadge(label: "Palm Oil", color: Color.theme.warning) }
                    if product.isOrganic       { PillBadge(label: "Organic", color: Color.theme.success) }
                    Spacer()
                }
                if let n = product.additivesN, n > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flask.fill").font(.caption2)
                            .foregroundColor(n > 5 ? Color.theme.warning : Color.theme.infso)
                        Text("\(n) Additives (E-numbers)")
                            .font(.caption).foregroundColor(n > 5 ? Color.theme.warning : Color.theme.mutedFg)
                    }
                }
                if let tags = product.additivesTags, !tags.isEmpty {
                    FlexTagCloud(tags: tags.map { $0.replacingOccurrences(of: "en:e", with: "E").uppercased() }, color: Color.theme.infso)
                }
            }
        }
    }
}
 
// MARK: - Allergen Section
 
private struct AllergenSection: View {
    let allergens: [String]; let traces: [String]
    private func format(_ tag: String) -> String {
        tag.replacingOccurrences(of: "en:", with: "").replacingOccurrences(of: "-", with: " ").capitalized
    }
    var body: some View {
        SheetSection(title: "Allergens & Traces", icon: "exclamationmark.shield.fill") {
            VStack(alignment: .leading, spacing: 10) {
                FlexTagCloud(tags: allergens.map { format($0) }, color: Color.theme.error)
                if !traces.isEmpty {
                    Text("May contain traces").font(.caption2).foregroundColor(Color.theme.mutedFg)
                    FlexTagCloud(tags: traces.map { format($0) }, color: Color.theme.warning)
                }
            }
        }
    }
}
 
// MARK: - Structured Ingredients
 
private struct StructuredIngredientsSection: View {
    let ingredients: [ProductIngredient]
    @State private var selectedSubProduct: SubProductIngredient? = nil
 
    var body: some View {
        SheetSection(title: "Ingredients (enriched)", icon: "list.bullet.rectangle") {
            VStack(spacing: 8) {
                ForEach(ingredients) { ingredient in
                    switch ingredient {
                    case .subProduct(let sp):
                        SubProductRow(subProduct: sp) { selectedSubProduct = sp }
                    case .chemical(let chem):
                        ChemicalIngredientRow(chemical: chem)
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedSubProduct) { sp in
            SubProductDetailScreen(subProduct: sp, onBack: { selectedSubProduct = nil })
        }
    }
}
 
private struct SubProductRow: View {
    let subProduct: SubProductIngredient
    let onTap: () -> Void
 
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.theme.success.opacity(0.12)).frame(width: 36, height: 36)
                    Image(systemName: categoryIcon).font(.system(size: 16)).foregroundColor(Color.theme.success)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(subProduct.name).font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                        if subProduct.isTraceable {
                            Image(systemName: "checkmark.seal.fill").font(.caption2).foregroundColor(Color.theme.success)
                        }
                    }
                    HStack(spacing: 8) {
                        if let pct = subProduct.percentageInProduct {
                            Text("\(Int(pct))%").font(.caption2).foregroundColor(Color.theme.mutedFg)
                        }
                        if let origin = subProduct.displayOrigin {
                            Text(origin).font(.caption2).foregroundColor(Color.theme.mutedFg)
                        }
                        if let supplier = subProduct.supplierName {
                            Text(supplier).font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.5)).lineLimit(1)
                        }
                    }
                }
                Spacer()
                if subProduct.isTraceable {
                    Image(systemName: "chevron.right").font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.35))
                }
            }
            .padding(12).background(Color.theme.cardBg).cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
 
    private var categoryIcon: String {
        switch subProduct.category {
        case .nuts:       return "leaf.fill"
        case .cocoa:      return "cup.and.saucer.fill"
        case .dairy:      return "drop.fill"
        case .eggs:       return "circle.fill"
        case .fish:       return "fish.fill"
        case .meat:       return "fork.knife"
        case .grains:     return "wheat"
        case .fruits:     return "apple.logo"
        case .vegetables: return "carrot"
        default:          return "leaf.fill"
        }
    }
}
 
private struct ChemicalIngredientRow: View {
    let chemical: ChemicalIngredient
    @State private var expanded = false
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(healthColor.opacity(0.12)).frame(width: 36, height: 36)
                        Image(systemName: "flask.fill").font(.system(size: 15)).foregroundColor(healthColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chemical.displayName).font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                        Text(chemical.category.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption2).foregroundColor(Color.theme.mutedFg)
                    }
                    Spacer()
                    HealthAssessmentBadge(assessment: chemical.healthAssessment)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.35))
                }
                .padding(12)
            }
            .buttonStyle(.plain)
 
            if expanded {
                Divider().padding(.leading, 60)
                VStack(alignment: .leading, spacing: 8) {
                    if let desc = chemical.description {
                        Text(desc).font(.caption).foregroundColor(Color.theme.mutedFg)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 16) {
                        LabelValue(label: "Function", value: chemical.function_.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        LabelValue(label: "Origin", value: chemical.origin.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        LabelValue(label: "EU-Status", value: chemical.euRegulatoryStatus.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    }
                    if let adi = chemical.acceptableDailyIntakeKgBw {
                        LabelValue(label: "ADI", value: "\(adi) mg/kg BW/day")
                    }
                    if let notes = chemical.healthNotes {
                        Text(notes).font(.caption2).foregroundColor(Color.theme.mutedFg)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if !chemical.sensitiveGroups.isEmpty {
                        HStack(spacing: 4) {
                            Text("Caution:").font(.caption2.weight(.semibold)).foregroundColor(Color.theme.warning)
                                .layoutPriority(1)
                            Text(chemical.sensitiveGroups.joined(separator: ", ")).font(.caption2).foregroundColor(Color.theme.warning)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.horizontal, 60).padding(.vertical, 10)
            }
        }
        .background(Color.theme.cardBg).cornerRadius(12)
    }
 
    private var healthColor: Color {
        switch chemical.healthAssessment {
        case .safe, .generallyRecognizedSafe: return Color.theme.success
        case .caution, .sensitiveOnly:        return Color.theme.warning
        case .controversial, .avoid:          return Color.theme.warning
        default:                              return Color.theme.mutedFg
        }
    }
}
 
private struct HealthAssessmentBadge: View {
    let assessment: ChemicalHealthAssessment
    var body: some View {
        Text(label).font(.caption2).foregroundColor(color)
            .padding(.horizontal, 7).padding(.vertical, 3).background(color.opacity(0.1)).cornerRadius(8)
    }
    private var label: String {
        switch assessment {
        case .safe, .generallyRecognizedSafe: return "Safe"
        case .caution:                        return "Caution"
        case .controversial:                  return "Controversial"
        case .sensitiveOnly:                  return "Sensitive"
        case .avoid:                          return "Avoid"
        default:                              return "Unknown"
        }
    }
    private var color: Color {
        switch assessment {
        case .safe, .generallyRecognizedSafe: return Color.theme.success
        case .caution, .sensitiveOnly:        return Color.theme.warning
        case .controversial, .avoid:          return Color.theme.warning
        default:                              return Color.theme.mutedFg
        }
    }
}
 
// MARK: - Raw Ingredients Section
 
private struct RawIngredientsSection: View {
    let text: String; let count: Int; let additivesN: Int
    @State private var expanded = false
 
    var body: some View {
        SheetSection(title: "Ingredient List (\(count))", icon: "doc.text") {
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .font(.caption).foregroundColor(Color.theme.mutedFg)
                    .lineLimit(expanded ? nil : 4)
                    .animation(.easeInOut(duration: 0.2), value: expanded)
                Button(expanded ? "Show less" : "Show full list") {
                    expanded.toggle()
                }
                .font(.caption.weight(.semibold)).foregroundColor(Color.theme.infso)
            }
        }
    }
}
 
// MARK: - SubProduct Detail Screen
 
struct SubProductDetailScreen: View {
    let subProduct: SubProductIngredient
    var onBack: () -> Void
 
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.baseBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero
                    subProductHero.padding(.horizontal, 16)
 
                    // Falls Trace vorhanden: wie ein normales Produkt anzeigen
                    if let trace = subProduct.traceData {
                        // Score Triplet
                        ScoreTripletSection(product: trace).padding(.horizontal, 16)
 
                        // Environment
                        EnvironmentSummarySection(env: trace.environmentSummary, certs: trace.certifications)
                            .padding(.horizontal, 16)
 
                        // S 
                        if !trace.stations.isEmpty {
                            TomapoStationTimeline(stations: trace.stations)
                                .padding(.horizontal, 16)
                        }
                    } else {
                        // Keine Trace-Daten
                        noTraceView.padding(.horizontal, 16)
                    }
 
                    // Zertifikate
                    if !subProduct.certifications.isEmpty {
                        CertificationsSection(certifications: subProduct.certifications).padding(.horizontal, 16)
                    }
 
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackNavigationBar(title: subProduct.name, onBack: onBack)
        }
    }
 
    private var subProductHero: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.theme.success.opacity(0.12)).frame(width: 56, height: 56)
                Image(systemName: "leaf.fill").font(.system(size: 24)).foregroundColor(Color.theme.success)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(subProduct.name).font(.title3.weight(.bold)).foregroundColor(Color.theme.cardFg)
                if let origin = subProduct.displayOrigin {
                    Label(origin, systemImage: "location.fill").font(.caption).foregroundColor(Color.theme.mutedFg)
                }
                if let supplier = subProduct.supplierName {
                    Text(supplier).font(.caption).foregroundColor(Color.theme.mutedFg)
                }
            }
            Spacer()
        }
        .padding(14).background(Color.theme.cardBg).cornerRadius(14)
    }
 
    private var noTraceView: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.circle").font(.system(size: 36)).foregroundColor(Color.theme.mutedFg.opacity(0.35))
            Text("No Traceability Data").font(.subheadline).foregroundColor(Color.theme.mutedFg)
            Text("No supply chain data available for this ingredient.")
                .font(.caption).foregroundColor(Color.theme.mutedFg)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 30)
    }
}
 
// MARK: - Shared sub-components
 
private struct ScoreTripletSection: View {
    let product: TomapoResponse
    var body: some View {
        SheetSection(title: "Scores", icon: "chart.bar.fill") {
            HStack(spacing: 12) {
                ScorePillSimple(label: "Nutri", grade: product.nutriscoreGrade)
                ScorePillSimple(label: "Eco",   grade: product.ecoscoreGrade)
                ScorePillSimple(label: "NOVA",  grade: product.novaGroup.map { "\($0)" })
                Spacer()
            }
        }
    }
}
 
private struct ScorePillSimple: View {
    let label: String; let grade: String?
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(bgColor).frame(width: 40, height: 40)
                Text((grade?.uppercased() ?? "?")).font(.system(size: 16, weight: .black)).foregroundColor(textColor)
            }
            Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
        }
    }
    private var bgColor: Color {
        switch grade?.lowercased() {
        case "a": return Color.theme.success; case "b": return Color.theme.chartDustyOlive
        case "c": return Color.theme.warning; case "d": return Color.theme.chartTerracottaRose
        case "e": return Color.theme.error;   default:  return Color.theme.mutedBg
        }
    }
    private var textColor: Color {
        switch grade?.lowercased() {
        case "a","b","c","d","e": return .white; default: return Color.theme.mutedFg
        }
    }
}
 
private struct EnvironmentSummarySection: View {
    let env: TomapoEnvironmentSummary; let certs: [TomapoCertification]
    var body: some View {
        SheetSection(title: "Environment", icon: "leaf.fill") {
            VStack(spacing: 8) {
                if let total = env.co2TotalKgPerKg {
                    HStack {
                        Image(systemName: "cloud.fill").foregroundColor(Color.theme.success).font(.caption)
                        Text("CO₂: \(String(format: "%.3f", total)) kg CO₂eq/kg")
                            .font(.subheadline.weight(.semibold)).foregroundColor(Color.theme.cardFg)
                        Spacer()
                    }
                }
                if let water = env.waterFootprintLiterPerKg {
                    HStack {
                        Image(systemName: "drop.fill").foregroundColor(Color.theme.infso).font(.caption)
                        Text("Water: \(Int(water)) L/kg").font(.caption).foregroundColor(Color.theme.mutedFg)
                        Spacer()
                    }
                }
            }
        }
    }
}
 
private struct CertificationsSection: View {
    let certifications: [TomapoCertification]
    var body: some View {
        SheetSection(title: "Certificates", icon: "checkmark.seal.fill") {
            FlexTagCloud(tags: certifications.map { $0.name }, color: Color.theme.success)
        }
    }
}
 
private struct LabelValue: View {
    let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
            Text(value).font(.caption.weight(.semibold)).foregroundColor(Color.theme.cardFg)
        }
    }
}
 
private struct PillBadge: View {
    let label: String; let color: Color
    var body: some View {
        Text(label).font(.caption2).foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 4).background(color.opacity(0.12)).cornerRadius(20)
    }
}
