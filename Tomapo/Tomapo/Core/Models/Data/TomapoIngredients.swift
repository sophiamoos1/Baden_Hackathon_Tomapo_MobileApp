//
//  TomapoIngridients.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//  Strukturiertes, angereichertes Zutaten-System (Tomapo-eigenes Modell).
//  Getrennt von rawIngredients (OFF-Rohliste) / RawIngredient (text-basiert).
//
//  Typen:
//  • ProductIngredient          – Enum: .subProduct oder .chemical
//  • SubProductIngredient       – Natürlicher Rohstoff mit eigener Lieferkette
//  • SubProductCategory         – nuts / cocoa / dairy / eggs / …
//  • ChemicalIngredient         – E-Nummer / Zusatzstoff
//  • ChemicalIngredientCategory / ChemicalFunction / ChemicalOrigin
//  • EUChemicalStatus / ChemicalHealthAssessment
//

internal import Foundation

// MARK: - ProductIngredient

enum ProductIngredient: Codable, Identifiable {

    case subProduct(SubProductIngredient)
    case chemical(ChemicalIngredient)

    var id: String {
        switch self {
        case .subProduct(let s): return s.id
        case .chemical(let c):   return c.id
        }
    }
    var displayName: String {
        switch self {
        case .subProduct(let s): return s.name
        case .chemical(let c):   return c.displayName
        }
    }
    var isSubProduct: Bool {
        if case .subProduct = self { return true }
        return false
    }
    var isTraceable: Bool {
        if case .subProduct(let s) = self { return s.traceData != nil }
        return false
    }

    enum CodingKeys: String, CodingKey { case type, data }

    init(from decoder: Decoder) throws {
        let c    = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        switch type {
        case "sub_product": self = .subProduct(try c.decode(SubProductIngredient.self, forKey: .data))
        case "chemical":    self = .chemical(try c.decode(ChemicalIngredient.self,    forKey: .data))
        default:            self = .subProduct(try c.decode(SubProductIngredient.self, forKey: .data))
        }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .subProduct(let d): try c.encode("sub_product", forKey: .type); try c.encode(d, forKey: .data)
        case .chemical(let d):   try c.encode("chemical",    forKey: .type); try c.encode(d, forKey: .data)
        }
    }
}

// MARK: - SubProductIngredient

struct SubProductIngredient: Codable, Identifiable {

    let id: String
    /// → GET /api/v1/trace/{barcode}
    let barcode: String
    let batchId: String?
    let name: String
    let description: String?
    let category: SubProductCategory
    let percentageInProduct: Double?
    let originCountry: String?
    let originRegion: String?
    let supplierName: String?
    let supplierCountry: String?
    let imageUrl: String?
    let certifications: [TomapoCertification]
    /// nil = nicht trackbar · non-nil = volle TomapoResponse (rekursiv)
    let traceData: TomapoResponse?

    enum CodingKeys: String, CodingKey {
        case id, barcode, name, description, category, certifications
        case batchId             = "batch_id"
        case percentageInProduct = "percentage_in_product"
        case originCountry       = "origin_country"
        case originRegion        = "origin_region"
        case supplierName        = "supplier_name"
        case supplierCountry     = "supplier_country"
        case imageUrl            = "image_url"
        case traceData           = "trace_data"
    }

    var isTraceable: Bool { traceData != nil }
    var displayOrigin: String? {
        switch (originCountry, originRegion) {
        case let (c?, r?): return "\(r), \(c)"
        case let (c?, nil): return c
        case let (nil, r?): return r
        default: return nil
        }
    }
}

// MARK: - SubProductCategory

enum SubProductCategory: String, Codable, CaseIterable {
    case nuts        = "nuts"
    case cocoa       = "cocoa"
    case grains      = "grains"
    case fruits      = "fruits"
    case vegetables  = "vegetables"
    case legumes     = "legumes"
    case oils        = "oils"
    case sugars      = "sugars"
    case spices      = "spices"
    case herbs       = "herbs"
    case fungi       = "fungi"
    case dairy       = "dairy"
    case meat        = "meat"
    case fish        = "fish"
    case eggs        = "eggs"
    case honey       = "honey"
    case flour       = "flour"
    case concentrates = "concentrates"
    case extracts    = "extracts"
    case other       = "other"
}

