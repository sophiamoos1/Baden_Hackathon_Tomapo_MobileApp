//
//  TomapoStationDetailsProcessing.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  TomapoStationDetailsProcessing.swift
//  WheresMyTomato
//
//  Detail-Structs für Verpackung, Lagerung, Transport, Distribution,
//  Retail und Labor.
//
//  Typen:
//  • PackagingDetail      + PackagingMaterialDetail / ModifiedAtmosphereDetail
//  • StorageDetail        + StorageFacilityType / LightCondition / RipeningDetail / RipeningMethod
//  • TransportDetail      + TransportMode / FuelType
//  • DistributionDetail   + DistributionCenterType
//  • RetailDetail         + RetailDisplayType
//  • LaboratoryDetail     + LaboratoryType / SamplingMethod / LaboratoryTestMethod
//                         + AnalyticalTechnique / MicrobiologicalResult / MicrobiologicalStatus
//                         + ChemicalResiduResult / ChemicalResiduCategory / ResiduStatus
//                         + MeasuredNutritionalValues / PhysicalTestResult / PhysicalParameter
//                         + AllergenTestResult / AllergenTestMethod
//                         + AuthenticityTestResult / AuthenticityTestType
//                         + LaboratoryVerdict / LaboratoryRecommendation
//

internal import Foundation

// MARK: ── PACKAGING ───────────────────────────────────────────────────────────

struct PackagingDetail: Codable {
    let facilityName: String?
    let materials: [PackagingMaterialDetail]
    let modifiedAtmosphere: ModifiedAtmosphereDetail?
    let isVacuumPacked: Bool
    let isRecyclable: Bool
    let totalPackagingWeightGrams: Double?
    let labelLanguages: [String]
    let expirationDate: Date?
    let batchCodeOnPackaging: String?

    enum CodingKeys: String, CodingKey {
        case facilityName              = "facility_name"
        case materials
        case modifiedAtmosphere        = "modified_atmosphere"
        case isVacuumPacked            = "is_vacuum_packed"
        case isRecyclable              = "is_recyclable"
        case totalPackagingWeightGrams = "total_packaging_weight_grams"
        case labelLanguages            = "label_languages"
        case expirationDate            = "expiration_date"
        case batchCodeOnPackaging      = "batch_code_on_packaging"
    }
}

struct PackagingMaterialDetail: Codable {
    let material: String
    let shape: String?
    let weightGrams: Double?
    let isRecyclable: Bool
    let recyclingCode: String?
    let isFoodContact: Bool

    enum CodingKeys: String, CodingKey {
        case material, shape
        case weightGrams   = "weight_grams"
        case isRecyclable  = "is_recyclable"
        case recyclingCode = "recycling_code"
        case isFoodContact = "is_food_contact"
    }
}

struct ModifiedAtmosphereDetail: Codable {
    let oxygenPercent: Double?
    let co2Percent: Double?
    let nitrogenPercent: Double?

    enum CodingKeys: String, CodingKey {
        case oxygenPercent   = "oxygen_percent"
        case co2Percent      = "co2_percent"
        case nitrogenPercent = "nitrogen_percent"
    }
}

// MARK: ── STORAGE ─────────────────────────────────────────────────────────────

struct StorageDetail: Codable {
    let facilityName: String?
    let facilityType: StorageFacilityType
    let storageDurationHours: Double?
    let averageTemperatureCelsius: Double?
    let humidityPercent: Double?
    let lightCondition: LightCondition?
    let maxDurationExceeded: Bool
    let ripeningDetail: RipeningDetail?

    enum CodingKeys: String, CodingKey {
        case facilityName              = "facility_name"
        case facilityType              = "facility_type"
        case storageDurationHours      = "storage_duration_hours"
        case averageTemperatureCelsius = "average_temperature_celsius"
        case humidityPercent           = "humidity_percent"
        case lightCondition            = "light_condition"
        case maxDurationExceeded       = "max_duration_exceeded"
        case ripeningDetail            = "ripening_detail"
    }
}

enum StorageFacilityType: String, Codable {
    case warehouse    = "warehouse"
    case coldStore    = "cold_store"
    case freezer      = "freezer"
    case ripeningCave = "ripening_cave"
    case silo         = "silo"
    case winery       = "winery"
    case unknown      = "unknown"
}

enum LightCondition: String, Codable {
    case dark         = "dark"
    case dim          = "dim"
    case normal       = "normal"
    case uvProtected  = "uv_protected"
}

