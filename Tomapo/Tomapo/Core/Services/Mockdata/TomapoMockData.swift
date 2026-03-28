//
//  TomapoMockData.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import Foundation
 
// MARK: - Hilfsfunktionen
 
private func d(_ iso: String) -> Date {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f.date(from: iso) ?? Date()
}
private let cal = Calendar.current
private func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: Date())! }
private func hoursAgo(_ n: Int) -> Date { cal.date(byAdding: .hour, value: -n, to: Date())! }
private func inDays(_ n: Int) -> Date { cal.date(byAdding: .day, value: n, to: Date())! }
private func inMonths(_ n: Int) -> Date { cal.date(byAdding: .month, value: n, to: Date())! }
private func uid() -> String { UUID().uuidString }
 
private func loc(
    _ name: String, _ country: String, _ region: String, _ city: String,
    address: String? = nil, lat: Double, lon: Double,
    emb: String? = nil, gln: String? = nil
) -> TomapoLocation {
    TomapoLocation(name: name, country: country, region: region, city: city,
                   address: address, latitude: lat, longitude: lon,
                   embCode: emb, gln: gln)
}
 
private func src(_ items: [(String, String, DataSourceType, DataSourceReliability)]) -> [TomapoDataSource] {
    items.map { TomapoDataSource(id: $0.0, name: $0.1, type: $0.2, lastSynced: Date(), reliability: $0.3) }
}
 
private func tScore(_ c: Double, v: Int, u: Int, gaps: Bool, hash: String? = nil) -> TomapoTraceabilityScore {
    TomapoTraceabilityScore(completeness: c, verifiedStations: v, unknownStations: u,
                            hasGaps: gaps, isThirdPartyVerified: v > 1, blockchainHash: hash)
}
 
// MARK: - SensorReading-Helfer
 
private func sensorLog(_ pairs: [(String, Double, Double?)]) -> [SensorReading] {
    pairs.map { SensorReading(timestamp: d($0.0), temperatureCelsius: $0.1,
                              humidity: $0.2, isWithinRange: true) }
}
 
// MARK: - Qualitätschecks
 
private func qcTempLog(
    sensor: String, target: Double, min: Double, max: Double,
    readings log: [(String, Double, Double?)],
    by performer: String, mandatory: Bool = true
) -> TomapoQualityCheck {
    let sr = log.map {
        SensorReading(timestamp: d($0.0), temperatureCelsius: $0.1, humidity: $0.2,
                      isWithinRange: $0.1 >= min && $0.1 <= max)
    }
    let breaches = sr.filter { !$0.isWithinRange }
    return TomapoQualityCheck(
        id: uid(), type: .temperatureLog,
        status: breaches.isEmpty ? .passed : .warning,
        performedAt: sr.last?.timestamp, performedBy: performer,
        accreditationNumber: nil,
        reportNumber: "TMP-\(Int.random(in: 10000...99999))",
        resultSummary: breaches.isEmpty
            ? "\(sr.count) Messungen – alle im Bereich \(min)–\(max)°C."
            : "⚠ \(breaches.count)/\(sr.count) Messungen ausserhalb.",
        detail: .temperature(TemperatureCheckDetail(
            measuredCelsius: sr.last?.temperatureCelsius ?? target,
            minAllowedCelsius: min, maxAllowedCelsius: max,
            isWithinRange: breaches.isEmpty, sensorId: sensor, log: sr)),
        nextCheckDue: inDays(7), isMandatory: mandatory)
}
 
private func qcMicro(
    pathogens: [(name: String, detected: Bool, cfu: Double?, limit: Double?, method: String, hours: Int)],
    totalCfu: Double, cfulimit: Double, lab: String, accred: String?, report: String,
    mandatory: Bool = true
) -> TomapoQualityCheck {
    let pathRes = pathogens.map {
        PathogenResult(pathogen: $0.name, detected: $0.detected, cfu: $0.cfu,
                       limit: $0.limit, limitExceeded: ($0.cfu ?? 0) > ($0.limit ?? 999999))
    }
    let microRes = pathogens.map {
        MicrobiologicalResult(pathogen: $0.name, testMethod: $0.method,
            detected: $0.detected, cfuPerGram: $0.cfu, euLimitCfuPerGram: $0.limit,
            limitExceeded: ($0.cfu ?? 0) > ($0.limit ?? 999999),
            analysisDurationHours: $0.hours,
            status: $0.detected ? .unsatisfactory : .satisfactory)
    }
    let passed = !pathRes.contains(where: \.limitExceeded) && totalCfu <= cfulimit
    return TomapoQualityCheck(
        id: uid(), type: .microbiologicalTest, status: passed ? .passed : .failed,
        performedAt: daysAgo(2), performedBy: lab,
        accreditationNumber: accred, reportNumber: report,
        resultSummary: passed
            ? "Alle \(pathogens.count) Pathogene n.d. Gesamtkeimzahl \(Int(totalCfu)) KBE/g."
            : "⚠ Grenzwertüberschreitung.",
        detail: .microbiological(MicrobiologicalCheckDetail(
            pathogensTested: pathRes,
            totalBacterialCount: BacterialCountResult(
                totalCfu: totalCfu, acceptableLimit: cfulimit,
                isAcceptable: totalCfu <= cfulimit),
            laboratoryName: lab, iso17025Accredited: accred != nil)),
        nextCheckDue: inMonths(1), isMandatory: mandatory)
}
 
