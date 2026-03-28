//
//  TomapoProductNutrition.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//  Typen:
//  • ProductNutriments      – Nährwerte pro 100g und pro Portion
//  • ProductNutrientLevels  – Ampelwerte (low/moderate/high) für Fett, Salz, Zucker
//  • RawIngredient          – Rohe Zutatenliste aus OFF (rekursiv, text-basiert)
//  • ProductPackaging       – Verpackungseinzelheit aus OFF packagings
//  • NutriScore             – Enum a–e + not-applicable + unknown
//  • NovaGroup              – Enum 1–4 + notComputable
//  • DietStatus             – yes / no / maybe / unknown
//  • DataCompleteness       – full / partial / minimal
//  • NutrientLevel          – low / moderate / high / unknown
//

internal import Foundation

// MARK: - ProductNutriments

struct ProductNutriments: Codable {

    // MARK: Energie
    let energyKcal100g: Double?
    let energyKj100g: Double?
    let energyKcalServing: Double?
    let energyKjServing: Double?

    // MARK: Fett
    let fat100g: Double?
    let saturatedFat100g: Double?
    let fatServing: Double?
    let saturatedFatServing: Double?

    // MARK: Kohlenhydrate
    let carbohydrates100g: Double?
    let sugars100g: Double?
    let fiber100g: Double?
    let addedSugars100g: Double?
    let starch100g: Double?
    let carbohydratesServing: Double?
    let sugarsServing: Double?
    let fiberServing: Double?

    // MARK: Proteine
    let proteins100g: Double?
    let proteinsServing: Double?

    // MARK: Salz / Natrium
    let salt100g: Double?
    let sodium100g: Double?
    let saltServing: Double?
    let sodiumServing: Double?

    // MARK: NOVA
    let novaGroup100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g       = "energy_kcal_100g"
        case energyKj100g         = "energy_kj_100g"
        case energyKcalServing    = "energy_kcal_serving"
        case energyKjServing      = "energy_kj_serving"
        case fat100g              = "fat_100g"
        case saturatedFat100g     = "saturated_fat_100g"
        case fatServing           = "fat_serving"
        case saturatedFatServing  = "saturated_fat_serving"
        case carbohydrates100g    = "carbohydrates_100g"
        case sugars100g           = "sugars_100g"
        case fiber100g            = "fiber_100g"
        case addedSugars100g      = "added_sugars_100g"
        case starch100g           = "starch_100g"
        case carbohydratesServing = "carbohydrates_serving"
        case sugarsServing        = "sugars_serving"
        case fiberServing         = "fiber_serving"
        case proteins100g         = "proteins_100g"
        case proteinsServing      = "proteins_serving"
        case salt100g             = "salt_100g"
        case sodium100g           = "sodium_100g"
        case saltServing          = "salt_serving"
        case sodiumServing        = "sodium_serving"
        case novaGroup100g        = "nova_group_100g"
    }

    // MARK: Computed

    /// Salz > 100g/100g ist physikalisch unmöglich → Datenfehler
    var hasSuspiciousSaltValue: Bool {
        (salt100g ?? 0) > 100
    }

    /// Alle Makros addieren deutlich mehr als 100g/100g → Datenfehler
    var hasSuspiciousMacroSum: Bool {
        let fat   = fat100g ?? 0
        let carbs = carbohydrates100g ?? 0
        let prot  = proteins100g ?? 0
        return fat + carbs + prot > 105
    }

    /// Mindestens Energie oder ein Makro vorhanden und keine schweren Fehler
    var hasMeaningfulNutritionData: Bool {
        let hasEnergy = (energyKcal100g ?? 0) > 0
        let hasMacros = (fat100g != nil || carbohydrates100g != nil || proteins100g != nil)
        return (hasEnergy || hasMacros) && !hasSuspiciousMacroSum
    }
}

// MARK: - ProductNutrientLevels

struct ProductNutrientLevels: Codable {
    let fat: String?
    let saturatedFat: String?
    let sugars: String?
    let salt: String?

    enum CodingKeys: String, CodingKey {
        case fat
        case saturatedFat = "saturated_fat"
        case sugars
        case salt
    }
}

// MARK: - RawIngredient