struct RipeningDetail: Codable {
    let ripeningMethod: RipeningMethod
    let targetDurationDays: Int?
    let actualDurationDays: Int?
    let ripeningAgentUsed: String?

    enum CodingKeys: String, CodingKey {
        case ripeningMethod     = "ripening_method"
        case targetDurationDays = "target_duration_days"
        case actualDurationDays = "actual_duration_days"
        case ripeningAgentUsed  = "ripening_agent_used"
    }
}

enum RipeningMethod: String, Codable {
    case natural    = "natural"
    case controlled = "controlled_atmosphere"
    case ethylene   = "ethylene_gas"
    case cave       = "cave_aged"
    case smoked     = "smoked"
    case brined     = "brined"
    case unknown    = "unknown"
}

// MARK: ── TRANSPORT ───────────────────────────────────────────────────────────

struct TransportDetail: Codable {
    let mode: TransportMode
    let carrierName: String?
    let trackingId: String?
    let originLocation: TomapoLocation?
    let destinationLocation: TomapoLocation?
    let distanceKm: Double?
    let isRefrigerated: Bool
    let coldStorageDetail: ColdStorageDetail?
    let co2EmissionsKg: Double?
    let vehicleType: String?
    let fuelType: FuelType?
    let scheduledArrival: Date?
    let actualArrival: Date?
    let delayReasons: [String]

    enum CodingKeys: String, CodingKey {
        case mode
        case carrierName         = "carrier_name"
        case trackingId          = "tracking_id"
        case originLocation      = "origin_location"
        case destinationLocation = "destination_location"
        case distanceKm          = "distance_km"
        case isRefrigerated      = "is_refrigerated"
        case coldStorageDetail   = "cold_storage_detail"
        case co2EmissionsKg      = "co2_emissions_kg"
        case vehicleType         = "vehicle_type"
        case fuelType            = "fuel_type"
        case scheduledArrival    = "scheduled_arrival"
        case actualArrival       = "actual_arrival"
        case delayReasons        = "delay_reasons"
    }
}

enum TransportMode: String, Codable {
    case truck             = "truck"
    case refrigeratedTruck = "refrigerated_truck"
    case train             = "train"
    case refrigeratedTrain = "refrigerated_train"
    case ship              = "ship"
    case refrigeratedShip  = "refrigerated_ship"
    case airplane          = "airplane"
    case van               = "van"
    case bicycle           = "bicycle"
    case drone             = "drone"
    case pipeline          = "pipeline"
    case unknown           = "unknown"
}

enum FuelType: String, Codable {
    case diesel       = "diesel"
    case petrol       = "petrol"
    case electric     = "electric"
    case hydrogen     = "hydrogen"
    case lng          = "lng"
    case hvo          = "hvo"
    case biodiesel    = "biodiesel"
    case kerosene     = "kerosene"
    case heavyFuelOil = "heavy_fuel_oil"
    case unknown      = "unknown"
}

// MARK: ── DISTRIBUTION ────────────────────────────────────────────────────────

struct DistributionDetail: Codable {
    let centerName: String?
    let centerType: DistributionCenterType
    let inboundDate: Date?
    let outboundDate: Date?
    let handlingCount: Int?
    let customsCleared: Bool
    let customsClearanceDate: Date?
    let importInspectionPassed: Bool?
    let inspectedBy: String?

    enum CodingKeys: String, CodingKey {
        case centerName             = "center_name"
        case centerType             = "center_type"
        case inboundDate            = "inbound_date"
        case outboundDate           = "outbound_date"
        case handlingCount          = "handling_count"
        case customsCleared         = "customs_cleared"
        case customsClearanceDate   = "customs_clearance_date"
        case importInspectionPassed = "import_inspection_passed"
        case inspectedBy            = "inspected_by"
    }
}

enum DistributionCenterType: String, Codable {
    case regional  = "regional_dc"
    case national  = "national_dc"
    case crossDock = "cross_dock"
    case hub       = "hub"
    case port      = "port"
    case airport   = "airport"
    case customs   = "customs_facility"
    case unknown   = "unknown"
}

// MARK: ── RETAIL ──────────────────────────────────────────────────────────────

struct RetailDetail: Codable {
    let storeName: String?
    let storeChain: String?
    let storeGln: String?
    let displayType: RetailDisplayType
    let displayTemperatureCelsius: Double?
    let firstOnShelfDate: Date?
    let bestBeforeDate: Date?
    let priceChf: Double?