private func qcChem(
    substances: [(name: String, cat: ChemicalCategory, measured: Double?, limit: Double?, unit: String)],
    lab: String, method: String, report: String, mandatory: Bool = false
) -> TomapoQualityCheck {
    let results = substances.map {
        ChemicalSubstanceResult(substance: $0.name, category: $0.cat,
            measuredMgPerKg: $0.measured, limitMgPerKg: $0.limit,
            limitExceeded: ($0.measured ?? 0) > ($0.limit ?? 99999), unit: $0.unit)
    }
    let passed = !results.contains(where: \.limitExceeded)
    return TomapoQualityCheck(
        id: uid(), type: .pesticideResidue, status: passed ? .passed : .failed,
        performedAt: daysAgo(5), performedBy: lab,
        accreditationNumber: nil, reportNumber: report,
        resultSummary: passed
            ? "\(results.count) Substanzen geprüft (\(method)). Alle unter MRL."
            : "⚠ MRL überschritten.",
        detail: .chemical(ChemicalCheckDetail(
            substancesTested: results, laboratoryName: lab, testMethod: method)),
        nextCheckDue: inMonths(3), isMandatory: mandatory)
}
 
private func qcVisual(
    color: Bool = true, shape: Bool = true, surface: Bool = true,
    mold: Bool = false, foreign: Bool = false,
    grade: String, rejection: Double, defects: [String] = []
) -> TomapoQualityCheck {
    let ok = !mold && !foreign && rejection < 5.0
    return TomapoQualityCheck(
        id: uid(), type: .visualInspection, status: ok ? .passed : .warning,
        performedAt: Date(), performedBy: "Sichtprüfung + Kamera-KI-System",
        accreditationNumber: nil, reportNumber: "VIS-\(Int.random(in: 10000...99999))",
        resultSummary: "Klasse: \(grade) · Ausschussrate: \(String(format: "%.1f", rejection))%",
        detail: .visual(VisualInspectionDetail(
            colorOk: color, shapeOk: shape, surfaceOk: surface,
            moldDetected: mold, foreignBodyDetected: foreign,
            gradeAssigned: grade, rejectionRate: rejection, defectsFound: defects)),
        nextCheckDue: nil, isMandatory: false)
}
 
private func qcWeight(
    target: Double, measured: Double, tolerance: Double, sampleSize: Int
) -> TomapoQualityCheck {
    let diff = abs(measured - target) / target * 100
    let ok = diff <= tolerance
    return TomapoQualityCheck(
        id: uid(), type: .weightCheck, status: ok ? .passed : .warning,
        performedAt: Date(), performedBy: "Automatische Wiegekontrolle",
        accreditationNumber: nil, reportNumber: "WGT-\(Int.random(in: 10000...99999))",
        resultSummary: "\(measured)g (Ziel: \(target)g, Toleranz: ±\(tolerance)%) – n=\(sampleSize)",
        detail: .weight(WeightCheckDetail(
            targetWeightG: target, measuredWeightG: measured,
            tolerancePercent: tolerance, isWithinTolerance: ok, sampleSize: sampleSize)),
        nextCheckDue: nil, isMandatory: true)
}
 
private func qcAudit(
    body: String, standard: String, type auditType: AuditType,
    score: Double, ncs: [NonConformity] = [], report: String,
    qcType: QualityCheckType = .organicCertCheck
) -> TomapoQualityCheck {
    let ok = !ncs.contains(where: { $0.severity == .critical })
    return TomapoQualityCheck(
        id: uid(), type: qcType, status: ok ? .passed : .failed,
        performedAt: daysAgo(14), performedBy: body,
        accreditationNumber: nil, reportNumber: report,
        resultSummary: "\(body) · Score: \(Int(score))/100 · Abweichungen: \(ncs.count)",
        detail: .certification(CertificationAuditDetail(
            certificationBody: body, standardAudited: standard,
            auditType: auditType, score: score, nonConformities: ncs,
            nextAuditDate: inMonths(12), certificateValidUntil: inMonths(12))),
        nextCheckDue: inMonths(12), isMandatory: true)
}
 
private func qcPkg(
    sealed: Bool, leaking: Bool, vacuum: Bool?, mapOk: Bool?,
    labelOk: Bool, barcodeOk: Bool, fillOk: Bool, defects: [String]
) -> TomapoQualityCheck {
    let ok = sealed && !leaking && labelOk && barcodeOk && fillOk && defects.isEmpty
    return TomapoQualityCheck(
        id: uid(), type: .packagingIntegrity, status: ok ? .passed : .warning,
        performedAt: Date(), performedBy: "Inline-Qualitätslinie",
        accreditationNumber: nil, reportNumber: "PKG-\(Int.random(in: 10000...99999))",
        resultSummary: ok ? "Dichtheitsprüfung: ✓ Barcode: ✓ Etikettierung: ✓" : "⚠ Mängel: \(defects.joined(separator: "; "))",
        detail: .packaging(PackagingIntegrityDetail(
            isSealed: sealed, isLeaking: leaking, vacuumIntact: vacuum,
            mapGasCompositionCorrect: mapOk, labelingCorrect: labelOk,
            barcodeReadable: barcodeOk, fillWeightCorrect: fillOk, defectsFound: defects)),
        nextCheckDue: nil, isMandatory: true)
}
 
// MARK: - LaborStation-Helfer
 