/// Rohe Zutatenliste aus OFF – text-basiert, rekursiv für Unterkomponenten.
/// Getrennt von ProductIngredient (dem strukturierten Tomapo-Modell).
struct RawIngredient: Codable {
    let id: String?
    let text: String?
    let percent: Double?
    let percentEstimate: Double?
    let percentMin: Double?
    let percentMax: Double?
    let vegan: String?
    let vegetarian: String?
    let fromPalmOil: String?
    /// Unterkomponenten (z.B. \"Haselnüsse\" unter \"Schokolade\")
    let ingredients: [RawIngredient]?

    enum CodingKeys: String, CodingKey {
        case id, text, percent, vegan, vegetarian, ingredients
        case percentEstimate = "percent_estimate"
        case percentMin      = "percent_min"
        case percentMax      = "percent_max"
        case fromPalmOil     = "from_palm_oil"
    }
}

// MARK: - ProductPackaging

struct ProductPackaging: Codable {
    let material: String?
    let shape: String?
    let recycling: String?
    let weightMeasured: Double?
    let numberOfUnits: Int?
    let quantityPerUnit: String?
    let foodContact: Int?
    let nonRecyclableAndNonBiodegradable: String?
    let environmentalScoreMaterialScore: Int?

    enum CodingKeys: String, CodingKey {
        case material, shape, recycling
        case weightMeasured                     = "weight_measured"
        case numberOfUnits                      = "number_of_units"
        case quantityPerUnit                    = "quantity_per_unit"
        case foodContact                        = "food_contact"
        case nonRecyclableAndNonBiodegradable   = "non_recyclable_and_non_biodegradable"
        case environmentalScoreMaterialScore    = "environmental_score_material_score"
    }
}

// MARK: - NutriScore

enum NutriScore: Equatable {
    case a, b, c, d, e
    case notApplicable
    case unknown

    var isKnown: Bool {
        switch self { case .unknown, .notApplicable: return false; default: return true }
    }

    var label: String {
        switch self {
        case .a: return "Sehr gut"
        case .b: return "Gut"
        case .c: return "Mittel"
        case .d: return "Weniger gut"
        case .e: return "Schlecht"
        case .notApplicable: return "Nicht anwendbar"
        case .unknown: return "Unbekannt"
        }
    }

    init(rawString: String?) {
        switch rawString?.lowercased() {
        case "a":              self = .a
        case "b":              self = .b
        case "c":              self = .c
        case "d":              self = .d
        case "e":              self = .e
        case "not-applicable": self = .notApplicable
        default:               self = .unknown
        }
    }
}

// MARK: - NovaGroup

enum NovaGroup: Equatable {
    case unprocessed          // 1 – Unverarbeitete Lebensmittel
    case culinaryIngredient   // 2 – Kulinarische Zutaten
    case processed            // 3 – Verarbeitete Lebensmittel
    case ultraProcessed       // 4 – Hochverarbeitete Lebensmittel
    case notComputable        // 0 / nil – Nicht berechenbar

    var isKnown: Bool { self != .notComputable }

    var label: String {
        switch self {
        case .unprocessed:        return "Unverarbeitete Lebensmittel"
        case .culinaryIngredient: return "Kulinarische Zutaten"
        case .processed:          return "Verarbeitete Lebensmittel"
        case .ultraProcessed:     return "Hochverarbeitet"
        case .notComputable:      return "Nicht berechenbar"
        }
    }

    init(rawValue: Int?, error: String?) {
        if error == "missing_ingredients" { self = .notComputable; return }
        switch rawValue {
        case 1: self = .unprocessed
        case 2: self = .culinaryIngredient
        case 3: self = .processed
        case 4: self = .ultraProcessed
        default: self = .notComputable
        }
    }
}

// MARK: - DietStatus

enum DietStatus: Equatable {
    case yes, no, maybe, unknown
}

// MARK: - DataCompleteness

enum DataCompleteness: Equatable {
    /// completeness ≥ 0.85
    case full
    /// 0.40 ≤ completeness < 0.85
    case partial
    /// completeness < 0.40
    case minimal

    init(completeness: Double?) {
        switch completeness ?? 0 {
        case 0.85...: self = .full
        case 0.40...: self = .partial
        default:      self = .minimal
        }
    }
}

// MARK: - NutrientLevel

enum NutrientLevel: Equatable {
    case low, moderate, high, unknown

    init(rawString: String?) {
        switch rawString {
        case "low":      self = .low
        case "moderate": self = .moderate
        case "high":     self = .high
        default:         self = .unknown
        }
    }
}
