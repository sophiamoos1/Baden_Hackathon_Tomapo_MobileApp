//
//  TomapoColdChain.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  TomapoColdChain.swift
//  WheresMyTomato
//
//  Typen:
//  • TomapoColdChainSummary  – Aggregiert auf Produktebene (auf TomapoResponse)
//  • ColdStorageDetail       – IoT-Sensorlog für eine einzelne Station
//  • ColdChainBreak          – Einzelne Kühlkettenunterbrechung
//  • SensorReading           – Einzelner Messwert eines IoT-Sensors
//
//  Architektur (3 Ebenen):
//  1. TomapoStation.wasRefrigerated: Bool
//     Schnelles Bool auf jeder Station – für Zeitstrahl in der UI.
//
//  2. ColdStorageDetail (in TomapoStation.detail)
//     Vollständiger IoT-Sensorlog – nur bei .coldStorage / .transport.
//
//  3. TomapoColdChainSummary (auf TomapoResponse)
//     Aggregierte Auswertung über alle Stationen.
//

internal import Foundation

// MARK: - TomapoColdChainSummary

struct TomapoColdChainSummary: Codable {

    let isIntact: Bool
    let refrigeratedStationCount: Int
    let unrefrigeratedStationCount: Int
    let lowestTemperatureCelsius: Double?
    let highestTemperatureCelsius: Double?
    let hadColdChainBreak: Bool
    let coldChainBreakCount: Int
    let totalBreakDurationMinutes: Int?
    let totalRefrigeratedTransportHours: Double?
    /// UI-Kurztext: "Lückenlos · 2 Stationen · max. 6.4°C"
    let summaryText: String?

    enum CodingKeys: String, CodingKey {
        case isIntact                        = "is_intact"
        case refrigeratedStationCount        = "refrigerated_station_count"
        case unrefrigeratedStationCount      = "unrefrigerated_station_count"
        case lowestTemperatureCelsius        = "lowest_temperature_celsius"
        case highestTemperatureCelsius       = "highest_temperature_celsius"
        case hadColdChainBreak               = "had_cold_chain_break"
        case coldChainBreakCount             = "cold_chain_break_count"
        case totalBreakDurationMinutes       = "total_break_duration_minutes"
        case totalRefrigeratedTransportHours = "total_refrigerated_transport_hours"
        case summaryText                     = "summary_text"
    }

    /// Für Produkte die keine Kühlung benötigen
    static var notRequired: TomapoColdChainSummary {
        TomapoColdChainSummary(
            isIntact: true, refrigeratedStationCount: 0,
            unrefrigeratedStationCount: 0, lowestTemperatureCelsius: nil,
            highestTemperatureCelsius: nil, hadColdChainBreak: false,
            coldChainBreakCount: 0, totalBreakDurationMinutes: nil,
            totalRefrigeratedTransportHours: nil,
            summaryText: "No refrigeration required")
    }
}

// MARK: - ColdStorageDetail

struct ColdStorageDetail: Codable {
    let facilityName: String?
    let targetTemperatureCelsius: Double
    let minActualTemperatureCelsius: Double?
    let maxActualTemperatureCelsius: Double?
    let avgActualTemperatureCelsius: Double?
    let coldChainBroken: Bool
    let coldChainBreaks: [ColdChainBreak]
    let sensorId: String?
    let lastSensorReading: SensorReading?

    enum CodingKeys: String, CodingKey {
        case facilityName                = "facility_name"
        case targetTemperatureCelsius    = "target_temperature_celsius"
        case minActualTemperatureCelsius = "min_actual_temperature_celsius"
        case maxActualTemperatureCelsius = "max_actual_temperature_celsius"
        case avgActualTemperatureCelsius = "avg_actual_temperature_celsius"
        case coldChainBroken             = "cold_chain_broken"
        case coldChainBreaks             = "cold_chain_breaks"
        case sensorId                    = "sensor_id"
        case lastSensorReading           = "last_sensor_reading"
    }
}

// MARK: - ColdChainBreak

struct ColdChainBreak: Codable {
    let occurredAt: Date
    let durationMinutes: Int
    let maxTemperatureReached: Double
    let location: String?
    let cause: String?

    enum CodingKeys: String, CodingKey {
        case occurredAt            = "occurred_at"
        case durationMinutes       = "duration_minutes"
        case maxTemperatureReached = "max_temperature_reached"
        case location, cause
    }
}

// MARK: - SensorReading

struct SensorReading: Codable {
    let timestamp: Date
    let temperatureCelsius: Double
    let humidity: Double?
    let isWithinRange: Bool

    enum CodingKeys: String, CodingKey {
        case timestamp
        case temperatureCelsius = "temperature_celsius"
        case humidity
        case isWithinRange      = "is_within_range"
    }
}