private func labStation(
    name: String, accred: String, accredBody: String, labType: LaboratoryType,
    location labLoc: TomapoLocation?,
    sampleId: String, samplingMethod: SamplingMethod, sampledBy: String,
    sampledAt: Date, matrix: String, batchId: String,
    techniques: [(String, AnalyticalTechnique, String, Double, String)],
    micro: [(name: String, detected: Bool, cfu: Double?, limit: Double?, method: String, hours: Int)],
    chemicals: [(name: String, cat: ChemicalResiduCategory, measured: Double?, limit: Double?, mrlExceeded: Bool, unit: String, method: String, status: ResiduStatus)],
    nutritional: MeasuredNutritionalValues?,
    physical: [PhysicalTestResult],
    allergens: [AllergenTestResult],
    authenticity: [AuthenticityTestResult],
    verdict: LaboratoryVerdict, recommendation: LaboratoryRecommendation,
    report: String, signedBy: String,
    stationTitle: String, stationSubtitle: String,
    stationLocation: TomapoLocation?, co2: Double?, isVerified: Bool
) -> TomapoStation {
 
    let microRes = micro.map {
        MicrobiologicalResult(pathogen: $0.name, testMethod: $0.method,
            detected: $0.detected, cfuPerGram: $0.cfu, euLimitCfuPerGram: $0.limit,
            limitExceeded: ($0.cfu ?? 0) > ($0.limit ?? 999999),
            analysisDurationHours: $0.hours,
            status: $0.detected ? .unsatisfactory : .satisfactory)
    }
    let chemRes = chemicals.map {
        ChemicalResiduResult(substanceName: $0.name, category: $0.cat,
            measuredValue: $0.measured, unit: $0.unit, mrlValue: $0.limit,
            mrlUnit: $0.unit, mrlExceeded: $0.mrlExceeded, method: $0.method,
            loqValue: 0.001, lodValue: 0.0003, belowLod: $0.measured == nil, status: $0.status)
    }
    let testMethods = techniques.map {
        LaboratoryTestMethod(standardName: $0.0, technique: $0.1, targetParameter: $0.2,
                             detectionLimitValue: $0.3, detectionLimitUnit: $0.4)
    }
    let pathRes = micro.map {
        PathogenResult(pathogen: $0.name, detected: $0.detected, cfu: $0.cfu,
                       limit: $0.limit, limitExceeded: ($0.cfu ?? 0) > ($0.limit ?? 999999))
    }
    let labDetail = LaboratoryDetail(
        laboratoryName: name, accreditationNumber: accred, accreditationBody: accredBody,
        isIso17025Accredited: true, laboratoryType: labType, location: labLoc,
        sampleId: sampleId, samplingMethod: samplingMethod, sampledBy: sampledBy,
        sampledAt: sampledAt, sampleWeightGrams: 500, sampleMatrix: matrix,
        batchId: batchId, sampleTransportedCooled: true, sampleArrivalTemperatureCelsius: 4.2,
        sampleReceivedAt: cal.date(byAdding: .hour, value: 4, to: sampledAt),
        analysisStartedAt: cal.date(byAdding: .hour, value: 6, to: sampledAt),
        analysisCompletedAt: cal.date(byAdding: .hour, value: 52, to: sampledAt),
        testMethods: testMethods, microbiologicalResults: microRes, chemicalResults: chemRes,
        nutritionalAnalysis: nutritional, physicalResults: physical,
        allergenResults: allergens, authenticityResults: authenticity,
        overallVerdict: verdict,
        legalLimitsExceeded: verdict == .nonCompliant || verdict == .unsafe,
        exceedanceCount: chemicals.filter(\.mrlExceeded).count + micro.filter(\.detected).count,
        recommendation: recommendation, reportNumber: report, reportUrl: nil,
        signedBy: signedBy, reportIssuedAt: cal.date(byAdding: .hour, value: 54, to: sampledAt))
 
    let qcSummary = TomapoQualityCheck(
        id: uid(), type: .microbiologicalTest,
        status: verdict == .compliant ? .passed : verdict == .minorDeviation ? .warning : .failed,
        performedAt: sampledAt, performedBy: name,
        accreditationNumber: accred, reportNumber: report,
        resultSummary: "Vollanalyse \(matrix) – Gesamturteil: \(verdict.rawValue).",
        detail: .microbiological(MicrobiologicalCheckDetail(
            pathogensTested: pathRes, totalBacterialCount: nil,
            laboratoryName: name, iso17025Accredited: true)),
        nextCheckDue: inMonths(3), isMandatory: true)
 
    return TomapoStation(
        id: uid(), type: .laboratoryTest,
        status: verdict == .compliant ? .completed : verdict == .minorDeviation ? .warning : .failed,
        title: stationTitle, subtitle: stationSubtitle, location: stationLocation,
        startedAt: sampledAt,
        completedAt: cal.date(byAdding: .hour, value: 54, to: sampledAt),
        durationHours: 54, qualityChecks: [qcSummary], certificationIds: [],
        co2KgPerKg: co2, environmentSummary: nil,
        detail: .laboratory(labDetail),
        isVerified: isVerified, verifiedBy: name,
        notes: "Prüfbericht \(report) · Unterzeichnet: \(signedBy)",
        wasRefrigerated: true, refrigerationTemperatureCelsius: 4.2)
}
 
// MARK: - ColdStorage-Helfer
 
private func coldStore(
    name: String, target: Double, minT: Double, maxT: Double, avgT: Double,
    broken: Bool = false, breaks: [ColdChainBreak] = [],
    sensor: String, lastReading: SensorReading
) -> ColdStorageDetail {
    ColdStorageDetail(facilityName: name, targetTemperatureCelsius: target,
                      minActualTemperatureCelsius: minT, maxActualTemperatureCelsius: maxT,
                      avgActualTemperatureCelsius: avgT, coldChainBroken: broken,
                      coldChainBreaks: breaks, sensorId: sensor, lastSensorReading: lastReading)
}
 