    enum CodingKeys: String, CodingKey {
        case storeName                 = "store_name"
        case storeChain                = "store_chain"
        case storeGln                  = "store_gln"
        case displayType               = "display_type"
        case displayTemperatureCelsius = "display_temperature_celsius"
        case firstOnShelfDate          = "first_on_shelf_date"
        case bestBeforeDate            = "best_before_date"
        case priceChf                  = "price_chf"
    }
}

enum RetailDisplayType: String, Codable {
    case ambient     = "ambient"
    case chilled     = "chilled"
    case frozen      = "frozen"
    case bakery      = "bakery"
    case meatCounter = "meat_counter"
    case fishCounter = "fish_counter"
    case unknown     = "unknown"
}

// MARK: ── LABORATORY ──────────────────────────────────────────────────────────

struct LaboratoryDetail: Codable {

    // MARK: Labor-Identität
    let laboratoryName: String?
    let accreditationNumber: String?
    let accreditationBody: String?
    let isIso17025Accredited: Bool
    let laboratoryType: LaboratoryType
    let location: TomapoLocation?

    // MARK: Auftrag & Probe
    let sampleId: String?
    let samplingMethod: SamplingMethod
    let sampledBy: String?
    let sampledAt: Date?
    let sampleWeightGrams: Double?
    let sampleMatrix: String?
    let batchId: String?
    let sampleTransportedCooled: Bool
    let sampleArrivalTemperatureCelsius: Double?
    let sampleReceivedAt: Date?
    let analysisStartedAt: Date?
    let analysisCompletedAt: Date?

    // MARK: Analysemethoden & Ergebnisse
    let testMethods: [LaboratoryTestMethod]
    let microbiologicalResults: [MicrobiologicalResult]
    let chemicalResults: [ChemicalResiduResult]
    let nutritionalAnalysis: MeasuredNutritionalValues?
    let physicalResults: [PhysicalTestResult]
    let allergenResults: [AllergenTestResult]
    let authenticityResults: [AuthenticityTestResult]

    // MARK: Gesamtbewertung
    let overallVerdict: LaboratoryVerdict
    let legalLimitsExceeded: Bool
    let exceedanceCount: Int
    let recommendation: LaboratoryRecommendation?
    let reportNumber: String?
    let reportUrl: String?
    let signedBy: String?
    let reportIssuedAt: Date?

    enum CodingKeys: String, CodingKey {
        case laboratoryName                  = "laboratory_name"
        case accreditationNumber             = "accreditation_number"
        case accreditationBody               = "accreditation_body"
        case isIso17025Accredited            = "is_iso_17025_accredited"
        case laboratoryType                  = "laboratory_type"
        case location
        case sampleId                        = "sample_id"
        case samplingMethod                  = "sampling_method"
        case sampledBy                       = "sampled_by"
        case sampledAt                       = "sampled_at"
        case sampleWeightGrams               = "sample_weight_grams"
        case sampleMatrix                    = "sample_matrix"
        case batchId                         = "batch_id"
        case sampleTransportedCooled         = "sample_transported_cooled"
        case sampleArrivalTemperatureCelsius = "sample_arrival_temperature_celsius"
        case sampleReceivedAt                = "sample_received_at"
        case analysisStartedAt               = "analysis_started_at"
        case analysisCompletedAt             = "analysis_completed_at"
        case testMethods                     = "test_methods"
        case microbiologicalResults          = "microbiological_results"
        case chemicalResults                 = "chemical_results"
        case nutritionalAnalysis             = "nutritional_analysis"
        case physicalResults                 = "physical_results"
        case allergenResults                 = "allergen_results"
        case authenticityResults             = "authenticity_results"
        case overallVerdict                  = "overall_verdict"
        case legalLimitsExceeded             = "legal_limits_exceeded"
        case exceedanceCount                 = "exceedance_count"
        case recommendation
        case reportNumber                    = "report_number"
        case reportUrl                       = "report_url"
        case signedBy                        = "signed_by"
        case reportIssuedAt                  = "report_issued_at"
    }
}

// MARK: - Labor-Enums

enum LaboratoryType: String, Codable {
    case internalManufacturer = "internal_manufacturer"
    case externalIndependent  = "external_independent"
    case governmentOfficial   = "government_official"
    case universityResearch   = "university_research"
    case certificationBody    = "certification_body"
}

enum SamplingMethod: String, Codable {
    case random          = "random"
    case representative  = "representative"
    case composite       = "composite"
    case targeted        = "targeted"
    case officialControl = "official_control"
    case selfMonitoring  = "self_monitoring"
    case continuous      = "continuous"
    case unknown         = "unknown"
}

