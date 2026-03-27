//
//  TomapoQualityCheck.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Qualitätsprüfungen entlang der Produktionskette.
//  Jede Station kann beliebig viele Qualitätschecks haben.
//
//  Typen:
//  • TomapoQualityCheck       – Haupt-Struct
//  • QualityCheckType         – 40+ Typen (visualInspection … haccp)
//  • QualityCheckStatus       – passed / failed / warning / pending / …
//  • QualityCheckDetail       – Enum mit 9 typisierten Detail-Cases
//  • TemperatureCheckDetail    + SensorReading (aus TomapoColdChain.swift)
//  • MicrobiologicalCheckDetail + PathogenResult / BacterialCountResult
//  • ChemicalCheckDetail      + ChemicalSubstanceResult / ChemicalCategory
//  • NutritionalCheckDetail
//  • PackagingIntegrityDetail
//  • VisualInspectionDetail
//  • WeightCheckDetail
//  • CertificationAuditDetail + AuditType / NonConformity / NonConformitySeverity
//  • GenericCheckDetail
//

internal import Foundation

// MARK: - TomapoQualityCheck

struct TomapoQualityCheck: Codable, Identifiable {
    let id: String
    let type: QualityCheckType
    let status: QualityCheckStatus
    let performedAt: Date?
    let performedBy: String?
    let accreditationNumber: String?
    let reportNumber: String?
    let resultSummary: String?
    let detail: QualityCheckDetail
    let nextCheckDue: Date?
    let isMandatory: Bool

    enum CodingKeys: String, CodingKey {
        case id, type, status, detail
        case performedAt         = "performed_at"
        case performedBy         = "performed_by"
        case accreditationNumber = "accreditation_number"
        case reportNumber        = "report_number"
        case resultSummary       = "result_summary"
        case nextCheckDue        = "next_check_due"
        case isMandatory         = "is_mandatory"
    }
}

// MARK: - QualityCheckType

enum QualityCheckType: String, Codable, CaseIterable {
    // Sensorisch / Physisch
    case visualInspection     = "visual_inspection"
    case weightCheck          = "weight_check"
    case sizeGrading          = "size_grading"
    case colorCheck           = "color_check"
    case textureCheck         = "texture_check"
    case odorCheck            = "odor_check"
    // Temperatur & Kühlkette
    case temperatureLog       = "temperature_log"
    case coldChainVerification = "cold_chain_verification"
    case thermalMapping       = "thermal_mapping"
    // Mikrobiologie
    case microbiologicalTest  = "microbiological_test"
    case salmonellaTest       = "salmonella_test"
    case listeriaTest         = "listeria_test"
    case eColiTest            = "e_coli_test"
    case hygieneSurfaceSwab   = "hygiene_surface_swab"
    case waterQualityTest     = "water_quality_test"
    // Chemisch
    case pesticideResidue     = "pesticide_residue"
    case heavyMetalTest       = "heavy_metal_test"
    case mycotoxinTest        = "mycotoxin_test"
    case allergenTest         = "allergen_test"
    case antibioticTest       = "antibiotic_test"
    case hormonTest           = "hormon_test"
    case additivesCheck       = "additives_check"
    case nitrateTest          = "nitrate_test"
    // Nährwert
    case nutritionAnalysis    = "nutrition_analysis"
    case moistureContent      = "moisture_content"
    case fatContent           = "fat_content"
    case proteinContent       = "protein_content"
    case sugarContent         = "sugar_content"
    // Verpackung & Kennzeichnung
    case packagingIntegrity   = "packaging_integrity"
    case labelingCompliance   = "labeling_compliance"
    case barcodeVerification  = "barcode_verification"
    case weightFilling        = "weight_filling"
    case sealIntegrity        = "seal_integrity"
    // Umwelt & Nachhaltigkeit
    case carbonFootprintAudit = "carbon_footprint_audit"
    case organicCertCheck     = "organic_cert_check"
    case fairTradeAudit       = "fair_trade_audit"
    case animalWelfareCheck   = "animal_welfare_check"
    // Behördlich
    case veterinaryInspection = "veterinary_inspection"
    case customsInspection    = "customs_inspection"
    case importControl        = "import_control"
    case haccp                = "haccp_audit"
    case foodSafetyAudit      = "food_safety_audit"
    case other                = "other"
}

// MARK: - QualityCheckStatus

enum QualityCheckStatus: String, Codable {
    case passed        = "passed"
    case failed        = "failed"
    case warning       = "warning"
    case pending       = "pending"
    case inProgress    = "in_progress"
    case notApplicable = "not_applicable"
    case unknown       = "unknown"
}

// MARK: - QualityCheckDetail

enum QualityCheckDetail: Codable {
    case temperature(TemperatureCheckDetail)
    case microbiological(MicrobiologicalCheckDetail)
    case chemical(ChemicalCheckDetail)
    case nutritional(NutritionalCheckDetail)
    case packaging(PackagingIntegrityDetail)
    case visual(VisualInspectionDetail)
    case weight(WeightCheckDetail)
    case certification(CertificationAuditDetail)
    case generic(GenericCheckDetail)

