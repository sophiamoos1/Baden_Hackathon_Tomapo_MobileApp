//
//  TomapoStationDetailsPrimary.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  TomapoStationDetailsPrimary.swift
//  WheresMyTomato
//
//  Detail-Structs für Primärproduktion und erste Verarbeitung.
//  Verwendet in TomapoStationDetail (TomapoStation.swift).
//
//  Typen:
//  • FarmingDetail    + FarmingMethod / HusbandrySystem / FertilizerType / IrrigationType / FieldCoordinate
//  • FishingDetail    + FishingMethod
//  • HarvestDetail    + HarvestMethod
//  • ProcessingDetail + ProcessType / PasteurizationDetail / PasteurizationMethod
//                     + SterilizationDetail / FoodSafetyStandard
//

internal import Foundation

// MARK: ── FARMING ─────────────────────────────────────────────────────────────

struct FarmingDetail: Codable {
    let farmName: String?
    let farmingMethod: FarmingMethod
    let cropYear: Int?
    let animalSpecies: String?
    let husbandrySystem: HusbandrySystem?
    let areaHectares: Double?
    let fertilizerTypes: [FertilizerType]
    let pesticideTypes: [String]
    let fieldCoordinates: [FieldCoordinate]
    let irrigationType: IrrigationType?
    let soilType: String?
    let plantingDate: Date?
    let expectedHarvestStart: Date?
    let expectedHarvestEnd: Date?

    enum CodingKeys: String, CodingKey {
        case farmName             = "farm_name"
        case farmingMethod        = "farming_method"
        case cropYear             = "crop_year"
        case animalSpecies        = "animal_species"
        case husbandrySystem      = "husbandry_system"
        case areaHectares         = "area_hectares"
        case fertilizerTypes      = "fertilizer_types"
        case pesticideTypes       = "pesticide_types"
        case fieldCoordinates     = "field_coordinates"
        case irrigationType       = "irrigation_type"
        case soilType             = "soil_type"
        case plantingDate         = "planting_date"
        case expectedHarvestStart = "expected_harvest_start"
        case expectedHarvestEnd   = "expected_harvest_end"
    }
}

enum FarmingMethod: String, Codable {
    case organic      = "organic"
    case biodynamic   = "biodynamic"
    case conventional = "conventional"
    case integrated   = "integrated"
    case regenerative = "regenerative"
    case hydroponic   = "hydroponic"
    case aquaponic    = "aquaponic"
    case permaculture = "permaculture"
    case urban        = "urban_farming"
    case unknown      = "unknown"
}

enum HusbandrySystem: String, Codable {
    case freeRange    = "free_range"
    case organic      = "organic"
    case cageFree     = "cage_free"
    case battery      = "battery"
    case pastureRaised = "pasture_raised"
    case aquaculture  = "aquaculture"
    case wildCaught   = "wild_caught"
    case unknown      = "unknown"
}

enum FertilizerType: String, Codable {
    case organic   = "organic"
    case synthetic = "synthetic"
    case compost   = "compost"
    case manure    = "manure"
    case none      = "none"
}

enum IrrigationType: String, Codable {
    case drip      = "drip"
    case sprinkler = "sprinkler"
    case flood     = "flood"
    case rainFed   = "rain_fed"
    case none      = "none"
}

struct FieldCoordinate: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: ── FISHING ─────────────────────────────────────────────────────────────

struct FishingDetail: Codable {
    let method: FishingMethod
    let catchArea: String?       // FAO-Fanggebiet
    let vessel: String?
    let vesselId: String?        // IMO-Nummer
    let catchDate: Date?
    let isMscCertified: Bool
    let isAscCertified: Bool
    let bycatchInfo: String?

    enum CodingKeys: String, CodingKey {
        case method
        case catchArea      = "catch_area"
        case vessel
        case vesselId       = "vessel_id"
        case catchDate      = "catch_date"
        case isMscCertified = "is_msc_certified"
        case isAscCertified = "is_asc_certified"
        case bycatchInfo    = "bycatch_info"
    }
}