struct LaboratoryTestMethod: Codable {
    let standardName: String
    let technique: AnalyticalTechnique
    let targetParameter: String
    let detectionLimitValue: Double?
    let detectionLimitUnit: String?

    enum CodingKeys: String, CodingKey {
        case standardName        = "standard_name"
        case technique
        case targetParameter     = "target_parameter"
        case detectionLimitValue = "detection_limit_value"
        case detectionLimitUnit  = "detection_limit_unit"
    }
}

enum AnalyticalTechnique: String, Codable {
    case gcMs          = "gc_ms"
    case lcMsMs        = "lc_ms_ms"
    case hplc          = "hplc"
    case gfaas         = "gfaas"
    case icpMs         = "icp_ms"
    case culturePlating = "culture_plating"
    case pcr           = "pcr"
    case realTimePcr   = "real_time_pcr"
    case elisa         = "elisa"
    case flowCytometry = "flow_cytometry"
    case nirs          = "nirs"
    case nmr           = "nmr"
    case xrf           = "xrf"
    case turbidimetry  = "turbidimetry"
    case sensoryPanel  = "sensory_panel"
    case texture       = "texture_analysis"
    case colorimetry   = "colorimetry"
    case dnaFingerprint = "dna_fingerprinting"
    case isotope       = "isotope_ratio_analysis"
    case other         = "other"
}

// MARK: - Microbiologische Ergebnisse

struct MicrobiologicalResult: Codable {
    let pathogen: String
    let testMethod: String
    let detected: Bool
    let cfuPerGram: Double?
    let euLimitCfuPerGram: Double?
    let limitExceeded: Bool
    let analysisDurationHours: Int?
    let status: MicrobiologicalStatus

    enum CodingKeys: String, CodingKey {
        case pathogen
        case testMethod            = "test_method"
        case detected
        case cfuPerGram            = "cfu_per_gram"
        case euLimitCfuPerGram     = "eu_limit_cfu_per_gram"
        case limitExceeded         = "limit_exceeded"
        case analysisDurationHours = "analysis_duration_hours"
        case status
    }
}

enum MicrobiologicalStatus: String, Codable {
    case satisfactory   = "satisfactory"
    case acceptable     = "acceptable"
    case unsatisfactory = "unsatisfactory"
    case unsafe         = "unsafe"
}

// MARK: - Chemische Rückstandsanalyse

struct ChemicalResiduResult: Codable {
    let substanceName: String
    let category: ChemicalResiduCategory
    let measuredValue: Double?
    let unit: String
    let mrlValue: Double?
    let mrlUnit: String?
    let mrlExceeded: Bool
    let method: String?
    let loqValue: Double?
    let lodValue: Double?
    let belowLod: Bool
    let status: ResiduStatus

    enum CodingKeys: String, CodingKey {
        case substanceName = "substance_name"
        case category
        case measuredValue = "measured_value"
        case unit
        case mrlValue      = "mrl_value"
        case mrlUnit       = "mrl_unit"
        case mrlExceeded   = "mrl_exceeded"
        case method
        case loqValue      = "loq_value"
        case lodValue      = "lod_value"
        case belowLod      = "below_lod"
        case status
    }
}

enum ChemicalResiduCategory: String, Codable {
    case pesticide               = "pesticide"
    case herbicide               = "herbicide"
    case fungicide               = "fungicide"
    case insecticide             = "insecticide"
    case heavyMetal              = "heavy_metal"
    case mycotoxin               = "mycotoxin"
    case antibiotic              = "antibiotic"
    case hormone                 = "hormone"
    case nitrate                 = "nitrate"
    case dioxin                  = "dioxin"
    case pah                     = "pah"
    case plasticizer             = "plasticizer"
    case processingContaminant   = "processing_contaminant"
    case environmentalContaminant = "environmental_contaminant"
    case additive                = "additive"
    case other                   = "other"
}

enum ResiduStatus: String, Codable {
    case notDetected = "not_detected"
    case detected    = "detected"
    case mrlExceeded = "mrl_exceeded"
    case criticalLevel = "critical_level"
}

// MARK: - Nährwertanalyse (gemessen)