// MARK: - Umwelt-Helfer
 
private func envSummary(
    agri: Double?, proc: Double?, transport: Double?, pkg: Double?,
    dist: Double?, cons: Double?, total: Double?,
    eco: String?, ecoScore: Int?,
    water: Double?, waterStress: Double?,
    forest: Double?, forestGrade: String?, deforest: Double?,
    transportCo2: Double?, distKm: Double?, legs: Int?,
    pkgCo2: Double?, pkgScore: Int?, recyclePct: Double?,
    species: ThreatenedSpeciesRisk?, prodBonus: Int?, epi: Int?
) -> TomapoEnvironmentSummary {
    TomapoEnvironmentSummary(
        co2ByPhase: CO2ByPhase(agriculture: agri, processing: proc,
            transportation: transport, packaging: pkg,
            distribution: dist, consumption: cons),
        co2TotalKgPerKg: total, ecoscoreGrade: eco, ecoscoreScore: ecoScore,
        waterFootprintLiterPerKg: water, waterStressScore: waterStress,
        forestFootprintM2PerKg: forest, forestFootprintGrade: forestGrade,
        deforestationRisk: deforest,
        transportEmissionsGramsCo2: transportCo2, totalTransportDistanceKm: distKm,
        transportLegCount: legs, packagingCo2Kg: pkgCo2, packagingScore: pkgScore,
        recyclablePackagingPercent: recyclePct, threatenedSpeciesRisk: species,
        productionSystemBonus: prodBonus, originEpiScore: epi)
}
 
// MARK: ═══════════════════════════════════════════════════════════════════
// MARK: REGISTRY
// MARK: ═══════════════════════════════════════════════════════════════════
 
enum TomapoMockData {
 
    static func trace(for barcode: String) -> TomapoResponse? {
        switch barcode {
        case "4316268651288": return bioEier()
        default: return nil
        }
    }
 
    // MARK: ─── BioBio Bio-Freilandeier  4316268651288 ─────────────────────
 
