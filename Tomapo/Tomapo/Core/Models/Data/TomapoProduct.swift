//
//  TomapoResponse.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//
internal import Foundation
 
// MARK: - TomapoResponse
 
struct TomapoResponse: Codable {
 
    // MARK: Identität
    let barcode: String
    let batchId: String?
    let generatedAt: Date
 
    // MARK: Produktdaten (ehemals OFFProduct)
    let productName: String?
    let genericName: String?
    let brands: String?
    let quantity: String?
    let productQuantity: Double?
    let productQuantityUnit: String?
    let servingSize: String?
    let servingQuantity: Double?
    let storesTags: [String]?
 
    // MARK: Bilder
    let imageUrl: String?
    let imageFrontUrl: String?
    let imageIngredientsUrl: String?
    let imageNutritionUrl: String?
    let imagePackagingUrl: String?
 
    // MARK: Kategorisierung
    let categoriesTags: [String]?
    let foodGroupsTags: [String]?
    let foodGroups: String?
    let pnnsGroups1: String?
    let pnnsGroups2: String?
 
    // MARK: Scores
    let nutriscoreGrade: String?
    let nutriscoreScore: Int?
    let ecoscoreGrade: String?
    let ecoscoreScore: Int?
    let novaGroup: Int?
    let novaGroupError: String?
 
    // MARK: Nährwerte
    let nutriments: ProductNutriments?
    let nutrientLevels: ProductNutrientLevels?
 
    // MARK: Zutaten (Rohliste aus OFF – text-basiert)
    let ingredientsText: String?
    let rawIngredients: [RawIngredient]?
    let ingredientsN: Int?
    let additivesN: Int?
    let additivesTags: [String]?
 
    // MARK: Allergene & Diät
    let allergensTags: [String]?
    let tracesTags: [String]?
    let ingredientsAnalysisTags: [String]?
 
    // MARK: Labels & Herkunft
    let labelsTags: [String]?
    let countriesTags: [String]?
    let originsTags: [String]?
    let manufacturingPlaces: String?
    let manufacturingPlacesTags: [String]?
 
    // MARK: Verpackung
    let packagingTags: [String]?
    let packagings: [ProductPackaging]?
    let packagingText: String?
    let conservationConditions: String?
 
    // MARK: Datenqualität
    let dataQualityErrorsTags: [String]?
    let dataQualityWarningsTags: [String]?
    let completeness: Double?
 
    // MARK: Tomapo-Kern
    let alerts: [TomapoProductAlert]
    let stations: [TomapoStation]
    let environmentSummary: TomapoEnvironmentSummary
    let certifications: [TomapoCertification]
    let traceabilityScore: TomapoTraceabilityScore
    let dataSources: [TomapoDataSource]
    /// Strukturierte, angereicherte Zutaten (Tomapo-Modell – getrennt von rawIngredients)
    let ingredients: [ProductIngredient]
 
    // MARK: Kühlkette
    let requiresColdChain: Bool
    let coldChainSummary: TomapoColdChainSummary
 
    enum CodingKeys: String, CodingKey {
        case barcode, quantity, brands, certifications, alerts, stations
        case batchId                 = "batch_id"
        case generatedAt             = "generated_at"
        case productName             = "product_name"
        case genericName             = "generic_name"
        case productQuantity         = "product_quantity"
        case productQuantityUnit     = "product_quantity_unit"
        case servingSize             = "serving_size"
        case servingQuantity         = "serving_quantity"
        case storesTags              = "stores_tags"
        case imageUrl                = "image_url"
        case imageFrontUrl           = "image_front_url"
        case imageIngredientsUrl     = "image_ingredients_url"
        case imageNutritionUrl       = "image_nutrition_url"
        case imagePackagingUrl       = "image_packaging_url"
        case categoriesTags          = "categories_tags"
        case foodGroupsTags          = "food_groups_tags"
        case foodGroups              = "food_groups"
        case pnnsGroups1             = "pnns_groups_1"
        case pnnsGroups2             = "pnns_groups_2"
        case nutriscoreGrade         = "nutriscore_grade"
        case nutriscoreScore         = "nutriscore_score"
        case ecoscoreGrade           = "ecoscore_grade"
        case ecoscoreScore           = "ecoscore_score"
        case novaGroup               = "nova_group"
        case novaGroupError          = "nova_group_error"
        case nutriments
        case nutrientLevels          = "nutrient_levels"
        case ingredientsText         = "ingredients_text"
        case rawIngredients          = "raw_ingredients"
        case ingredientsN            = "ingredients_n"
        case additivesN              = "additives_n"
        case additivesTags           = "additives_tags"
        case allergensTags           = "allergens_tags"
        case tracesTags              = "traces_tags"
        case ingredientsAnalysisTags = "ingredients_analysis_tags"
        case labelsTags              = "labels_tags"
        case countriesTags           = "countries_tags"
        case originsTags             = "origins_tags"
        case manufacturingPlaces     = "manufacturing_places"
        case manufacturingPlacesTags = "manufacturing_places_tags"
        case packagingTags           = "packaging_tags"
        case packagings
        case packagingText           = "packaging_text"
        case conservationConditions  = "conservation_conditions"
        case dataQualityErrorsTags   = "data_quality_errors_tags"
        case dataQualityWarningsTags = "data_quality_warnings_tags"
        case completeness
        case environmentSummary      = "environment_summary"
        case traceabilityScore       = "traceability_score"
        case dataSources             = "data_sources"
        case ingredients
        case requiresColdChain       = "requires_cold_chain"
        case coldChainSummary        = "cold_chain_summary"
    }
}
 