    enum CodingKeys: String, CodingKey { case type, data }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "temperature":    self = .temperature(try c.decode(TemperatureCheckDetail.self,     forKey: .data))
        case "microbiological":self = .microbiological(try c.decode(MicrobiologicalCheckDetail.self, forKey: .data))
        case "chemical":       self = .chemical(try c.decode(ChemicalCheckDetail.self,           forKey: .data))
        case "nutritional":    self = .nutritional(try c.decode(NutritionalCheckDetail.self,     forKey: .data))
        case "packaging":      self = .packaging(try c.decode(PackagingIntegrityDetail.self,     forKey: .data))
        case "visual":         self = .visual(try c.decode(VisualInspectionDetail.self,          forKey: .data))
        case "weight":         self = .weight(try c.decode(WeightCheckDetail.self,               forKey: .data))
        case "certification":  self = .certification(try c.decode(CertificationAuditDetail.self, forKey: .data))
        default:               self = .generic(try c.decode(GenericCheckDetail.self,             forKey: .data))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .temperature(let d):    try c.encode("temperature",    forKey: .type); try c.encode(d, forKey: .data)
        case .microbiological(let d):try c.encode("microbiological",forKey: .type); try c.encode(d, forKey: .data)
        case .chemical(let d):       try c.encode("chemical",       forKey: .type); try c.encode(d, forKey: .data)
        case .nutritional(let d):    try c.encode("nutritional",    forKey: .type); try c.encode(d, forKey: .data)
        case .packaging(let d):      try c.encode("packaging",      forKey: .type); try c.encode(d, forKey: .data)
        case .visual(let d):         try c.encode("visual",         forKey: .type); try c.encode(d, forKey: .data)
        case .weight(let d):         try c.encode("weight",         forKey: .type); try c.encode(d, forKey: .data)
        case .certification(let d):  try c.encode("certification",  forKey: .type); try c.encode(d, forKey: .data)
        case .generic(let d):        try c.encode("generic",        forKey: .type); try c.encode(d, forKey: .data)
        }
    }
}

// MARK: - TemperatureCheckDetail

struct TemperatureCheckDetail: Codable {
    let measuredCelsius: Double
    let minAllowedCelsius: Double
    let maxAllowedCelsius: Double
    let isWithinRange: Bool
    let sensorId: String?
    let log: [SensorReading]   // SensorReading aus TomapoColdChain.swift

    enum CodingKeys: String, CodingKey {
        case measuredCelsius   = "measured_celsius"
        case minAllowedCelsius = "min_allowed_celsius"
        case maxAllowedCelsius = "max_allowed_celsius"
        case isWithinRange     = "is_within_range"
        case sensorId          = "sensor_id"
        case log
    }
}

// MARK: - MicrobiologicalCheckDetail

struct MicrobiologicalCheckDetail: Codable {
    let pathogensTested: [PathogenResult]
    let totalBacterialCount: BacterialCountResult?
    let laboratoryName: String?
    let iso17025Accredited: Bool

    enum CodingKeys: String, CodingKey {
        case pathogensTested     = "pathogens_tested"
        case totalBacterialCount = "total_bacterial_count"
        case laboratoryName      = "laboratory_name"
        case iso17025Accredited  = "iso_17025_accredited"
    }
}

struct PathogenResult: Codable {
    let pathogen: String
    let detected: Bool
    let cfu: Double?
    let limit: Double?
    let limitExceeded: Bool

    enum CodingKeys: String, CodingKey {
        case pathogen, detected, cfu, limit
        case limitExceeded = "limit_exceeded"
    }
}

struct BacterialCountResult: Codable {
    let totalCfu: Double
    let acceptableLimit: Double
    let isAcceptable: Bool

    enum CodingKeys: String, CodingKey {
        case totalCfu        = "total_cfu"
        case acceptableLimit = "acceptable_limit"
        case isAcceptable    = "is_acceptable"
    }
}

// MARK: - ChemicalCheckDetail

struct ChemicalCheckDetail: Codable {
    let substancesTested: [ChemicalSubstanceResult]
    let laboratoryName: String?
    let testMethod: String?

    enum CodingKeys: String, CodingKey {
        case substancesTested = "substances_tested"
        case laboratoryName   = "laboratory_name"
        case testMethod       = "test_method"
    }
}

struct ChemicalSubstanceResult: Codable {
    let substance: String
    let category: ChemicalCategory
    let measuredMgPerKg: Double?
    let limitMgPerKg: Double?
    let limitExceeded: Bool
    let unit: String

    enum CodingKeys: String, CodingKey {
        case substance, category, unit
        case measuredMgPerKg = "measured_mg_per_kg"
        case limitMgPerKg    = "limit_mg_per_kg"
        case limitExceeded   = "limit_exceeded"
    }
}