struct MeasuredNutritionalValues: Codable {
    let energyKcal: Double?
    let fatG: Double?
    let saturatedFatG: Double?
    let carbohydratesG: Double?
    let sugarsG: Double?
    let fiberG: Double?
    let proteinsG: Double?
    let saltG: Double?
    let moisturePercent: Double?
    let ashG: Double?
    let deviationFromDeclarationPercent: Double?
    let isWithinEuTolerance: Bool

    enum CodingKeys: String, CodingKey {
        case energyKcal                      = "energy_kcal"
        case fatG                            = "fat_g"
        case saturatedFatG                   = "saturated_fat_g"
        case carbohydratesG                  = "carbohydrates_g"
        case sugarsG                         = "sugars_g"
        case fiberG                          = "fiber_g"
        case proteinsG                       = "proteins_g"
        case saltG                           = "salt_g"
        case moisturePercent                 = "moisture_percent"
        case ashG                            = "ash_g"
        case deviationFromDeclarationPercent = "deviation_from_declaration_percent"
        case isWithinEuTolerance             = "is_within_eu_tolerance"
    }
}

// MARK: - Physikalische Prüfergebnisse

struct PhysicalTestResult: Codable {
    let parameter: PhysicalParameter
    let measuredValue: Double
    let unit: String
    let minAllowed: Double?
    let maxAllowed: Double?
    let isWithinSpec: Bool
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case parameter, unit, notes
        case measuredValue = "measured_value"
        case minAllowed    = "min_allowed"
        case maxAllowed    = "max_allowed"
        case isWithinSpec  = "is_within_spec"
    }
}

enum PhysicalParameter: String, Codable {
    case phValue      = "ph_value"
    case waterActivity = "water_activity"
    case brix         = "brix"
    case viscosity    = "viscosity"
    case turbidity    = "turbidity"
    case colorL       = "color_l"
    case colorA       = "color_a"
    case colorB       = "color_b"
    case hardness     = "hardness"
    case particleSize = "particle_size"
    case density      = "density"
    case fillWeight   = "fill_weight"
    case headspace    = "headspace"
    case foreignBodies = "foreign_bodies"
    case other        = "other"
}

// MARK: - Allergen-Tests

struct AllergenTestResult: Codable {
    let allergen: String
    let isEuMajorAllergen: Bool
    let method: AllergenTestMethod
    let detected: Bool
    let measuredMgPerKg: Double?
    let declarationThresholdMgPerKg: Double?
    let declarationRequired: Bool
    let declarationOnLabelCorrect: Bool

    enum CodingKeys: String, CodingKey {
        case allergen, method, detected
        case isEuMajorAllergen           = "is_eu_major_allergen"
        case measuredMgPerKg             = "measured_mg_per_kg"
        case declarationThresholdMgPerKg = "declaration_threshold_mg_per_kg"
        case declarationRequired         = "declaration_required"
        case declarationOnLabelCorrect   = "declaration_on_label_correct"
    }
}

enum AllergenTestMethod: String, Codable {
    case elisa      = "elisa"
    case pcr        = "pcr"
    case lcMsMs     = "lc_ms_ms"
    case lateralFlow = "lateral_flow"
    case other      = "other"
}

// MARK: - Authentizitäts-Tests

struct AuthenticityTestResult: Codable {
    let testType: AuthenticityTestType
    let claim: String
    let isAuthentic: Bool
    let method: String?
    let confidencePercent: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case testType          = "test_type"
        case claim
        case isAuthentic       = "is_authentic"
        case method
        case confidencePercent = "confidence_percent"
        case notes
    }
}

enum AuthenticityTestType: String, Codable {
    case geographicOrigin    = "geographic_origin"
    case organicStatus       = "organic_status"
    case speciesId           = "species_id"
    case adulteration        = "adulteration"
    case varietyId           = "variety_id"
    case vintageCertification = "vintage_certification"
    case productionMethod    = "production_method"
    case other               = "other"
}

// MARK: - Labor-Gesamtbewertung

enum LaboratoryVerdict: String, Codable {
    case compliant       = "compliant"
    case minorDeviation  = "minor_deviation"
    case majorDeviation  = "major_deviation"
    case nonCompliant    = "non_compliant"
    case unsafe          = "unsafe"
    case pending         = "pending"
}

enum LaboratoryRecommendation: String, Codable {
    case releaseProduct            = "release_product"
    case releaseWithRemarks        = "release_with_remarks"
    case holdPendingInvestigation  = "hold_pending_investigation"
    case recallBatch               = "recall_batch"
    case destroyProduct            = "destroy_product"
    case furtherTesting            = "further_testing"
    case notifyAuthorities         = "notify_authorities"
}