// MARK: - Extension: Alerts
 
extension TomapoResponse {
    /// Legacy-Kompatibilität – berechnet aus alerts[]
    var recallStatus: TomapoRecallStatus { alerts.legacyRecallStatus }
    var activeAlerts: [TomapoProductAlert] {
        alerts.filter { $0.isActive }.sorted { $0.severity > $1.severity }
    }
    var officialRecalls: [TomapoProductAlert] {
        activeAlerts.filter { $0.isRecall && $0.isOfficial }
    }
    var communityAlerts: [TomapoProductAlert] {
        activeAlerts.filter { $0.source == .user || $0.source == .community }
    }
    var ownUserAlerts: [TomapoProductAlert] {
        alerts.filter { $0.source == .ownUser }
    }
    var highestAlertSeverity: AlertSeverity? { activeAlerts.first?.severity }
    var hasActiveRecall: Bool   { activeAlerts.contains { $0.isRecall } }
    var communityAlertCount: Int { communityAlerts.count }
}
 
// MARK: - Extension: Kühlkette
 
extension TomapoResponse {
    var refrigeratedStations: [TomapoStation] {
        stations.filter { $0.wasRefrigerated }
    }
    var refrigeratedStationRatio: Double {
        guard !stations.isEmpty else { return 0 }
        return Double(refrigeratedStations.count) / Double(stations.count)
    }
}
 
// MARK: - Extension: Zutaten
 
extension TomapoResponse {
    var subProductIngredients: [SubProductIngredient] {
        ingredients.compactMap {
            if case .subProduct(let s) = $0 { return s } else { return nil }
        }
    }
    var chemicalIngredients: [ChemicalIngredient] {
        ingredients.compactMap {
            if case .chemical(let c) = $0 { return c } else { return nil }
        }
    }
    var traceableSubProducts: [SubProductIngredient] {
        subProductIngredients.filter { $0.isTraceable }
    }
}
 
// MARK: - Extension: Produktdaten / Scores / Diät
 
extension TomapoResponse {
    var nova: NovaGroup          { NovaGroup(rawValue: novaGroup, error: novaGroupError) }
    var nutri: NutriScore        { NutriScore(rawString: nutriscoreGrade) }
    var eco: NutriScore          { NutriScore(rawString: ecoscoreGrade) }
    var dataCompleteness: DataCompleteness { DataCompleteness(completeness: completeness) }
 
    var hasReliableNutritionData: Bool {
        guard let n = nutriments else { return false }
        guard !(dataQualityErrorsTags?.isEmpty == false) else { return false }
        return n.hasMeaningfulNutritionData && !n.hasSuspiciousMacroSum
    }
    var hasDataErrors: Bool         { !(dataQualityErrorsTags?.isEmpty ?? true) }
    var isBeverage: Bool            { categoriesTags?.contains("en:beverages") ?? false }
    var isEcoScoreApplicable: Bool  { ecoscoreGrade != "not-applicable" }
    var ingredientCount: Int        { ingredientsN ?? rawIngredients?.count ?? 0 }
    var hasAdditives: Bool          { (additivesN ?? 0) > 0 }
 
    var veganStatus: DietStatus {
        guard let tags = ingredientsAnalysisTags else { return .unknown }
        if tags.contains("en:vegan")       { return .yes }
        if tags.contains("en:non-vegan")   { return .no }
        if tags.contains("en:maybe-vegan") { return .maybe }
        return .unknown
    }
    var containsPalmOil: Bool {
        ingredientsAnalysisTags?.contains("en:palm-oil") ?? false
    }
    var isOrganic: Bool {
        labelsTags?.contains("en:organic") ?? false ||
        labelsTags?.contains("en:eu-organic") ?? false
    }
    var isGlutenFree: Bool {
        labelsTags?.contains("en:no-gluten") ?? false ||
        labelsTags?.contains("en:gluten-free") ?? false
    }
    var displayImageUrl: String? { imageFrontUrl ?? imageUrl }
}