/// Chemikalienkategorie für ChemicalCheckDetail (nicht zu verwechseln
/// mit ChemicalResiduCategory aus TomapoStationDetailsProcessing.swift)
enum ChemicalCategory: String, Codable {
    case pesticide   = "pesticide"
    case heavyMetal  = "heavy_metal"
    case mycotoxin   = "mycotoxin"
    case antibiotic  = "antibiotic"
    case hormone     = "hormone"
    case nitrate     = "nitrate"
    case additive    = "additive"
    case allergen    = "allergen"
    case contaminant = "contaminant"
    case other       = "other"
}

// MARK: - NutritionalCheckDetail

struct NutritionalCheckDetail: Codable {
    let energyKcal: Double?
    let fatG: Double?
    let saturatedFatG: Double?
    let carbohydratesG: Double?
    let sugarsG: Double?
    let fiberG: Double?
    let proteinsG: Double?
    let saltG: Double?
    let deviationFromLabelPercent: Double?
    let deviationAcceptable: Bool

    enum CodingKeys: String, CodingKey {
        case energyKcal                = "energy_kcal"
        case fatG                      = "fat_g"
        case saturatedFatG             = "saturated_fat_g"
        case carbohydratesG            = "carbohydrates_g"
        case sugarsG                   = "sugars_g"
        case fiberG                    = "fiber_g"
        case proteinsG                 = "proteins_g"
        case saltG                     = "salt_g"
        case deviationFromLabelPercent = "deviation_from_label_percent"
        case deviationAcceptable       = "deviation_acceptable"
    }
}

// MARK: - PackagingIntegrityDetail

struct PackagingIntegrityDetail: Codable {
    let isSealed: Bool
    let isLeaking: Bool
    let vacuumIntact: Bool?
    let mapGasCompositionCorrect: Bool?
    let labelingCorrect: Bool
    let barcodeReadable: Bool
    let fillWeightCorrect: Bool
    let defectsFound: [String]

    enum CodingKeys: String, CodingKey {
        case isSealed                 = "is_sealed"
        case isLeaking                = "is_leaking"
        case vacuumIntact             = "vacuum_intact"
        case mapGasCompositionCorrect = "map_gas_composition_correct"
        case labelingCorrect          = "labeling_correct"
        case barcodeReadable          = "barcode_readable"
        case fillWeightCorrect        = "fill_weight_correct"
        case defectsFound             = "defects_found"
    }
}

// MARK: - VisualInspectionDetail

struct VisualInspectionDetail: Codable {
    let colorOk: Bool
    let shapeOk: Bool
    let surfaceOk: Bool
    let moldDetected: Bool
    let foreignBodyDetected: Bool
    let gradeAssigned: String?
    let rejectionRate: Double?
    let defectsFound: [String]

    enum CodingKeys: String, CodingKey {
        case colorOk             = "color_ok"
        case shapeOk             = "shape_ok"
        case surfaceOk           = "surface_ok"
        case moldDetected        = "mold_detected"
        case foreignBodyDetected = "foreign_body_detected"
        case gradeAssigned       = "grade_assigned"
        case rejectionRate       = "rejection_rate"
        case defectsFound        = "defects_found"
    }
}

// MARK: - WeightCheckDetail

struct WeightCheckDetail: Codable {
    let targetWeightG: Double
    let measuredWeightG: Double
    let tolerancePercent: Double
    let isWithinTolerance: Bool
    let sampleSize: Int

    enum CodingKeys: String, CodingKey {
        case targetWeightG    = "target_weight_g"
        case measuredWeightG  = "measured_weight_g"
        case tolerancePercent = "tolerance_percent"
        case isWithinTolerance = "is_within_tolerance"
        case sampleSize       = "sample_size"
    }
}

// MARK: - CertificationAuditDetail

struct CertificationAuditDetail: Codable {
    let certificationBody: String
    let standardAudited: String
    let auditType: AuditType
    let score: Double?
    let nonConformities: [NonConformity]
    let nextAuditDate: Date?
    let certificateValidUntil: Date?

    enum CodingKeys: String, CodingKey {
        case certificationBody     = "certification_body"
        case standardAudited       = "standard_audited"
        case auditType             = "audit_type"
        case score
        case nonConformities       = "non_conformities"
        case nextAuditDate         = "next_audit_date"
        case certificateValidUntil = "certificate_valid_until"
    }
}

enum AuditType: String, Codable {
    case announced   = "announced"
    case unannounced = "unannounced"
    case remote      = "remote"
    case documentary = "documentary"
}

struct NonConformity: Codable {
    let severity: NonConformitySeverity
    let description: String
    let correctionDeadline: Date?
    let corrected: Bool

    enum CodingKeys: String, CodingKey {
        case severity, description, corrected
        case correctionDeadline = "correction_deadline"
    }
}

enum NonConformitySeverity: String, Codable {
    case critical = "critical"
    case major    = "major"
    case minor    = "minor"
}

// MARK: - GenericCheckDetail

struct GenericCheckDetail: Codable {
    let description: String?
    let measuredValue: String?
    let expectedValue: String?
    let unit: String?

    enum CodingKeys: String, CodingKey {
        case description
        case measuredValue = "measured_value"
        case expectedValue = "expected_value"
        case unit
    }
}
