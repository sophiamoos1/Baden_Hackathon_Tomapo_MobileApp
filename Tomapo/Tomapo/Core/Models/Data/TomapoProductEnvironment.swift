//
//  TomapoProductEnvironment.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//  Typen:
//  • TomapoEnvironmentSummary  – aggregierte Umweltkennzahlen (CO₂, Wasser, Wald…)
//  • CO2ByPhase                – CO₂ aufgeteilt nach Produktionsphase
//  • ThreatenedSpeciesRisk     – Artenbedrohungsrisiko (Palmöl, Soja)
//
//  Zertifikate wurden in TomapoCertification.swift ausgelagert.
//

internal import Foundation

// MARK: - TomapoEnvironmentSummary

struct TomapoEnvironmentSummary: Codable {

    // ── CO₂-Fussabdruck ───────────────────────────────────────────
    let co2ByPhase: CO2ByPhase
    /// Gesamt-CO₂ in kg CO₂eq pro kg Produkt
    let co2TotalKgPerKg: Double?
    let ecoscoreGrade: String?
    let ecoscoreScore: Int?

    // ── Wasser-Fussabdruck ────────────────────────────────────────
    let waterFootprintLiterPerKg: Double?
    /// Wasserknappheits-Score 0.0 (kein Stress) – 1.0 (extremer Stress)
    let waterStressScore: Double?

    // ── Waldschutz ────────────────────────────────────────────────
    let forestFootprintM2PerKg: Double?
    let forestFootprintGrade: String?
    let deforestationRisk: Double?

    // ── Transport ─────────────────────────────────────────────────
    let transportEmissionsGramsCo2: Double?
    let totalTransportDistanceKm: Double?
    let transportLegCount: Int?

    // ── Verpackung ────────────────────────────────────────────────
    let packagingCo2Kg: Double?
    let packagingScore: Int?
    let recyclablePackagingPercent: Double?

    // ── Biodiversität ─────────────────────────────────────────────
    let threatenedSpeciesRisk: ThreatenedSpeciesRisk?

    // ── Produktionssystem ─────────────────────────────────────────
    let productionSystemBonus: Int?
    let originEpiScore: Int?

    enum CodingKeys: String, CodingKey {
        case co2ByPhase                  = "co2_by_phase"
        case co2TotalKgPerKg             = "co2_total_kg_per_kg"
        case ecoscoreGrade               = "ecoscore_grade"
        case ecoscoreScore               = "ecoscore_score"
        case waterFootprintLiterPerKg    = "water_footprint_liter_per_kg"
        case waterStressScore            = "water_stress_score"
        case forestFootprintM2PerKg      = "forest_footprint_m2_per_kg"
        case forestFootprintGrade        = "forest_footprint_grade"
        case deforestationRisk           = "deforestation_risk"
        case transportEmissionsGramsCo2  = "transport_emissions_grams_co2"
        case totalTransportDistanceKm    = "total_transport_distance_km"
        case transportLegCount           = "transport_leg_count"
        case packagingCo2Kg              = "packaging_co2_kg"
        case packagingScore              = "packaging_score"
        case recyclablePackagingPercent  = "recyclable_packaging_percent"
        case threatenedSpeciesRisk       = "threatened_species_risk"
        case productionSystemBonus       = "production_system_bonus"
        case originEpiScore              = "origin_epi_score"
    }
}

// MARK: - CO2ByPhase

struct CO2ByPhase: Codable {
    let agriculture: Double?
    let processing: Double?
    let transportation: Double?
    let packaging: Double?
    let distribution: Double?
    let consumption: Double?
}

// MARK: - ThreatenedSpeciesRisk

struct ThreatenedSpeciesRisk: Codable {
    let ingredient: String?
    let ecoscorePenalty: Int?
    let explanation: String?

    enum CodingKeys: String, CodingKey {
        case ingredient
        case ecoscorePenalty = "ecoscore_penalty"
        case explanation
    }
}