    static func bioEier() -> TomapoResponse {
 
        // ── Station 1: Legehennenhaltung ──────────────────────────────────
        let s1 = TomapoStation(
            id: uid(), type: .farming, status: .completed,
            title: "Bio-Freiland-Legehennenhaltung – Bio-Hof Sonnenhügel",
            subtitle: "Sulingen, Niedersachsen · DE-031107 · 3'820 Hennen · GfRS DE-ÖKO-005",
            location: loc("Bio-Hof Sonnenhügel GbR – Stall 2", "DE", "Niedersachsen", "Sulingen",
                          address: "Hügelweg 12, 27232 Sulingen",
                          lat: 52.678, lon: 8.792, emb: "DE-031107"),
            startedAt: d("2025-01-15T00:00:00Z"), completedAt: d("2026-03-31T00:00:00Z"),
            durationHours: nil,
            qualityChecks: [
                TomapoQualityCheck(
                    id: uid(), type: .veterinaryInspection, status: .passed,
                    performedAt: d("2025-12-10T09:00:00Z"),
                    performedBy: "Veterinäramt Diepholz – Dr. Stefan Müller",
                    accreditationNumber: "VET-NI-DIE-2025-0441",
                    reportNumber: "VETA-DIE-2025-12-0391",
                    resultSummary: "3'820 Hennen guter AZ. Tierdichte: 4.2 H/m² (Grenzwert: 6). Auslauf: 6.2 m²/Henne. Keine Erkrankungen.",
                    detail: .certification(CertificationAuditDetail(
                        certificationBody: "Veterinäramt Diepholz",
                        standardAudited: "TierSchNutztV § 13ff + EU-Bio-VO 2018/848",
                        auditType: .unannounced, score: 98,
                        nonConformities: [], nextAuditDate: inMonths(6),
                        certificateValidUntil: inMonths(6))),
                    nextCheckDue: inMonths(6), isMandatory: true),
                qcMicro(pathogens: [
                    (name: "Salmonella Enteritidis", detected: false, cfu: 0.0, limit: 0.0, method: "ISO 6579-1 + PCR", hours: 48),
                    (name: "Salmonella Typhimurium", detected: false, cfu: 0.0, limit: 0.0, method: "ISO 6579-1 + PCR", hours: 48),
                    (name: "Campylobacter jejuni", detected: false, cfu: 0.0, limit: 0.0, method: "ISO 10272-1", hours: 48)],
                    totalCfu: 0, cfulimit: 0,
                    lab: "LUFA Nord-West Oldenburg", accred: "DAkkS-D-PL-11244-01",
                    report: "LUFA-NW-2026-01-S-0082"),
                qcAudit(body: "GfRS Gesellschaft für Ressourcenschutz GmbH",
                        standard: "EU-Öko-VO 2018/848 + DE-ÖKO-005",
                        type: .unannounced, score: 97.8,
                        ncs: [NonConformity(severity: .minor,
                              description: "Futterprotokoll KW48/2025: 3 Einträge lückenhaft",
                              correctionDeadline: inDays(30), corrected: true)],
                        report: "GFRS-BIO-2026-NI-00441", qcType: .organicCertCheck)],
            certificationIds: ["eu-organic", "de-oko-005", "no-gmos", "fsc"],
            co2KgPerKg: 2.786, environmentSummary: nil,
            detail: .farming(FarmingDetail(
                farmName: "Bio-Hof Sonnenhügel GbR – Familie Bergmann",
                farmingMethod: .organic, cropYear: 2026,
                animalSpecies: "Gallus gallus domesticus (Lohmann Brown Classic)",
                husbandrySystem: .freeRange, areaHectares: 12,
                fertilizerTypes: [.manure, .compost], pesticideTypes: [],
                fieldCoordinates: [FieldCoordinate(latitude: 52.678, longitude: 8.792)],
                irrigationType: .none, soilType: nil,
                plantingDate: d("2025-01-15T00:00:00Z"),
                expectedHarvestStart: nil, expectedHarvestEnd: nil)),
            isVerified: true, verifiedBy: "GfRS DE-ÖKO-005 + Veterinäramt Diepholz",
            notes: "Stempel: 0-DE-031107 · Futter: 100% bio, gentechnikfrei, Soja <5%",
            wasRefrigerated: false, refrigerationTemperatureCelsius: nil)
 
        // ── Station 2: Sortierung ─────────────────────────────────────────
        let s2 = TomapoStation(
            id: uid(), type: .sorting, status: .completed,
            title: "Sortierung & Gewichtsklassierung – Moba Omega",
            subtitle: "30'000 Eier/h · Klasse A · Gewichtsklasse L (63–73g)",
            location: loc("Packstelle DE-031107 Sonnenhügel", "DE", "Niedersachsen", "Sulingen",
                          lat: 52.678, lon: 8.793, emb: "DE-031107"),
            startedAt: d("2026-02-15T05:00:00Z"), completedAt: d("2026-02-15T09:00:00Z"),
            durationHours: 4,
            qualityChecks: [
                qcVisual(grade: "Klasse A · L (63–73g)", rejection: 1.8,
                         defects: ["Haarrissige Schale: 14 Stück"]),
                qcWeight(target: 67.5, measured: 67.8, tolerance: 4.5, sampleSize: 200)],
            certificationIds: [], co2KgPerKg: 0.02, environmentSummary: nil,
            detail: .harvest(HarvestDetail(
                method: .milking, harvestDate: d("2026-02-14T18:00:00Z"),
                gradeAfterHarvest: "Klasse A · L · Freiland-Stempel 0-DE-031107",
                yieldPercent: 98.2, harvestTemperatureCelsius: 12,
                isManual: false, workerCount: 2, immediatelyPrecooled: true)),
            isVerified: true, verifiedBy: nil,
            notes: "Legeleistung: 94.2% (KW 7/2026).",
            wasRefrigerated: false, refrigerationTemperatureCelsius: nil)
 
        // ── Station 3: Labor ──────────────────────────────────────────────
        let labEier = labStation(
            name: "LUFA Nord-West Oldenburg – Lebensmittellabor",
            accred: "DAkkS-D-PL-11244-01", accredBody: "DAkkS",
            labType: .externalIndependent,
            location: loc("LUFA Nord-West", "DE", "Niedersachsen", "Oldenburg",
                          address: "Mars-la-Tour-Str. 6, 26121 Oldenburg",
                          lat: 53.144, lon: 8.214),
            sampleId: "LUFA-NW-2026-02-EI-0082",
            samplingMethod: .representative, sampledBy: "QM Bio-Hof Sonnenhügel",
            sampledAt: d("2026-02-15T09:30:00Z"),
            matrix: "Bio-Freilandeier Klasse A, Gewichtsklasse L (5 Eier ≈ 340g Probe)",
            batchId: "DE-031107-26046",
            techniques: [
                ("EN ISO 6579-1:2017 + ISO/TS 13136 PCR", .realTimePcr, "Salmonella spp.", 1.0, "KBE/25g"),
                ("DIN 10117:1991 ELISA", .elisa, "Antibiotikarückstände", 0.001, "mg/kg"),
                ("ICP-MS EPA 200.8", .icpMs, "Schwermetalle Pb/Cd/Hg/As", 0.001, "mg/kg"),
                ("VDLUFA §3.8.1", .nirs, "Nährwertanalyse", 0.1, "%")],
            micro: [
                (name: "Salmonella Enteritidis", detected: false, cfu: 0.0, limit: 0.0, method: "ISO 6579-1 + PCR", hours: 48),
                (name: "Salmonella Typhimurium", detected: false, cfu: 0.0, limit: 0.0, method: "ISO 6579-1 + PCR", hours: 48)],
            chemicals: [
                (name: "Oxytetracyclin (OTC)", cat: .antibiotic, measured: nil, limit: 0.2, mrlExceeded: false, unit: "mg/kg", method: "LC-MS/MS", status: .notDetected),
                (name: "Cadmium (Cd)", cat: .heavyMetal, measured: 0.0003, limit: 0.05, mrlExceeded: false, unit: "mg/kg", method: "ICP-MS", status: .detected),
                (name: "Blei (Pb)", cat: .heavyMetal, measured: 0.008, limit: 0.10, mrlExceeded: false, unit: "mg/kg", method: "ICP-MS", status: .detected)],
            nutritional: MeasuredNutritionalValues(
                energyKcal: 147, fatG: 10.6, saturatedFatG: 3.1,
                carbohydratesG: 0.4, sugarsG: 0.4, fiberG: 0, proteinsG: 12.7,
                saltG: 0.36, moisturePercent: 74.8, ashG: 1.0,
                deviationFromDeclarationPercent: 1.4, isWithinEuTolerance: true),
            physical: [
                PhysicalTestResult(parameter: .hardness, measuredValue: 38.4, unit: "N",
                    minAllowed: 25.0, maxAllowed: nil, isWithinSpec: true,
                    notes: "Schalenbruchfestigkeit – Klasse A erfüllt")],
            allergens: [
                AllergenTestResult(allergen: "Eier", isEuMajorAllergen: true, method: .elisa,
                    detected: true, measuredMgPerKg: nil, declarationThresholdMgPerKg: nil,
                    declarationRequired: true, declarationOnLabelCorrect: true)],
            authenticity: [
                AuthenticityTestResult(testType: .organicStatus,
                    claim: "Bio-Status und Freilandhaltung",
                    isAuthentic: true, method: "δ¹³C Isotopen-Analyse + Fettsäuremuster",
                    confidencePercent: 99.1,
                    notes: "Bio-Status bestätigt durch Isotopenprofil und erhöhten Omega-3-Anteil")],
            verdict: .compliant, recommendation: .releaseProduct,
            report: "LUFA-NW-2026-02-EI-0082",
            signedBy: "Dr. Hannelore Fuchs – LUFA Nord-West",
            stationTitle: "Laboranalyse Eier – LUFA Nord-West",
            stationSubtitle: "Vollanalyse · Salmonella, Antibiotika, Schwermetalle, Nährwerte",
            stationLocation: loc("LUFA Nord-West", "DE", "Niedersachsen", "Oldenburg",
                                  lat: 53.144, lon: 8.214),
            co2: nil, isVerified: true)
 
        // ── Station 4: Verpackung ─────────────────────────────────────────
        let s4 = TomapoStation(
            id: uid(), type: .packaging, status: .completed,
            title: "Verpackung – 10er Karton FSC-Mix C122951",
            subtitle: "100% recyclierbar · MHD 02.03.2026 · Bio-Stempel 0-DE-031107",
            location: loc("Packstelle DE-031107", "DE", "Niedersachsen", "Sulingen",
                          lat: 52.678, lon: 8.793, emb: "DE-031107"),
            startedAt: d("2026-02-15T09:00:00Z"), completedAt: d("2026-02-15T13:00:00Z"),
            durationHours: 4,
            qualityChecks: [
                qcPkg(sealed: true, leaking: false, vacuum: nil, mapOk: nil,
                      labelOk: true, barcodeOk: true, fillOk: true, defects: []),
                qcWeight(target: 675, measured: 672.8, tolerance: 2.0, sampleSize: 60)],
            certificationIds: ["fsc-mix-c122951"],
            co2KgPerKg: 0.124, environmentSummary: nil,
            detail: .packaging(PackagingDetail(
                facilityName: "Packstelle Bio-Hof Sonnenhügel DE-031107",
                materials: [PackagingMaterialDetail(
                    material: "en:paperboard",
                    shape: "10er Eierkarton FSC-Mix (C122951) · Recyclingkarton 60%",
                    weightGrams: 46, isRecyclable: true, recyclingCode: "21", isFoodContact: true)],
                modifiedAtmosphere: nil, isVacuumPacked: false, isRecyclable: true,
                totalPackagingWeightGrams: 46, labelLanguages: ["de"],
                expirationDate: d("2026-03-02T00:00:00Z"),
                batchCodeOnPackaging: "DE-031107-26046")),
            isVerified: true, verifiedBy: "FSC C122951",
            notes: "Stempel auf jedem Ei: 0-DE-031107. MHD = Legedatum + 28 Tage.",
            wasRefrigerated: false, refrigerationTemperatureCelsius: nil)
 
        // ── Station 5: Kühltransport ──────────────────────────────────────
        let s5 = TomapoStation(
            id: uid(), type: .refrigeratedTruck, status: .completed,
            title: "Kühltransport → Netto DC Hannover",
            subtitle: "Netto Logistik · 185 km · 4–8°C · 6h · Kühlkette lückenlos",
            location: nil,
            startedAt: d("2026-02-16T03:30:00Z"), completedAt: d("2026-02-16T10:00:00Z"),
            durationHours: 6.5,
            qualityChecks: [
                qcTempLog(sensor: "SNS-NETTO-TRK-2026-0712", target: 6, min: 4, max: 8,
                          readings: [
                            ("2026-02-16T03:30:00Z", 5.8, 75.0),
                            ("2026-02-16T05:00:00Z", 6.1, 76.0),
                            ("2026-02-16T07:00:00Z", 6.4, 74.0),
                            ("2026-02-16T09:00:00Z", 6.2, 75.5),
                            ("2026-02-16T10:00:00Z", 5.9, 74.5)],
                          by: "Netto Logistik Kühltransport-Telematik")],
            certificationIds: [], co2KgPerKg: 0.169,
            environmentSummary: nil,
            detail: .transport(TransportDetail(
                mode: .refrigeratedTruck, carrierName: "Netto Logistik GmbH",
                trackingId: "NETTO-2026-02-KW07-TRK-0712",
                originLocation: loc("Bio-Hof Sonnenhügel", "DE", "Niedersachsen", "Sulingen",
                                    lat: 52.678, lon: 8.792),
                destinationLocation: loc("Netto DC Langenhagen", "DE", "Niedersachsen", "Langenhagen",
                                         address: "Industrieweg 8, 30855 Langenhagen",
                                         lat: 52.432, lon: 9.748),
                distanceKm: 185, isRefrigerated: true,
                coldStorageDetail: coldStore(
                    name: "Kühlauflieger NETTO-TRK-0712 – Thermo-King",
                    target: 6.0, minT: 5.8, maxT: 6.4, avgT: 6.1,
                    sensor: "SNS-NETTO-TRK-2026-0712",
                    lastReading: SensorReading(timestamp: d("2026-02-16T10:00:00Z"),
                        temperatureCelsius: 5.9, humidity: 74.5, isWithinRange: true)),
                co2EmissionsKg: 0.169 * 10.0 / 1000,
                vehicleType: "Mercedes-Benz Actros 2553 · Kühlauflieger Thermo-King T-1200R",
                fuelType: .diesel,
                scheduledArrival: d("2026-02-16T10:30:00Z"),
                actualArrival: d("2026-02-16T10:00:00Z"),
                delayReasons: [])),
            isVerified: true, verifiedBy: "Netto Telematik",
            notes: "5 Messungen alle 1.5h. Kühlkette lückenlos. Akzeptanztemperatur DC: max. 8°C.",
            wasRefrigerated: true, refrigerationTemperatureCelsius: 6.0)
 
        // ── Station 6: Verkaufsregal ──────────────────────────────────────
        let s6 = TomapoStation(
            id: uid(), type: .retailDisplay, status: .completed,
            title: "Kühlregal – Netto Marken-Discount",
            subtitle: "~4'200 Filialen DE · 4–8°C Kühlregal · MHD 02.03.2026",
            location: nil,
            startedAt: d("2026-02-17T06:00:00Z"), completedAt: nil, durationHours: nil,
            qualityChecks: [], certificationIds: [], co2KgPerKg: 0.080,
            environmentSummary: nil,
            detail: .retail(RetailDetail(
                storeName: nil, storeChain: "Netto Marken-Discount",
                storeGln: nil, displayType: .chilled, displayTemperatureCelsius: 6.0,
                firstOnShelfDate: d("2026-02-17T06:00:00Z"),
                bestBeforeDate: d("2026-03-02T00:00:00Z"),
                priceChf: nil)),
            isVerified: false, verifiedBy: nil, notes: nil,
            wasRefrigerated: true, refrigerationTemperatureCelsius: 6.0)
 
        // ── Alerts ────────────────────────────────────────────────────────
        let alertSchimmel = TomapoProductAlert(
            id: "alert-eier-001", barcode: "4316268651288",
            batchId: "DE-031107-26046", source: .user,
            category: .mold, severity: .high,
            title: "Schimmel an Eierschale entdeckt",
            description: "Habe bei 2 von 10 Eiern grünen Schimmel an der Schale festgestellt, obwohl MHD noch 5 Tage entfernt. Charge DE-031107-26046.",
            actionRequired: "Produkt nicht verwenden, beim Händler zurückgeben.",
            referenceId: nil, moreInfoUrl: nil,
            authorId: "user-mock-042", authorNickname: "thomas_k",
            authorAvatarUrl: nil, authorLogoUrl: nil,
            status: .active, confirmationCount: 7, rejectionCount: 1,
            createdAt: daysAgo(3), updatedAt: daysAgo(3),
            expiresAt: inDays(27))
 
        let alertInfo = TomapoProductAlert(
            id: "alert-eier-002", barcode: "4316268651288",
            batchId: nil, source: .official,
            category: .generalInfo, severity: .info,
            title: "Neues Verpackungsdesign ab März 2026",
            description: "Ab Charge März 2026 verwenden wir 100% recyceltes Papier für die Kartonverpackung. Die Eier sind identisch.",
            actionRequired: nil, referenceId: "BIOBIO-INFO-2026-03",
            moreInfoUrl: "https://biobio.de/news/verpackung-2026",
            authorId: "system-biobio", authorNickname: "BioBio GmbH",
            authorAvatarUrl: nil, authorLogoUrl: nil,
            status: .verified, confirmationCount: 0, rejectionCount: 0,
            createdAt: daysAgo(14), updatedAt: daysAgo(14), expiresAt: nil)
 
        // ── Roh-Zutaten ───────────────────────────────────────────────────
        let rawIngredients: [RawIngredient] = [
            RawIngredient(id: "en:eggs", text: "Bio-Freilandeier",
                          percent: 100, percentEstimate: 100,
                          percentMin: 100, percentMax: 100,
                          vegan: "no", vegetarian: "yes", fromPalmOil: "no",
                          ingredients: nil)
        ]
 
        // ── ProductIngredients (strukturiert) ─────────────────────────────
        let ingredients: [ProductIngredient] = [
            .subProduct(SubProductIngredient(
                id: "sub-eier-001",
                barcode: "4316268651288-egg",
                batchId: "DE-031107-26046",
                name: "Bio-Freilandeier",
                description: "Freilandeier aus ökologischer Haltung. Haltungsform 3 (Freiland). Bio-zertifiziert nach EU-Öko-VO 2018/848.",
                category: .eggs,
                percentageInProduct: 100,
                originCountry: "DE",
                originRegion: "Niedersachsen",
                supplierName: "Bio-Hof Sonnenhügel GbR",
                supplierCountry: "DE",
                imageUrl: nil,
                certifications: TomapoCertification.from(offLabelTags: ["en:organic", "en:eu-organic"]),
                traceData: nil))
        ]
 
        // ── Verpackung ────────────────────────────────────────────────────
        let packagings: [ProductPackaging] = [
            ProductPackaging(
                material: "en:paperboard", shape: "en:egg-box",
                recycling: "en:recycle-in-sorting-bin",
                weightMeasured: 46, numberOfUnits: 10,
                quantityPerUnit: "1 Ei", foodContact: 1,
                nonRecyclableAndNonBiodegradable: "no",
                environmentalScoreMaterialScore: 92)
        ]
 
        // ── TomapoResponse ────────────────────────────────────────────────
        return TomapoResponse(
            barcode: "4316268651288",
            batchId: "DE-031107-26046",
            generatedAt: Date(),
            // Produktdaten (ehemals OFFProduct)
            productName: "BioBio Bio-Eier Freilandhaltung 10 Stück",
            genericName: "Bio-Freilandeier",
            brands: "BioBio",
            quantity: "10 Stück",
            productQuantity: 10,
            productQuantityUnit: "Stück",
            servingSize: "63g (1 Ei)",
            servingQuantity: 63,
            storesTags: ["netto-marken-discount"],
            imageUrl: nil,
            imageFrontUrl: nil,
            imageIngredientsUrl: nil,
            imageNutritionUrl: nil,
            imagePackagingUrl: nil,
            categoriesTags: ["en:eggs", "en:hen-eggs", "en:free-range-eggs"],
            foodGroupsTags: ["en:eggs"],
            foodGroups: "en:eggs",
            pnnsGroups1: "Fish Meat Eggs",
            pnnsGroups2: "Eggs",
            nutriscoreGrade: "a",
            nutriscoreScore: -4,
            ecoscoreGrade: "b",
            ecoscoreScore: 65,
            novaGroup: 1,
            novaGroupError: nil,
            nutriments: ProductNutriments(
                energyKcal100g: 147, energyKj100g: 614,
                energyKcalServing: 93, energyKjServing: 388,
                fat100g: 10.6, saturatedFat100g: 3.1,
                fatServing: 6.7, saturatedFatServing: 2.0,
                carbohydrates100g: 0.4, sugars100g: 0.4,
                fiber100g: 0, addedSugars100g: nil, starch100g: nil,
                carbohydratesServing: 0.3, sugarsServing: 0.3, fiberServing: nil,
                proteins100g: 12.7, proteinsServing: 8.0,
                salt100g: 0.36, sodium100g: 0.14,
                saltServing: 0.23, sodiumServing: 0.09, novaGroup100g: 1),
            nutrientLevels: ProductNutrientLevels(
                fat: "moderate", saturatedFat: "moderate", sugars: "low", salt: "low"),
            ingredientsText: "Bio-Freilandeier",
            rawIngredients: rawIngredients,
            ingredientsN: 1, additivesN: 0,
            additivesTags: [],
            allergensTags: ["en:eggs"],
            tracesTags: [],
            ingredientsAnalysisTags: ["en:vegan-status-unknown"],
            labelsTags: ["en:organic", "en:eu-organic", "en:no-gmos", "en:fsc", "en:de-oko-005"],
            countriesTags: ["en:germany"],
            originsTags: ["en:germany"],
            manufacturingPlaces: "Sulingen, Niedersachsen, DE",
            manufacturingPlacesTags: ["en:germany"],
            packagingTags: ["en:paperboard", "en:recycled-materials"],
            packagings: packagings,
            packagingText: "FSC-Mix Karton C122951 · 100% recyclierbar",
            conservationConditions: "Kühl und trocken lagern (4–8°C). MHD beachten.",
            dataQualityErrorsTags: [],
            dataQualityWarningsTags: ["en:ecoscore-origins-of-ingredients-not-specified"],
            completeness: 0.92,
            // Tomapo Core
            alerts: [alertSchimmel, alertInfo],
            stations: [s1, s2, labEier, s4, s5, s6],
            environmentSummary: envSummary(
                agri: 2.786, proc: 0.0, transport: 0.169, pkg: 0.124, dist: 0.008, cons: 0.080,
                total: 3.167, eco: "b", ecoScore: 65,
                water: 340, waterStress: 0.15, forest: 0.0156, forestGrade: "a", deforest: 0.1,
                transportCo2: 31.2, distKm: 185, legs: 1,
                pkgCo2: 0.124, pkgScore: 92, recyclePct: 100,
                species: nil, prodBonus: 15, epi: 80),
            certifications: TomapoCertification.from(offLabelTags: [
                "en:organic", "en:eu-organic", "en:no-gmos", "en:fsc", "en:fsc-mix", "en:de-oko-005"]),
            traceabilityScore: tScore(0.97, v: 5, u: 0, gaps: false,
                hash: "sha256:b7d4e9f2a1c3e5d8b9a0c2e4f6a8b0c2d4e6f8g0"),
            dataSources: src([
                ("off",  "Open Food Facts",        .openFoodFacts, .community),
                ("mfr",  "Bio-Hof Sonnenhügel GbR", .manufacturer, .official),
                ("gfrs", "GfRS DE-ÖKO-005",        .certification, .verified),
                ("lufa", "LUFA Nord-West",          .laboratory,    .verified),
                ("vet",  "Veterinäramt Diepholz",   .government,    .verified)]),
            ingredients: ingredients,
            requiresColdChain: true,
            coldChainSummary: TomapoColdChainSummary(
                isIntact: true,
                refrigeratedStationCount: 2,
                unrefrigeratedStationCount: 4,
                lowestTemperatureCelsius: 5.8,
                highestTemperatureCelsius: 6.4,
                hadColdChainBreak: false,
                coldChainBreakCount: 0,
                totalBreakDurationMinutes: nil,
                totalRefrigeratedTransportHours: 6.5,
                summaryText: "Kühlkette lückenlos · 2 gekühlte Stationen · max. 6.4°C · 6.5h Kühltransport"))
    }
}