// MARK: - ChemicalIngredient

struct ChemicalIngredient: Codable, Identifiable {

    let id: String
    let eNumber: String?
    let name: String
    let description: String?
    let category: ChemicalIngredientCategory
    let function_: ChemicalFunction   // function ist reserved keyword
    let percentageInProduct: Double?
    let origin: ChemicalOrigin
    let isSynthetic: Bool
    let euRegulatoryStatus: EUChemicalStatus
    let healthAssessment: ChemicalHealthAssessment
    let healthNotes: String?
    let sensitiveGroups: [String]
    let acceptableDailyIntakeKgBw: Double?
    let maxAllowedMgPerKg: Double?
    let actualMgPerKg: Double?
    let efsaEvaluationUrl: String?
    let allowedInOrganic: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, description, category, origin
        case eNumber                   = "e_number"
        case function_                 = "function"
        case percentageInProduct       = "percentage_in_product"
        case isSynthetic               = "is_synthetic"
        case euRegulatoryStatus        = "eu_regulatory_status"
        case healthAssessment          = "health_assessment"
        case healthNotes               = "health_notes"
        case sensitiveGroups           = "sensitive_groups"
        case acceptableDailyIntakeKgBw = "acceptable_daily_intake_kg_bw"
        case maxAllowedMgPerKg         = "max_allowed_mg_per_kg"
        case actualMgPerKg             = "actual_mg_per_kg"
        case efsaEvaluationUrl         = "efsa_evaluation_url"
        case allowedInOrganic          = "allowed_in_organic"
    }

    var displayName: String { eNumber.map { "\($0) · \(name)" } ?? name }
    var hasENumber: Bool    { eNumber != nil }
    /// → GET /api/v1/chemicals/{identifier}
    var apiIdentifier: String { eNumber ?? name.lowercased().replacingOccurrences(of: " ", with: "_") }
}

// MARK: - ChemicalIngredientCategory

enum ChemicalIngredientCategory: String, Codable, CaseIterable {
    case preservative     = "preservative"
    case colorant         = "colorant"
    case antioxidant      = "antioxidant"
    case emulsifier       = "emulsifier"
    case thickener        = "thickener"
    case stabilizer       = "stabilizer"
    case flavourEnhancer  = "flavour_enhancer"
    case sweetener        = "sweetener"
    case acidityRegulator = "acidity_regulator"
    case flourTreatment   = "flour_treatment"
    case glazingAgent     = "glazing_agent"
    case humectant        = "humectant"
    case modifiedStarch   = "modified_starch"
    case flavouring       = "flavouring"
    case enzyme           = "enzyme"
    case other            = "other"
}

// MARK: - ChemicalFunction

enum ChemicalFunction: String, Codable {
    case preserving   = "preserving"
    case coloring     = "coloring"
    case sweetening   = "sweetening"
    case emulsifying  = "emulsifying"
    case thickening   = "thickening"
    case stabilizing  = "stabilizing"
    case flavouring   = "flavouring"
    case antioxidizing = "antioxidizing"
    case acidifying   = "acidifying"
    case buffering    = "buffering"
    case foaming      = "foaming"
    case glazing      = "glazing"
    case moistening   = "moistening"
    case other        = "other"
}

// MARK: - ChemicalOrigin

enum ChemicalOrigin: String, Codable {
    case synthetic       = "synthetic"
    case naturalIdentical = "nature_identical"
    case natural         = "natural"
    case fermentation    = "fermentation"
    case mineral         = "mineral"
    case unknown         = "unknown"
}

// MARK: - EUChemicalStatus

enum EUChemicalStatus: String, Codable {
    case approved        = "approved"
    case approvedWithAdi = "approved_with_adi"
    case underReview     = "under_review"
    case restricted      = "restricted"
    case banned          = "banned"
    case notListed       = "not_listed"
}

// MARK: - ChemicalHealthAssessment

enum ChemicalHealthAssessment: String, Codable {
    case safe                  = "safe"
    case generallyRecognizedSafe = "gras"
    case caution               = "caution"
    case controversial         = "controversial"
    case sensitiveOnly         = "sensitive_only"
    case avoid                 = "avoid"
    case unknown               = "unknown"
}