enum FishingMethod: String, Codable {
    case wildCaught  = "wild_caught"
    case aquaculture = "aquaculture"
    case lineCaught  = "line_caught"
    case netCaught   = "net_caught"
    case trawl       = "trawl"
    case unknown     = "unknown"
}

// MARK: ── HARVEST ─────────────────────────────────────────────────────────────

struct HarvestDetail: Codable {
    let method: HarvestMethod
    let harvestDate: Date?
    let gradeAfterHarvest: String?
    let yieldPercent: Double?
    let harvestTemperatureCelsius: Double?
    let isManual: Bool
    let workerCount: Int?
    let immediatelyPrecooled: Bool

    enum CodingKeys: String, CodingKey {
        case method
        case harvestDate               = "harvest_date"
        case gradeAfterHarvest         = "grade_after_harvest"
        case yieldPercent              = "yield_percent"
        case harvestTemperatureCelsius = "harvest_temperature_celsius"
        case isManual                  = "is_manual"
        case workerCount               = "worker_count"
        case immediatelyPrecooled      = "immediately_precooled"
    }
}

enum HarvestMethod: String, Codable {
    case manual     = "manual"
    case mechanical = "mechanical"
    case selective  = "selective"
    case slaughter  = "slaughter"
    case milking    = "milking"
    case shearing   = "shearing"
    case unknown    = "unknown"
}

// MARK: ── PROCESSING ──────────────────────────────────────────────────────────

struct ProcessingDetail: Codable {
    let facilityName: String?
    let facilityEmbCode: String?
    let processTypes: [ProcessType]
    let processingTemperatureCelsius: Double?
    let pasteurization: PasteurizationDetail?
    let sterilization: SterilizationDetail?
    let additivesAdded: [String]
    let isHaccpCertified: Bool
    let foodSafetyStandard: FoodSafetyStandard?
    let batchSizeKg: Double?

    enum CodingKeys: String, CodingKey {
        case facilityName                    = "facility_name"
        case facilityEmbCode                 = "facility_emb_code"
        case processTypes                    = "process_types"
        case processingTemperatureCelsius    = "processing_temperature_celsius"
        case pasteurization
        case sterilization
        case additivesAdded                  = "additives_added"
        case isHaccpCertified                = "is_haccp_certified"
        case foodSafetyStandard              = "food_safety_standard"
        case batchSizeKg                     = "batch_size_kg"
    }
}

enum ProcessType: String, Codable {
    case washing        = "washing"
    case peeling        = "peeling"
    case cutting        = "cutting"
    case mixing         = "mixing"
    case cooking        = "cooking"
    case pasteurization = "pasteurization"
    case sterilization  = "sterilization"
    case fermentation   = "fermentation"
    case smoking        = "smoking"
    case salting        = "salting"
    case drying         = "drying"
    case freezing       = "freezing"
    case pressing       = "pressing"
    case extraction     = "extraction"
    case filtration     = "filtration"
    case homogenization = "homogenization"
    case irradiation    = "irradiation"
    case grinding       = "grinding"
    case unknown        = "unknown"
}

struct PasteurizationDetail: Codable {
    let temperatureCelsius: Double
    let durationSeconds: Int
    let method: PasteurizationMethod

    enum CodingKeys: String, CodingKey {
        case temperatureCelsius = "temperature_celsius"
        case durationSeconds    = "duration_seconds"
        case method
    }
}

enum PasteurizationMethod: String, Codable {
    case htst  = "htst"   // 72°C/15s
    case uht   = "uht"    // 135°C/2s
    case ltlt  = "ltlt"   // 63°C/30min
    case flash = "flash"
}

struct SterilizationDetail: Codable {
    let temperatureCelsius: Double
    let durationMinutes: Int
    let method: String?

    enum CodingKeys: String, CodingKey {
        case temperatureCelsius = "temperature_celsius"
        case durationMinutes    = "duration_minutes"
        case method
    }
}

enum FoodSafetyStandard: String, Codable {
    case haccp    = "haccp"
    case ifsFood  = "ifs_food"
    case brcGs2   = "brc_gs2"
    case iso22000 = "iso_22000"
    case sqf      = "sqf"
    case fssc22000 = "fssc_22000"
    case globalGap = "global_gap"
    case unknown  = "unknown"
}
