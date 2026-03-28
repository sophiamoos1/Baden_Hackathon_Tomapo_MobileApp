//
//  MockData.swift
//  Tomapo
//
//  Created by Sophia Moos on 28.03.2026.
//

// MARK: Verwendung für Demo und Pitch
//
//  Generiert aus den Backend-Seeds (trace.seed.js, eltonymate.seed.js,
//  alerts.seed.js, userMessages.seed.js, scanHistory.seed.js, User.seed.js)
//
//  Enthält:
//  • MockUsers          – 4 User (Max, Lara, Timo, Sofia)
//  • MockTraces         – 5 vollständige TomapoResponse-Objekte
//    ├─ Coca-Cola 500ml
//    ├─ Ovomaltine 500g
//    ├─ Migros Vollmilch 1L  (Kühlkette)
//    ├─ Lindt Excellence 85% (aktiver Recall)
//    └─ El Tony Mate 330ml
//  • MockAlerts         – 5 Alerts
//  • MockUserMessages   – 3 Meldungen
//

internal import Foundation

// MARK: - Datum-Helfer

private func date(_ iso: String) -> Date {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let d = f.date(from: iso) { return d }
    f.formatOptions = [.withInternetDateTime]
    return f.date(from: iso) ?? Date()
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: USERS
// MARK: ══════════════════════════════════════════════════════════

enum MockUsers {

    static let maxMueller = TomapoUser(
        id: "64a1b2c3d4e5f6a7b8c9d001",
        fullName: "Max Müller",
        email: "max.mueller@example.ch",
        nickname: "maxmueller",
        avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=maxmueller",
        messages: [
            TomapoUserMessageSummary(
                id: "64a1b2c3d4e5f6a7b8c9c001",
                barcode: "3046920028836",
                batchId: "LINDT-85-2026-0201",
                productName: "Lindt Excellence 85% Cacao",
                productBrand: "Lindt",
                productCategoryTag: "chocolates",
                messageTitle: "Fremdkörper in Lindt Excellence 85%",
                messageCategory: .foreignObject,
                messageSeverity: .high,
                submissionStatus: .submitted,
                createdAt: date("2026-02-20T15:00:00Z"),
                updatedAt: date("2026-02-20T15:00:00Z")
            )
        ],
        createdAt: date("2025-11-01T08:00:00Z"),
        updatedAt: date("2026-03-15T10:30:00Z"),
        isSyncedWithBackend: true
    )

    static let laraSchmid = TomapoUser(
        id: "64a1b2c3d4e5f6a7b8c9d002",
        fullName: "Lara Schmid",
        email: "lara.schmid@example.ch",
        nickname: "laras",
        avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=laras",
        messages: [
            TomapoUserMessageSummary(
                id: "64a1b2c3d4e5f6a7b8c9c002",
                barcode: "7610815001032",
                batchId: "MILCH-2026-0320",
                productName: "Migros Vollmilch 1L",
                productBrand: "Migros",
                productCategoryTag: "milks",
                messageTitle: "Migros Vollmilch riecht säuerlich vor MHD",
                messageCategory: .qualityDefect,
                messageSeverity: .medium,
                submissionStatus: .submitted,
                createdAt: date("2026-03-22T09:30:00Z"),
                updatedAt: date("2026-03-22T09:30:00Z")
            )
        ],
        createdAt: date("2025-12-15T09:00:00Z"),
        updatedAt: date("2026-02-20T14:00:00Z"),
        isSyncedWithBackend: true
    )

    static let timoKeller = TomapoUser(
        id: "64a1b2c3d4e5f6a7b8c9d003",
        fullName: "Timo Keller",
        email: "timo.keller@example.ch",
        nickname: "timok",
        avatarUrl: nil,
        messages: [
            TomapoUserMessageSummary(
                id: "64a1b2c3d4e5f6a7b8c9c003",
                barcode: "7640150491001",
                batchId: "L250634716:41",
                productName: "El Tony Mate 330ml",
                productBrand: "El Tony",
                productCategoryTag: "beverages",
                messageTitle: "El Tony Mate Flasche undicht",
                messageCategory: .qualityDefect,
                messageSeverity: .low,
                submissionStatus: .submitted,
                createdAt: date("2025-06-12T16:30:00Z"),
                updatedAt: date("2025-06-12T16:30:00Z")
            )
        ],
        createdAt: date("2026-01-10T11:00:00Z"),
        updatedAt: date("2026-01-10T11:00:00Z"),
        isSyncedWithBackend: true
    )

    static let sofiaRossi = TomapoUser(
        id: "64a1b2c3d4e5f6a7b8c9d004",
        fullName: "Sofia Rossi",
        email: "sofia.rossi@example.ch",
        nickname: "sofiar",
        avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=sofiar",
        messages: [],
        createdAt: date("2026-02-05T16:00:00Z"),
        updatedAt: date("2026-02-05T16:00:00Z"),
        isSyncedWithBackend: false
    )

    static let all: [TomapoUser] = [maxMueller, laraSchmid, timoKeller, sofiaRossi]
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: ALERTS
// MARK: ══════════════════════════════════════════════════════════

enum MockAlerts {

    // ── Alert 1: BLV Rückruf Lindt ────────────────────────────────
    static let blvRecallLindt = TomapoProductAlert(
        id: "64a1b2c3d4e5f6a7b8c9b001",
        barcode: "3046920028836",
        batchId: "LINDT-85-2026-0201",
        source: .government,
        category: .productRecall,
        severity: .high,
        title: "Rückruf: Lindt Excellence 85% — erhöhter Cadmiumgehalt",
        description: "Das Bundesamt für Lebensmittelsicherheit hat einen Rückruf für die Charge LINDT-85-2026-0201 ausgesprochen. Cadmiumgehalt 0.28 mg/kg – innerhalb EU-Grenzwert, jedoch über Tomapo-Schwellenwert.",
        actionRequired: "Produkt nicht konsumieren. Zurückgeben an Verkaufsstelle.",
        referenceId: "BLV-2026-0215-004",
        moreInfoUrl: "https://www.blv.admin.ch/rueckrufe/2026/lindt-cadmium",
        authorId: nil,
        authorNickname: "BLV",
        authorAvatarUrl: nil,
        authorLogoUrl: nil,
        status: .active,
        confirmationCount: 12,
        rejectionCount: 2,
        createdAt: date("2026-02-15T10:00:00Z"),
        updatedAt: date("2026-02-15T10:00:00Z"),
        expiresAt: date("2026-12-31T00:00:00Z")
    )

    // ── Alert 2: Migros Qualitätswarnung ──────────────────────────
    static let migrosQuality = TomapoProductAlert(
        id: "64a1b2c3d4e5f6a7b8c9b002",
        barcode: "7610815001032",
        batchId: nil,
        source: .official,
        category: .qualityDefect,
        severity: .medium,
        title: "Qualitätshinweis: Migros Vollmilch — verkürzte Haltbarkeit",
        description: "Aufgrund eines Kühlkettenproblems bei der Lieferung kann die Haltbarkeit einzelner Chargen verkürzt sein. Bitte MHD prüfen.",
        actionRequired: "MHD überprüfen. Bei Unsicherheit Produkt nicht konsumieren.",
        referenceId: "MGR-QA-2026-0318",
        moreInfoUrl: nil,
        authorId: nil,
        authorNickname: "Migros",
        authorAvatarUrl: nil,
        authorLogoUrl: nil,
        status: .active,
        confirmationCount: 5,
        rejectionCount: 1,
        createdAt: date("2026-03-18T08:00:00Z"),
        updatedAt: date("2026-03-18T08:00:00Z"),
        expiresAt: date("2026-04-01T00:00:00Z")
    )

    // ── Alert 3: Info Ovomaltine neue Rezeptur ────────────────────
    static let infoOvomaltine = TomapoProductAlert(
        id: "64a1b2c3d4e5f6a7b8c9b003",
        barcode: "7610305001002",
        batchId: nil,
        source: .official,
        category: .recipeChange,
        severity: .low,
        title: "Information: Ovomaltine — neue Rezeptur ab Q2 2026",
        description: "Ab April 2026 wird die Rezeptur leicht angepasst. Zuckergehalt wird um 8 % reduziert. Geschmack und Nährwertprofil bleiben weitgehend gleich.",
        actionRequired: nil,
        referenceId: "WANDER-PR-2026-001",
        moreInfoUrl: "https://www.ovomaltine.ch/news/rezeptur-2026",
        authorId: nil,
        authorNickname: "Wander AG",
        authorAvatarUrl: nil,
        authorLogoUrl: nil,
        status: .active,
        confirmationCount: 0,
        rejectionCount: 0,
        createdAt: date("2026-03-01T09:00:00Z"),
        updatedAt: date("2026-03-01T09:00:00Z"),
        expiresAt: date("2026-06-30T00:00:00Z")
    )

    // ── Alert 4: Community Milch säuerlich ────────────────────────
    static let communityMilch = TomapoProductAlert(
        id: "64a1b2c3d4e5f6a7b8c9b004",
        barcode: "7610815001032",
        batchId: "MILCH-2026-0320",
        source: .community,
        category: .qualityDefect,
        severity: .low,
        title: "Community: Milch riecht leicht säuerlich",
        description: "Mehrere User berichten, dass die Charge MILCH-2026-0320 bereits beim Öffnen leicht säuerlich riecht, obwohl MHD noch 5 Tage entfernt.",
        actionRequired: "Bei auffälligem Geruch nicht konsumieren.",
        referenceId: nil,
        moreInfoUrl: nil,
        authorId: nil,
        authorNickname: "Community",
        authorAvatarUrl: nil,
        authorLogoUrl: nil,
        status: .active,
        confirmationCount: 8,
        rejectionCount: 3,
        createdAt: date("2026-03-21T14:00:00Z"),
        updatedAt: date("2026-03-21T14:00:00Z"),
        expiresAt: date("2026-03-31T00:00:00Z")
    )

    // ── Alert 5: Community El Tony undicht ────────────────────────
    static let communityElTony = TomapoProductAlert(
        id: "64a1b2c3d4e5f6a7b8c9b005",
        barcode: "7640150491001",
        batchId: "L250634716:41",
        source: .community,
        category: .qualityDefect,
        severity: .low,
        title: "Community: El Tony Mate — Flasche undicht",
        description: "Einzelne User aus der Charge L250634716:41 berichten von leicht undichten Verschlüssen. Kein Gesundheitsrisiko, aber Qualitätsmangel.",
        actionRequired: "Verschluss vor dem Kauf prüfen.",
        referenceId: nil,
        moreInfoUrl: nil,
        authorId: nil,
        authorNickname: "Community",
        authorAvatarUrl: nil,
        authorLogoUrl: nil,
        status: .active,
        confirmationCount: 3,
        rejectionCount: 1,
        createdAt: date("2025-06-10T11:00:00Z"),
        updatedAt: date("2025-06-10T11:00:00Z"),
        expiresAt: date("2025-12-31T00:00:00Z")
    )
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: USER MESSAGES
// MARK: ══════════════════════════════════════════════════════════

enum MockUserMessages {

    static let maxLindt = TomapoUserMessage(
        id: "64a1b2c3d4e5f6a7b8c9c001",
        authorId: "64a1b2c3d4e5f6a7b8c9d001",
        authorNickname: "maxmueller",
        productSnapshot: TomapoMessageProductSnapshot(
            barcode: "3046920028836",
            batchId: "LINDT-85-2026-0201",
            productName: "Lindt Excellence 85% Cacao",
            brand: "Lindt",
            quantity: "100g",
            imageUrl: "https://images.openfoodfacts.org/images/products/304/692/002/8836/front.jpg",
            nutriscoreGrade: "d",
            ecoscoreGrade: "c",
            categoriesTags: ["chocolates", "dark-chocolates"],
            scannedAt: date("2026-02-20T14:30:00Z"),
            scannedAtStoreName: "Migros Zürich HB"
        ),
        category: .foreignObject,
        title: "Fremdkörper in Lindt Excellence 85%",
        body: "Beim Öffnen der Tafel habe ich ein kleines Plastikstück (ca. 3 mm) gefunden. Charge LINDT-85-2026-0201, Kaufdatum 20.02.2026, Migros Zürich HB.",
        severity: .high,
        submissionStatus: .submitted,
        linkedAlertId: nil,
        createdAt: date("2026-02-20T15:00:00Z"),
        updatedAt: date("2026-02-20T15:00:00Z")
    )

    static let laraMilch = TomapoUserMessage(
        id: "64a1b2c3d4e5f6a7b8c9c002",
        authorId: "64a1b2c3d4e5f6a7b8c9d002",
        authorNickname: "laras",
        productSnapshot: TomapoMessageProductSnapshot(
            barcode: "7610815001032",
            batchId: "MILCH-2026-0320",
            productName: "Migros Vollmilch 1L",
            brand: "Migros",
            quantity: "1L",
            imageUrl: nil,
            nutriscoreGrade: "b",
            ecoscoreGrade: "c",
            categoriesTags: ["milks", "whole-milks"],
            scannedAt: date("2026-03-22T09:00:00Z"),
            scannedAtStoreName: "Migros Oerlikon"
        ),
        category: .qualityDefect,
        title: "Migros Vollmilch riecht säuerlich vor MHD",
        body: "Die Milch aus Charge MILCH-2026-0320 riecht bereits beim Öffnen leicht säuerlich. MHD ist noch 4 Tage entfernt. Konsistenz wirkt normal, aber Geruch definitiv nicht frisch.",
        severity: .medium,
        submissionStatus: .submitted,
        linkedAlertId: nil,
        createdAt: date("2026-03-22T09:30:00Z"),
        updatedAt: date("2026-03-22T09:30:00Z")
    )

    static let timoElTony = TomapoUserMessage(
        id: "64a1b2c3d4e5f6a7b8c9c003",
        authorId: "64a1b2c3d4e5f6a7b8c9d003",
        authorNickname: "timok",
        productSnapshot: TomapoMessageProductSnapshot(
            barcode: "7640150491001",
            batchId: "L250634716:41",
            productName: "El Tony Mate 330ml",
            brand: "El Tony",
            quantity: "330ml",
            imageUrl: "https://images.openfoodfacts.org/images/products/764/015/049/1001/front.jpg",
            nutriscoreGrade: "b",
            ecoscoreGrade: "b",
            categoriesTags: ["beverages", "sodas", "mate"],
            scannedAt: date("2025-06-12T16:00:00Z"),
            scannedAtStoreName: "Coop City Zürich Bellevue"
        ),
        category: .qualityDefect,
        title: "El Tony Mate Flasche undicht",
        body: "Habe heute eine Flasche El Tony Mate (Charge L250634716:41) gekauft und der Verschluss war nicht richtig zu. Ein paar ml Flüssigkeit haben sich bereits verloren. Kein Geruch, aber trotzdem blöd.",
        severity: .low,
        submissionStatus: .submitted,
        linkedAlertId: nil,
        createdAt: date("2025-06-12T16:30:00Z"),
        updatedAt: date("2025-06-12T16:30:00Z")
    )

    static let all: [TomapoUserMessage] = [maxLindt, laraMilch, timoElTony]
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: TRACE: Coca-Cola Original 500ml
// MARK: ══════════════════════════════════════════════════════════

enum MockTraceCocaCola {

    // MARK: Certifications
    static let certISO22000 = TomapoCertification(
        id: "cert-iso22000-001",
        type: .iso22000,
        name: "ISO 22000",
        issuingBody: "SGS SA",
        certificateNumber: nil,
        validFrom: date("2024-06-01T00:00:00Z"),
        validUntil: date("2027-06-01T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: "https://www.sgs.com/certifications/iso22000/cc-ch-001",
        scope: .facility,
        source: .thirdParty,
        offLabelTag: nil
    )

    // MARK: Stations
    static let stationAbfuellung = TomapoStation(
        id: "sta-cc-001",
        type: .processing,
        status: .completed,
        title: "Abfüllung Brüttisellen",
        subtitle: "Abfüllanlage Schweiz",
        location: TomapoLocation(
            name: "Coca-Cola HBC Schweiz AG",
            country: "CH",
            region: "Zürich",
            city: "Brüttisellen",
            address: "Stationsstrasse 33, 8306 Brüttisellen",
            latitude: 47.4250,
            longitude: 8.6236,
            embCode: nil,
            gln: "7610305000001"
        ),
        startedAt: date("2026-03-10T06:00:00Z"),
        completedAt: date("2026-03-10T22:00:00Z"),
        durationHours: 16,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-cc-001",
                type: .microbiologicalTest,
                status: .passed,
                performedAt: date("2026-03-10T08:00:00Z"),
                performedBy: "QC Labor Brüttisellen",
                accreditationNumber: "STS 0459",
                reportNumber: "QC-2026-0310-001",
                resultSummary: "Keine pathogenen Keime nachgewiesen",
                detail: .microbiological(MicrobiologicalCheckDetail(
                    pathogensTested: [
                        PathogenResult(pathogen: "E. coli",         detected: false, cfu: 0, limit: 100, limitExceeded: false),
                        PathogenResult(pathogen: "Salmonella spp.", detected: false, cfu: 0, limit: 0,   limitExceeded: false)
                    ],
                    totalBacterialCount: nil,
                    laboratoryName: "Coca-Cola Internes Labor",
                    iso17025Accredited: true
                )),
                nextCheckDue: date("2026-06-10T08:00:00Z"),
                isMandatory: true
            )
        ],
        certificationIds: ["cert-iso22000-001"],
        co2KgPerKg: 0.18,
        environmentSummary: nil,
        detail: .processing(ProcessingDetail(
            facilityName: "Coca-Cola HBC Brüttisellen",
            facilityEmbCode: nil,
            processTypes: [.cooking],
            processingTemperatureCelsius: nil,
            pasteurization: nil,
            sterilization: nil,
            additivesAdded: [],
            isHaccpCertified: true,
            foodSafetyStandard: .fssc22000,
            batchSizeKg: nil
        )),
        isVerified: true,
        verifiedBy: "Coca-Cola HBC Schweiz AG",
        notes: "ISO 22000 zertifizierte Abfüllanlage",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationDistribution = TomapoStation(
        id: "sta-cc-002",
        type: .distribution,
        status: .completed,
        title: "Verteilung Zürich Lager",
        subtitle: "Regionallager Ostschweiz",
        location: TomapoLocation(
            name: "Coca-Cola Lager Zürich",
            country: "CH",
            region: "Zürich",
            city: "Dietlikon",
            address: "Industriestrasse 10, 8305 Dietlikon",
            latitude: 47.4100,
            longitude: 8.6400,
            embCode: nil,
            gln: "7610305000002"
        ),
        startedAt: date("2026-03-11T04:00:00Z"),
        completedAt: date("2026-03-11T18:00:00Z"),
        durationHours: 14,
        qualityChecks: [],
        certificationIds: [],
        co2KgPerKg: 0.04,
        environmentSummary: nil,
        detail: .distribution(DistributionDetail(
            centerName: "CDC Zürich-Ost",
            centerType: .regional,
            inboundDate: date("2026-03-11T04:00:00Z"),
            outboundDate: date("2026-03-11T18:00:00Z"),
            handlingCount: nil,
            customsCleared: true,
            customsClearanceDate: nil,
            importInspectionPassed: nil,
            inspectedBy: nil
        )),
        isVerified: true,
        verifiedBy: "Coca-Cola Distribution CH",
        notes: nil,
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationRetail = TomapoStation(
        id: "sta-cc-003",
        type: .retailDisplay,
        status: .completed,
        title: "Migros Filiale Zürich HB",
        subtitle: "Einzelhandel",
        location: TomapoLocation(
            name: "Migros Zürich HB",
            country: "CH",
            region: "Zürich",
            city: "Zürich",
            address: "Shopville, 8001 Zürich",
            latitude: 47.3778,
            longitude: 8.5403,
            embCode: nil,
            gln: "7610200000001"
        ),
        startedAt: date("2026-03-12T05:00:00Z"),
        completedAt: nil,
        durationHours: nil,
        qualityChecks: [],
        certificationIds: [],
        co2KgPerKg: 0.02,
        environmentSummary: nil,
        detail: .retail(RetailDetail(
            storeName: "Migros Zürich HB",
            storeChain: "Migros",
            storeGln: "7610200000001",
            displayType: .ambient,
            displayTemperatureCelsius: 18,
            firstOnShelfDate: date("2026-03-12T05:00:00Z"),
            bestBeforeDate: nil,
            priceChf: nil
        )),
        isVerified: false,
        verifiedBy: nil,
        notes: nil,
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    // MARK: Response
    static let response = TomapoResponse(
        barcode: "5449000000996",
        batchId: "CC-CH-2026-0312",
        generatedAt: date("2026-03-12T06:00:00Z"),
        productName: "Coca-Cola Original 500ml",
        genericName: "Kohlensäurehaltiges Erfrischungsgetränk",
        brands: "Coca-Cola",
        quantity: "500ml",
        productQuantity: 500,
        productQuantityUnit: "ml",
        servingSize: "250ml",
        servingQuantity: 250,
        storesTags: ["migros", "coop", "denner"],
        imageUrl: "https://images.openfoodfacts.org/images/products/544/900/000/0996/front.jpg",
        imageFrontUrl: "https://images.openfoodfacts.org/images/products/544/900/000/0996/front.jpg",
        imageIngredientsUrl: nil,
        imageNutritionUrl: nil,
        imagePackagingUrl: nil,
        categoriesTags: ["en:beverages", "en:sodas", "en:carbonated-drinks"],
        foodGroupsTags: ["en:sugary-drinks"],
        foodGroups: "Sugary drinks",
        pnnsGroups1: "Beverages",
        pnnsGroups2: "Sweetened beverages",
        nutriscoreGrade: "e",
        nutriscoreScore: 14,
        ecoscoreGrade: "c",
        ecoscoreScore: 43,
        novaGroup: 4,
        novaGroupError: nil,
        nutriments: ProductNutriments(
            energyKcal100g: 42,
            energyKj100g: 180,
            energyKcalServing: 105,
            energyKjServing: 450,
            fat100g: 0,
            saturatedFat100g: 0,
            fatServing: 0,
            saturatedFatServing: 0,
            carbohydrates100g: 10.6,
            sugars100g: 10.6,
            fiber100g: 0,
            addedSugars100g: 10.6,
            starch100g: nil,
            carbohydratesServing: 26.5,
            sugarsServing: 26.5,
            fiberServing: nil,
            proteins100g: 0,
            proteinsServing: 0,
            salt100g: 0,
            sodium100g: 0,
            saltServing: 0,
            sodiumServing: 0,
            novaGroup100g: 4
        ),
        nutrientLevels: ProductNutrientLevels(
            fat: "low",
            saturatedFat: "low",
            sugars: "high",
            salt: "low"
        ),
        ingredientsText: "Wasser, Zucker, Kohlensäure, Farbstoff E150d, Phosphorsäure E338, Aromen, Koffein",
        rawIngredients: nil,
        ingredientsN: 7,
        additivesN: 3,
        additivesTags: ["en:e150d", "en:e338"],
        allergensTags: [],
        tracesTags: [],
        ingredientsAnalysisTags: ["en:non-vegan", "en:palm-oil-free"],
        labelsTags: [],
        countriesTags: ["en:switzerland"],
        originsTags: ["en:switzerland"],
        manufacturingPlaces: "Brüttisellen, Schweiz",
        manufacturingPlacesTags: ["en:bruttisellen"],
        packagingTags: ["en:plastic-bottle", "en:recycled"],
        packagings: nil,
        packagingText: "PET-Flasche",
        conservationConditions: nil,
        dataQualityErrorsTags: [],
        dataQualityWarningsTags: [],
        completeness: 0.82,
        alerts: [],
        stations: [stationAbfuellung, stationDistribution, stationRetail],
        environmentSummary: TomapoEnvironmentSummary(
            co2ByPhase: CO2ByPhase(
                agriculture: nil,
                processing: 0.18,
                transportation: 0.04,
                packaging: 0.052,
                distribution: 0.04,
                consumption: nil
            ),
            co2TotalKgPerKg: 0.24,
            ecoscoreGrade: "c",
            ecoscoreScore: 43,
            waterFootprintLiterPerKg: 210,
            waterStressScore: 0.32,
            forestFootprintM2PerKg: nil,
            forestFootprintGrade: nil,
            deforestationRisk: nil,
            transportEmissionsGramsCo2: 38,
            totalTransportDistanceKm: 85,
            transportLegCount: 2,
            packagingCo2Kg: 0.052,
            packagingScore: 55,
            recyclablePackagingPercent: 1.0,
            threatenedSpeciesRisk: nil,
            productionSystemBonus: nil,
            originEpiScore: nil
        ),
        certifications: [certISO22000],
        traceabilityScore: TomapoTraceabilityScore(
            completeness: 0.82,
            verifiedStations: 2,
            unknownStations: 0,
            hasGaps: false,
            isThirdPartyVerified: true,
            blockchainHash: nil
        ),
        dataSources: [
            TomapoDataSource(id: "ds-cc-001", name: "Coca-Cola HBC Schweiz",  type: .manufacturer,  lastSynced: date("2026-03-12T06:00:00Z"), reliability: .verified),
            TomapoDataSource(id: "ds-cc-002", name: "Open Food Facts",        type: .openFoodFacts, lastSynced: date("2026-03-12T06:01:00Z"), reliability: .community)
        ],
        ingredients: [
            .chemical(ChemicalIngredient(
                id: "ing-cc-001",
                eNumber: nil,
                name: "Koffein",
                description: "Natürliches Stimulans",
                category: .flavourEnhancer,
                function_: .flavouring,
                percentageInProduct: nil,
                origin: .synthetic,
                isSynthetic: true,
                euRegulatoryStatus: .approved,
                healthAssessment: .safe,
                healthNotes: "ADI: 3 mg/kg KG",
                sensitiveGroups: ["Kinder", "Schwangere"],
                acceptableDailyIntakeKgBw: 3,
                maxAllowedMgPerKg: nil,
                actualMgPerKg: 120,
                efsaEvaluationUrl: nil,
                allowedInOrganic: false
            )),
            .chemical(ChemicalIngredient(
                id: "ing-cc-002",
                eNumber: "E338",
                name: "Phosphorsäure",
                description: "Säuerungsmittel",
                category: .acidityRegulator,
                function_: .acidifying,
                percentageInProduct: nil,
                origin: .synthetic,
                isSynthetic: true,
                euRegulatoryStatus: .approvedWithAdi,
                healthAssessment: .caution,
                healthNotes: nil,
                sensitiveGroups: [],
                acceptableDailyIntakeKgBw: nil,
                maxAllowedMgPerKg: nil,
                actualMgPerKg: nil,
                efsaEvaluationUrl: nil,
                allowedInOrganic: false
            ))
        ],
        requiresColdChain: false,
        coldChainSummary: .notRequired
    )
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: TRACE: Ovomaltine Pulver 500g
// MARK: ══════════════════════════════════════════════════════════

enum MockTraceOvomaltine {

    // MARK: Certifications
    static let certIPSuisse = TomapoCertification(
        id: "cert-ipsuisse-001",
        type: .ipSuisse,
        name: "IP-Suisse",
        issuingBody: "IP-SUISSE",
        certificateNumber: nil,
        validFrom: date("2025-04-01T00:00:00Z"),
        validUntil: date("2026-03-31T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: nil,
        scope: .product,
        source: .thirdParty,
        offLabelTag: "en:ip-suisse"
    )

    static let certIFS = TomapoCertification(
        id: "cert-ifs-001",
        type: .ifs,
        name: "IFS Food",
        issuingBody: "Bureau Veritas",
        certificateNumber: nil,
        validFrom: date("2025-01-15T00:00:00Z"),
        validUntil: date("2027-01-15T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: "https://www.bureauveritas.ch/ifs/wander-001",
        scope: .facility,
        source: .thirdParty,
        offLabelTag: nil
    )

    // MARK: Stations
    static let stationFarming = TomapoStation(
        id: "sta-ovo-001",
        type: .farming,
        status: .completed,
        title: "Gerstenerzeugung CH",
        subtitle: "Anbau in der Schweiz",
        location: TomapoLocation(
            name: "Hof Müller",
            country: "CH",
            region: "Bern",
            city: "Lyss",
            address: nil,
            latitude: 47.0701,
            longitude: 7.3011,
            embCode: nil,
            gln: nil
        ),
        startedAt: date("2025-05-01T00:00:00Z"),
        completedAt: date("2025-08-31T00:00:00Z"),
        durationHours: 2208,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-ovo-001",
                type: .pesticideResidue,
                status: .passed,
                performedAt: date("2025-09-05T10:00:00Z"),
                performedBy: "Agroscope",
                accreditationNumber: "STS 0389",
                reportNumber: "AGRO-2025-0901",
                resultSummary: "Keine Pestizide über EU-Grenzwerten",
                detail: .chemical(ChemicalCheckDetail(
                    substancesTested: [
                        ChemicalSubstanceResult(substance: "Glyphosat",    category: .pesticide,    measuredMgPerKg: 0.002, limitMgPerKg: 0.1,  limitExceeded: false, unit: "mg/kg"),
                        ChemicalSubstanceResult(substance: "Chlorpyrifos", category: .pesticide,  measuredMgPerKg: 0.001, limitMgPerKg: 0.01, limitExceeded: false, unit: "mg/kg")
                    ],
                    laboratoryName: "Agroscope Liebefeld",
                    testMethod: "LC-MS/MS"
                )),
                nextCheckDue: nil,
                isMandatory: true
            )
        ],
        certificationIds: ["cert-ipsuisse-001"],
        co2KgPerKg: 0.89,
        environmentSummary: nil,
        detail: .farming(FarmingDetail(
            farmName: "Hof Müller, Lyss",
            farmingMethod: .integrated,
            cropYear: 2025,
            animalSpecies: nil,
            husbandrySystem: nil,
            areaHectares: 4.2,
            fertilizerTypes: [.synthetic],
            pesticideTypes: [],
            fieldCoordinates: [FieldCoordinate(latitude: 47.0701, longitude: 7.3011)],
            irrigationType: .none,
            soilType: nil,
            plantingDate: date("2025-05-01T00:00:00Z"),
            expectedHarvestStart: date("2025-08-01T00:00:00Z"),
            expectedHarvestEnd: date("2025-08-31T00:00:00Z")
        )),
        isVerified: true,
        verifiedBy: "IP-SUISSE",
        notes: "Schweizer Sommergerste, IP-SUISSE zertifiziert",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationProcessing = TomapoStation(
        id: "sta-ovo-002",
        type: .processing,
        status: .completed,
        title: "Produktion Neuenegg",
        subtitle: "Wander AG Hauptwerk",
        location: TomapoLocation(
            name: "Wander AG",
            country: "CH",
            region: "Bern",
            city: "Neuenegg",
            address: "Wander-Strasse 1, 3176 Neuenegg",
            latitude: 46.9000,
            longitude: 7.3167,
            embCode: "CH-BE 001",
            gln: "7610305000010"
        ),
        startedAt: date("2026-02-20T06:00:00Z"),
        completedAt: date("2026-03-01T14:00:00Z"),
        durationHours: 248,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-ovo-002",
                type: .nutritionAnalysis,
                status: .passed,
                performedAt: date("2026-02-28T09:00:00Z"),
                performedBy: "Wander QA Labor",
                accreditationNumber: "STS 0459",
                reportNumber: "WANDER-QC-2026-028",
                resultSummary: "Nährwertangaben innerhalb Toleranz",
                detail: .nutritional(NutritionalCheckDetail(
                    energyKcal: 385,
                    fatG: 6.6,
                    saturatedFatG: 3.0,
                    carbohydratesG: 67.1,
                    sugarsG: 38.2,
                    fiberG: 4.5,
                    proteinsG: 14.1,
                    saltG: 0.39,
                    deviationFromLabelPercent: nil,
                    deviationAcceptable: true
                )),
                nextCheckDue: date("2026-05-28T09:00:00Z"),
                isMandatory: true
            )
        ],
        certificationIds: ["cert-ifs-001"],
        co2KgPerKg: 1.2,
        environmentSummary: nil,
        detail: .processing(ProcessingDetail(
            facilityName: "Wander AG Neuenegg",
            facilityEmbCode: nil,
            processTypes: [.mixing],
            processingTemperatureCelsius: nil,
            pasteurization: nil,
            sterilization: nil,
            additivesAdded: [],
            isHaccpCertified: true,
            foodSafetyStandard: .ifsFood,
            batchSizeKg: nil
        )),
        isVerified: true,
        verifiedBy: "SGS SA",
        notes: "IFS Food zertifiziertes Werk, Charge OVO-2026-0301",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationRetail = TomapoStation(
        id: "sta-ovo-003",
        type: .retailDisplay,
        status: .completed,
        title: "Coop Supermarkt Bern",
        subtitle: "POS Bern Zentrum",
        location: TomapoLocation(
            name: "Coop Bern Zentrum",
            country: "CH",
            region: "Bern",
            city: "Bern",
            address: "Neuengasse 23, 3011 Bern",
            latitude: 46.9481,
            longitude: 7.4474,
            embCode: nil,
            gln: "7610200010001"
        ),
        startedAt: date("2026-03-05T05:00:00Z"),
        completedAt: nil,
        durationHours: nil,
        qualityChecks: [],
        certificationIds: [],
        co2KgPerKg: 0.03,
        environmentSummary: nil,
        detail: .retail(RetailDetail(
            storeName: "Coop Bern Zentrum",
            storeChain: "Coop",
            storeGln: "7610200010001",
            displayType: .ambient,
            displayTemperatureCelsius: 18,
            firstOnShelfDate: date("2026-03-05T05:00:00Z"),
            bestBeforeDate: date("2027-01-01T00:00:00Z"),
            priceChf: nil
        )),
        isVerified: false,
        verifiedBy: nil,
        notes: nil,
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    // MARK: Response
    static let response = TomapoResponse(
        barcode: "7610305001002",
        batchId: "OVO-2026-0301",
        generatedAt: date("2026-03-05T07:00:00Z"),
        productName: "Ovomaltine Pulver",
        genericName: "Malzgetränkepulver",
        brands: "Ovomaltine",
        quantity: "500g",
        productQuantity: 500,
        productQuantityUnit: "g",
        servingSize: "23g",
        servingQuantity: 23,
        storesTags: ["coop", "migros"],
        imageUrl: "https://images.openfoodfacts.org/images/products/761/030/500/1002/front.jpg",
        imageFrontUrl: "https://images.openfoodfacts.org/images/products/761/030/500/1002/front.jpg",
        imageIngredientsUrl: nil,
        imageNutritionUrl: nil,
        imagePackagingUrl: nil,
        categoriesTags: ["en:beverages", "en:hot-beverages", "en:cocoa-powders"],
        foodGroupsTags: ["en:cocoa-and-chocolate-products"],
        foodGroups: "Cocoa and chocolate products",
        pnnsGroups1: "Beverages",
        pnnsGroups2: "Hot beverages",
        nutriscoreGrade: "c",
        nutriscoreScore: 8,
        ecoscoreGrade: "b",
        ecoscoreScore: 62,
        novaGroup: 3,
        novaGroupError: nil,
        nutriments: ProductNutriments(
            energyKcal100g: 385,
            energyKj100g: 1620,
            energyKcalServing: 89,
            energyKjServing: 373,
            fat100g: 6.6,
            saturatedFat100g: 3.0,
            fatServing: 1.5,
            saturatedFatServing: 0.7,
            carbohydrates100g: 67.1,
            sugars100g: 38.2,
            fiber100g: 4.5,
            addedSugars100g: nil,
            starch100g: nil,
            carbohydratesServing: 15.4,
            sugarsServing: 8.8,
            fiberServing: 1.0,
            proteins100g: 14.1,
            proteinsServing: 3.2,
            salt100g: 0.39,
            sodium100g: 0.15,
            saltServing: 0.09,
            sodiumServing: 0.035,
            novaGroup100g: 3
        ),
        nutrientLevels: ProductNutrientLevels(
            fat: "low",
            saturatedFat: "low",
            sugars: "high",
            salt: "low"
        ),
        ingredientsText: "Gerstenmalzextrakt, Zucker, Magermilchpulver, Kakaopulver, Hafermehl, Weizenmehl, Vitaminkomplex",
        rawIngredients: nil,
        ingredientsN: 12,
        additivesN: 0,
        additivesTags: [],
        allergensTags: ["en:gluten", "en:milk"],
        tracesTags: [],
        ingredientsAnalysisTags: ["en:non-vegan"],
        labelsTags: ["en:ip-suisse"],
        countriesTags: ["en:switzerland"],
        originsTags: ["en:switzerland"],
        manufacturingPlaces: "Neuenegg, Schweiz",
        manufacturingPlacesTags: ["en:neuenegg"],
        packagingTags: ["en:cardboard", "en:recyclable"],
        packagings: nil,
        packagingText: "Kartonverpackung",
        conservationConditions: "Trocken und kühl lagern",
        dataQualityErrorsTags: [],
        dataQualityWarningsTags: [],
        completeness: 0.91,
        alerts: [MockAlerts.infoOvomaltine],
        stations: [stationFarming, stationProcessing, stationRetail],
        environmentSummary: TomapoEnvironmentSummary(
            co2ByPhase: CO2ByPhase(
                agriculture: 0.89,
                processing: 1.2,
                transportation: 0.055,
                packaging: 0.09,
                distribution: 0.03,
                consumption: nil
            ),
            co2TotalKgPerKg: 2.12,
            ecoscoreGrade: "b",
            ecoscoreScore: 62,
            waterFootprintLiterPerKg: 1240,
            waterStressScore: 0.41,
            forestFootprintM2PerKg: 0.08,
            forestFootprintGrade: "b",
            deforestationRisk: 0.12,
            transportEmissionsGramsCo2: 55,
            totalTransportDistanceKm: 180,
            transportLegCount: 3,
            packagingCo2Kg: 0.09,
            packagingScore: 72,
            recyclablePackagingPercent: 1.0,
            threatenedSpeciesRisk: nil,
            productionSystemBonus: 5,
            originEpiScore: 68
        ),
        certifications: [certIPSuisse, certIFS],
        traceabilityScore: TomapoTraceabilityScore(
            completeness: 0.91,
            verifiedStations: 2,
            unknownStations: 0,
            hasGaps: false,
            isThirdPartyVerified: true,
            blockchainHash: "0x3a8f2c1d4e5b6a7c8d9e0f1a2b3c4d5e6f7a8b9c"
        ),
        dataSources: [
            TomapoDataSource(id: "ds-ovo-001", name: "Wander AG",    type: .manufacturer,  lastSynced: date("2026-03-05T07:00:00Z"), reliability: .verified),
            TomapoDataSource(id: "ds-ovo-002", name: "IP-SUISSE",    type: .certification, lastSynced: date("2026-03-05T07:01:00Z"), reliability: .official)
        ],
        ingredients: [
            .subProduct(SubProductIngredient(
                id: "ing-ovo-001",
                barcode: "0000000000000",
                batchId: nil,
                name: "Schweizer Gerste",
                description: nil,
                category: .grains,
                percentageInProduct: 36,
                originCountry: "CH",
                originRegion: "Bern",
                supplierName: "Hof Müller, Lyss",
                supplierCountry: "CH",
                imageUrl: nil,
                certifications: [certIPSuisse],
                traceData: nil
            )),
            .subProduct(SubProductIngredient(
                id: "ing-ovo-002",
                barcode: "0000000000001",
                batchId: nil,
                name: "Kakao",
                description: nil,
                category: .cocoa,
                percentageInProduct: 12,
                originCountry: "CI",
                originRegion: nil,
                supplierName: nil,
                supplierCountry: nil,
                imageUrl: nil,
                certifications: [],
                traceData: nil
            ))
        ],
        requiresColdChain: false,
        coldChainSummary: .notRequired
    )
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: TRACE: Migros Vollmilch 1L  (Kühlkette aktiv)
// MARK: ══════════════════════════════════════════════════════════

enum MockTraceMigrosMilch {

    // MARK: Certifications
    static let certHeumilch = TomapoCertification(
        id: "cert-heumilch-001",
        type: .animalWelfare,
        name: "Schweizer Heumilch",
        issuingBody: "IG Schweizer Heumilch",
        certificateNumber: nil,
        validFrom: date("2025-03-01T00:00:00Z"),
        validUntil: date("2026-02-28T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: nil,
        scope: .product,
        source: .thirdParty,
        offLabelTag: nil
    )

    static let certISO22000 = TomapoCertification(
        id: "cert-iso22000-002",
        type: .iso22000,
        name: "ISO 22000",
        issuingBody: "SGS SA",
        certificateNumber: nil,
        validFrom: date("2023-09-01T00:00:00Z"),
        validUntil: date("2026-09-01T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: "https://www.sgs.com/certifications/iso22000/migros-molkerei-001",
        scope: .facility,
        source: .thirdParty,
        offLabelTag: nil
    )

    // MARK: Kühlketten-Sensorlog
    private static let sensorLog: [SensorReading] = [
        SensorReading(timestamp: date("2026-03-20T02:00:00Z"), temperatureCelsius: 3.8, humidity: 85, isWithinRange: true),
        SensorReading(timestamp: date("2026-03-20T04:00:00Z"), temperatureCelsius: 4.2, humidity: 83, isWithinRange: true),
        SensorReading(timestamp: date("2026-03-20T06:00:00Z"), temperatureCelsius: 5.1, humidity: 82, isWithinRange: true),
        SensorReading(timestamp: date("2026-03-20T08:00:00Z"), temperatureCelsius: 4.0, humidity: 84, isWithinRange: true)
    ]

    // MARK: Stations
    static let stationFarming = TomapoStation(
        id: "sta-milch-001",
        type: .farming,
        status: .completed,
        title: "Milchwirtschaft Emmental",
        subtitle: "Schweizer Heumilch-Betrieb",
        location: TomapoLocation(
            name: "Alpbetrieb Zimmermann",
            country: "CH",
            region: "Bern",
            city: "Langnau im Emmental",
            address: nil,
            latitude: 46.9394,
            longitude: 7.7879,
            embCode: nil,
            gln: nil
        ),
        startedAt: date("2026-03-18T04:00:00Z"),
        completedAt: date("2026-03-18T18:00:00Z"),
        durationHours: 14,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-milch-001",
                type: .microbiologicalTest,
                status: .passed,
                performedAt: date("2026-03-18T19:00:00Z"),
                performedBy: "Molkerei Qualitätskontrolle",
                accreditationNumber: "STS 0501",
                reportNumber: "MK-2026-0318-001",
                resultSummary: "Keimzahl und somatische Zellen im Normbereich",
                detail: .microbiological(MicrobiologicalCheckDetail(
                    pathogensTested: [
                        PathogenResult(pathogen: "Listeria monocytogenes", detected: false, cfu: 0,  limit: 0,   limitExceeded: false),
                        PathogenResult(pathogen: "Staphylococcus aureus",  detected: false, cfu: 10, limit: 500, limitExceeded: false)
                    ],
                    totalBacterialCount: nil,
                    laboratoryName: "Schweizer Milchproduzenten SMP",
                    iso17025Accredited: true
                )),
                nextCheckDue: date("2026-04-18T00:00:00Z"),
                isMandatory: true
            )
        ],
        certificationIds: ["cert-heumilch-001"],
        co2KgPerKg: 1.85,
        environmentSummary: nil,
        detail: .farming(FarmingDetail(
            farmName: "Alpbetrieb Zimmermann",
            farmingMethod: .conventional,
            cropYear: nil,
            animalSpecies: "Rind",
            husbandrySystem: .freeRange,
            areaHectares: 18.5,
            fertilizerTypes: [.organic],
            pesticideTypes: [],
            fieldCoordinates: [FieldCoordinate(latitude: 46.9394, longitude: 7.7879)],
            irrigationType: .none,
            soilType: nil,
            plantingDate: nil,
            expectedHarvestStart: nil,
            expectedHarvestEnd: nil
        )),
        isVerified: true,
        verifiedBy: "BioSuisse",
        notes: "Heumilchbetrieb, Alpweidehaltung",
        wasRefrigerated: true,
        refrigerationTemperatureCelsius: 4
    )

    static let stationPasteurization = TomapoStation(
        id: "sta-milch-002",
        type: .processing,
        status: .completed,
        title: "Pasteurisierung Zürich",
        subtitle: "Molkerei & Abfüllung",
        location: TomapoLocation(
            name: "Molkerei Zürich",
            country: "CH",
            region: "Zürich",
            city: "Zürich",
            address: "Buckhauserstrasse 19, 8048 Zürich",
            latitude: 47.3785,
            longitude: 8.4980,
            embCode: "CH-ZH 002 EG",
            gln: "7610815000001"
        ),
        startedAt: date("2026-03-19T02:00:00Z"),
        completedAt: date("2026-03-19T18:00:00Z"),
        durationHours: 16,
        qualityChecks: [],
        certificationIds: ["cert-iso22000-002"],
        co2KgPerKg: 0.12,
        environmentSummary: nil,
        detail: .processing(ProcessingDetail(
            facilityName: "Molkerei Zürich Altstetten",
            facilityEmbCode: "CH-ZH 002 EG",
            processTypes: [.pasteurization],
            processingTemperatureCelsius: 72,
            pasteurization: PasteurizationDetail(
                temperatureCelsius: 72,
                durationSeconds: 15,
                method: .htst
            ),
            sterilization: nil,
            additivesAdded: [],
            isHaccpCertified: true,
            foodSafetyStandard: .fssc22000,
            batchSizeKg: nil
        )),
        isVerified: true,
        verifiedBy: "Migros Qualität AG",
        notes: "HTST-Pasteurisierung 72°C / 15 Sek.",
        wasRefrigerated: true,
        refrigerationTemperatureCelsius: 4
    )

    static let stationTransport = TomapoStation(
        id: "sta-milch-003",
        type: .refrigeratedTruck,
        status: .completed,
        title: "Kühllieferung Migros Filialen",
        subtitle: "Kühlkette Zürich Region",
        location: nil,
        startedAt: date("2026-03-20T02:00:00Z"),
        completedAt: date("2026-03-20T08:00:00Z"),
        durationHours: 6,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-milch-002",
                type: .temperatureLog,
                status: .passed,
                performedAt: date("2026-03-20T08:00:00Z"),
                performedBy: "Camion Transport Fahrenheit System",
                accreditationNumber: nil,
                reportNumber: "CT-2026-0320-099",
                resultSummary: "Temperatur durchgehend 2–5°C",
                detail: .temperature(TemperatureCheckDetail(
                    measuredCelsius: 4.1,
                    minAllowedCelsius: 2,
                    maxAllowedCelsius: 6,
                    isWithinRange: true,
                    sensorId: "SENS-CT-0042",
                    log: sensorLog
                )),
                nextCheckDue: nil,
                isMandatory: true
            )
        ],
        certificationIds: [],
        co2KgPerKg: 0.03,
        environmentSummary: nil,
        detail: .transport(TransportDetail(
            mode: .refrigeratedTruck,
            carrierName: "Camion Transport AG",
            trackingId: nil,
            originLocation: nil,
            destinationLocation: nil,
            distanceKm: 95,
            isRefrigerated: true,
            coldStorageDetail: ColdStorageDetail(
                facilityName: nil,
                targetTemperatureCelsius: 4,
                minActualTemperatureCelsius: 2.0,
                maxActualTemperatureCelsius: 5.1,
                avgActualTemperatureCelsius: 4.0,
                coldChainBroken: false,
                coldChainBreaks: [],
                sensorId: "SENS-CT-0042",
                lastSensorReading: sensorLog.last
            ),
            co2EmissionsKg: 0.03,
            vehicleType: "Kühlfahrzeug",
            fuelType: .diesel,
            scheduledArrival: nil,
            actualArrival: date("2026-03-20T08:00:00Z"),
            delayReasons: []
        )),
        isVerified: true,
        verifiedBy: "Camion Transport AG",
        notes: "Durchgehende Kühlkette 2–6°C",
        wasRefrigerated: true,
        refrigerationTemperatureCelsius: 4
    )

    // MARK: Response
    static let response = TomapoResponse(
        barcode: "7610815001032",
        batchId: "MILCH-2026-0320",
        generatedAt: date("2026-03-20T04:00:00Z"),
        productName: "Migros Vollmilch",
        genericName: "Pasteurisierte Vollmilch",
        brands: "Migros",
        quantity: "1L",
        productQuantity: 1000,
        productQuantityUnit: "ml",
        servingSize: "200ml",
        servingQuantity: 200,
        storesTags: ["migros"],
        imageUrl: nil,
        imageFrontUrl: nil,
        imageIngredientsUrl: nil,
        imageNutritionUrl: nil,
        imagePackagingUrl: nil,
        categoriesTags: ["en:milks", "en:whole-milks", "en:dairy"],
        foodGroupsTags: ["en:dairy"],
        foodGroups: "Dairy",
        pnnsGroups1: "Milk and dairy products",
        pnnsGroups2: "Milk",
        nutriscoreGrade: "b",
        nutriscoreScore: 1,
        ecoscoreGrade: "c",
        ecoscoreScore: 45,
        novaGroup: 1,
        novaGroupError: nil,
        nutriments: ProductNutriments(
            energyKcal100g: 64,
            energyKj100g: 268,
            energyKcalServing: 128,
            energyKjServing: 536,
            fat100g: 3.6,
            saturatedFat100g: 2.3,
            fatServing: 7.2,
            saturatedFatServing: 4.6,
            carbohydrates100g: 4.8,
            sugars100g: 4.8,
            fiber100g: 0,
            addedSugars100g: 0,
            starch100g: nil,
            carbohydratesServing: 9.6,
            sugarsServing: 9.6,
            fiberServing: nil,
            proteins100g: 3.3,
            proteinsServing: 6.6,
            salt100g: 0.1,
            sodium100g: 0.04,
            saltServing: 0.2,
            sodiumServing: 0.08,
            novaGroup100g: 1
        ),
        nutrientLevels: ProductNutrientLevels(
            fat: "moderate",
            saturatedFat: "high",
            sugars: "low",
            salt: "low"
        ),
        ingredientsText: "Vollmilch",
        rawIngredients: nil,
        ingredientsN: 1,
        additivesN: 0,
        additivesTags: [],
        allergensTags: ["en:milk"],
        tracesTags: [],
        ingredientsAnalysisTags: ["en:non-vegan"],
        labelsTags: ["en:swiss-made"],
        countriesTags: ["en:switzerland"],
        originsTags: ["en:switzerland"],
        manufacturingPlaces: "Zürich, Schweiz",
        manufacturingPlacesTags: ["en:zurich"],
        packagingTags: ["en:tetra-pak", "en:recyclable"],
        packagings: nil,
        packagingText: "Tetra Pak",
        conservationConditions: "Gekühlt lagern (2–6°C). Nach dem Öffnen innerhalb von 3 Tagen verbrauchen.",
        dataQualityErrorsTags: [],
        dataQualityWarningsTags: [],
        completeness: 0.94,
        alerts: [MockAlerts.migrosQuality, MockAlerts.communityMilch],
        stations: [stationFarming, stationPasteurization, stationTransport],
        environmentSummary: TomapoEnvironmentSummary(
            co2ByPhase: CO2ByPhase(
                agriculture: 1.85,
                processing: 0.12,
                transportation: 0.03,
                packaging: 0.04,
                distribution: 0.03,
                consumption: nil
            ),
            co2TotalKgPerKg: 2.0,
            ecoscoreGrade: "c",
            ecoscoreScore: 45,
            waterFootprintLiterPerKg: 631,
            waterStressScore: 0.38,
            forestFootprintM2PerKg: nil,
            forestFootprintGrade: nil,
            deforestationRisk: nil,
            transportEmissionsGramsCo2: 30,
            totalTransportDistanceKm: 95,
            transportLegCount: 1,
            packagingCo2Kg: 0.04,
            packagingScore: 68,
            recyclablePackagingPercent: 1.0,
            threatenedSpeciesRisk: nil,
            productionSystemBonus: 3,
            originEpiScore: 72
        ),
        certifications: [certHeumilch, certISO22000],
        traceabilityScore: TomapoTraceabilityScore(
            completeness: 0.94,
            verifiedStations: 3,
            unknownStations: 0,
            hasGaps: false,
            isThirdPartyVerified: true,
            blockchainHash: nil
        ),
        dataSources: [
            TomapoDataSource(id: "ds-milch-001", name: "Migros Genossenschafts-Bund", type: .manufacturer, lastSynced: date("2026-03-20T04:00:00Z"), reliability: .verified)
        ],
        ingredients: [
            .subProduct(SubProductIngredient(
                id: "ing-milch-001",
                barcode: "0000000000002",
                batchId: nil,
                name: "Schweizer Rohmilch",
                description: nil,
                category: .dairy,
                percentageInProduct: 100,
                originCountry: "CH",
                originRegion: "Bern",
                supplierName: "Alpbetrieb Zimmermann",
                supplierCountry: "CH",
                imageUrl: nil,
                certifications: [certHeumilch],
                traceData: nil
            ))
        ],
        requiresColdChain: true,
        coldChainSummary: TomapoColdChainSummary(
            isIntact: true,
            refrigeratedStationCount: 3,
            unrefrigeratedStationCount: 0,
            lowestTemperatureCelsius: 2.0,
            highestTemperatureCelsius: 5.1,
            hadColdChainBreak: false,
            coldChainBreakCount: 0,
            totalBreakDurationMinutes: nil,
            totalRefrigeratedTransportHours: 36,
            summaryText: "Lückenlos · 3 Stationen · max. 5.1°C"
        )
    )
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: TRACE: Lindt Excellence 85% (aktiver BLV-Rückruf)
// MARK: ══════════════════════════════════════════════════════════

enum MockTraceLindt {

    // MARK: Certifications
    static let certRA = TomapoCertification(
        id: "cert-ra-001",
        type: .rainforestAlliance,
        name: "Rainforest Alliance",
        issuingBody: "Rainforest Alliance",
        certificateNumber: nil,
        validFrom: date("2024-09-01T00:00:00Z"),
        validUntil: date("2026-08-31T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: "https://www.rainforest-alliance.org/certificate/lindt-001",
        scope: .product,
        source: .thirdParty,
        offLabelTag: "en:rainforest-alliance"
    )

    // MARK: Stations
    static let stationKakao = TomapoStation(
        id: "sta-lindt-001",
        type: .farming,
        status: .completed,
        title: "Kakaoplantage Ghana",
        subtitle: "Rainforest Alliance zertifiziert",
        location: TomapoLocation(
            name: "Cocoa Farmers Cooperative Ashanti",
            country: "GH",
            region: "Ashanti",
            city: "Kumasi",
            address: nil,
            latitude: 6.6882,
            longitude: -1.6244,
            embCode: nil,
            gln: nil
        ),
        startedAt: date("2025-09-01T00:00:00Z"),
        completedAt: date("2025-11-30T00:00:00Z"),
        durationHours: 2160,
        qualityChecks: [],
        certificationIds: ["cert-ra-001"],
        co2KgPerKg: 2.1,
        environmentSummary: nil,
        detail: .farming(FarmingDetail(
            farmName: "Cooperative Ashanti Region",
            farmingMethod: .conventional,
            cropYear: 2025,
            animalSpecies: nil,
            husbandrySystem: nil,
            areaHectares: 2800,
            fertilizerTypes: [.organic],
            pesticideTypes: [],
            fieldCoordinates: [FieldCoordinate(latitude: 6.6882, longitude: -1.6244)],
            irrigationType: .rainFed,
            soilType: nil,
            plantingDate: nil,
            expectedHarvestStart: nil,
            expectedHarvestEnd: nil
        )),
        isVerified: true,
        verifiedBy: "Rainforest Alliance",
        notes: "Ashanti Region, Ghana. RA-zertifizierter Kooperativenbetrieb.",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationProduktion = TomapoStation(
        id: "sta-lindt-002",
        type: .processing,
        status: .completed,
        title: "Schokoladenproduktion Kilchberg",
        subtitle: "Lindt & Sprüngli Hauptwerk",
        location: TomapoLocation(
            name: "Lindt & Sprüngli AG",
            country: "CH",
            region: "Zürich",
            city: "Kilchberg",
            address: "Seestrasse 204, 8802 Kilchberg",
            latitude: 47.3228,
            longitude: 8.5489,
            embCode: "CH-ZH 008 EG",
            gln: "7610300000001"
        ),
        startedAt: date("2026-01-15T06:00:00Z"),
        completedAt: date("2026-02-10T18:00:00Z"),
        durationHours: 612,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-lindt-001",
                type: .heavyMetalTest,
                status: .passed,
                performedAt: date("2026-02-08T10:00:00Z"),
                performedBy: "Lindt QA",
                accreditationNumber: "STS 0620",
                reportNumber: "LINDT-QC-2026-0208",
                resultSummary: "Cadmium-Gehalt unter EU-Grenzwert",
                detail: .chemical(ChemicalCheckDetail(
                    substancesTested: [
                        ChemicalSubstanceResult(substance: "Cadmium", category: .heavyMetal, measuredMgPerKg: 0.28, limitMgPerKg: 0.80, limitExceeded: false, unit: "mg/kg"),
                        ChemicalSubstanceResult(substance: "Blei",    category: .heavyMetal, measuredMgPerKg: 0.04, limitMgPerKg: 0.10, limitExceeded: false, unit: "mg/kg")
                    ],
                    laboratoryName: "Lindt Internes Prüflabor",
                    testMethod: "ICP-MS"
                )),
                nextCheckDue: nil,
                isMandatory: true
            )
        ],
        certificationIds: [],
        co2KgPerKg: 0.65,
        environmentSummary: nil,
        detail: .processing(ProcessingDetail(
            facilityName: "Lindt & Sprüngli Kilchberg",
            facilityEmbCode: "CH-ZH 008 EG",
            processTypes: [.mixing],
            processingTemperatureCelsius: nil,
            pasteurization: nil,
            sterilization: nil,
            additivesAdded: [],
            isHaccpCertified: true,
            foodSafetyStandard: .ifsFood,
            batchSizeKg: nil
        )),
        isVerified: true,
        verifiedBy: "Bureau Veritas",
        notes: "Conchierzeit 72h für Excellence-Linie",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    // MARK: Response
    static let response = TomapoResponse(
        barcode: "3046920028836",
        batchId: "LINDT-85-2026-0201",
        generatedAt: date("2026-02-15T09:00:00Z"),
        productName: "Lindt Excellence 85% Cacao",
        genericName: "Dunkle Schokolade",
        brands: "Lindt",
        quantity: "100g",
        productQuantity: 100,
        productQuantityUnit: "g",
        servingSize: "10g",
        servingQuantity: 10,
        storesTags: ["migros", "coop", "denner"],
        imageUrl: "https://images.openfoodfacts.org/images/products/304/692/002/8836/front.jpg",
        imageFrontUrl: "https://images.openfoodfacts.org/images/products/304/692/002/8836/front.jpg",
        imageIngredientsUrl: nil,
        imageNutritionUrl: nil,
        imagePackagingUrl: nil,
        categoriesTags: ["en:chocolates", "en:dark-chocolates", "en:snacks"],
        foodGroupsTags: ["en:chocolate-products"],
        foodGroups: "Chocolate products",
        pnnsGroups1: "Sugary snacks",
        pnnsGroups2: "Chocolate products",
        nutriscoreGrade: "d",
        nutriscoreScore: 11,
        ecoscoreGrade: "c",
        ecoscoreScore: 41,
        novaGroup: 4,
        novaGroupError: nil,
        nutriments: ProductNutriments(
            energyKcal100g: 590,
            energyKj100g: 2460,
            energyKcalServing: 59,
            energyKjServing: 246,
            fat100g: 47,
            saturatedFat100g: 29,
            fatServing: 4.7,
            saturatedFatServing: 2.9,
            carbohydrates100g: 17,
            sugars100g: 9,
            fiber100g: 16,
            addedSugars100g: nil,
            starch100g: nil,
            carbohydratesServing: 1.7,
            sugarsServing: 0.9,
            fiberServing: 1.6,
            proteins100g: 12,
            proteinsServing: 1.2,
            salt100g: 0.02,
            sodium100g: 0.008,
            saltServing: 0.002,
            sodiumServing: 0.0008,
            novaGroup100g: 4
        ),
        nutrientLevels: ProductNutrientLevels(
            fat: "high",
            saturatedFat: "high",
            sugars: "moderate",
            salt: "low"
        ),
        ingredientsText: "Kakaomasse*, Kakaobutter*, Zucker*, Bourbon-Vanille*. *aus zertifiziertem Anbau.",
        rawIngredients: nil,
        ingredientsN: 4,
        additivesN: 0,
        additivesTags: [],
        allergensTags: ["en:milk"],
        tracesTags: ["en:nuts"],
        ingredientsAnalysisTags: ["en:non-vegan", "en:palm-oil-free"],
        labelsTags: ["en:rainforest-alliance"],
        countriesTags: ["en:switzerland"],
        originsTags: ["en:ghana", "en:switzerland"],
        manufacturingPlaces: "Kilchberg, Schweiz",
        manufacturingPlacesTags: ["en:kilchberg"],
        packagingTags: ["en:paper", "en:aluminium-foil"],
        packagings: nil,
        packagingText: "Papier/Aluminiumfolie",
        conservationConditions: "Kühl und trocken lagern (16–18°C).",
        dataQualityErrorsTags: [],
        dataQualityWarningsTags: [],
        completeness: 0.78,
        alerts: [MockAlerts.blvRecallLindt],
        stations: [stationKakao, stationProduktion],
        environmentSummary: TomapoEnvironmentSummary(
            co2ByPhase: CO2ByPhase(
                agriculture: 2.1,
                processing: 0.65,
                transportation: 0.185,
                packaging: 0.08,
                distribution: 0.02,
                consumption: nil
            ),
            co2TotalKgPerKg: 2.75,
            ecoscoreGrade: "c",
            ecoscoreScore: 41,
            waterFootprintLiterPerKg: 27015,
            waterStressScore: 0.6,
            forestFootprintM2PerKg: 22.0,
            forestFootprintGrade: "d",
            deforestationRisk: 0.45,
            transportEmissionsGramsCo2: 185,
            totalTransportDistanceKm: 6500,
            transportLegCount: 2,
            packagingCo2Kg: 0.08,
            packagingScore: 60,
            recyclablePackagingPercent: 0.8,
            threatenedSpeciesRisk: ThreatenedSpeciesRisk(
                ingredient: "Kakao",
                ecoscorePenalty: -8,
                explanation: "Kakaoproduktion in Ghana mit Risiko für Regenwaldflächen"
            ),
            productionSystemBonus: 0,
            originEpiScore: 38
        ),
        certifications: [certRA],
        traceabilityScore: TomapoTraceabilityScore(
            completeness: 0.78,
            verifiedStations: 2,
            unknownStations: 1,
            hasGaps: true,
            isThirdPartyVerified: true,
            blockchainHash: nil
        ),
        dataSources: [
            TomapoDataSource(id: "ds-lindt-001", name: "Lindt & Sprüngli AG", type: .manufacturer, lastSynced: date("2026-02-15T09:00:00Z"), reliability: .verified)
        ],
        ingredients: [
            .subProduct(SubProductIngredient(
                id: "ing-lindt-001",
                barcode: "0000000000003",
                batchId: nil,
                name: "Kakaomasse Ghana",
                description: nil,
                category: .cocoa,
                percentageInProduct: 85,
                originCountry: "GH",
                originRegion: "Ashanti",
                supplierName: "Cocoa Farmers Cooperative Ashanti",
                supplierCountry: "GH",
                imageUrl: nil,
                certifications: [certRA],
                traceData: nil
            )),
            .subProduct(SubProductIngredient(
                id: "ing-lindt-002",
                barcode: "0000000000004",
                batchId: nil,
                name: "Kakaobutter",
                description: nil,
                category: .cocoa,
                percentageInProduct: nil,
                originCountry: "GH",
                originRegion: nil,
                supplierName: nil,
                supplierCountry: nil,
                imageUrl: nil,
                certifications: [],
                traceData: nil
            ))
        ],
        requiresColdChain: false,
        coldChainSummary: .notRequired
    )
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: TRACE: El Tony Mate 330ml
// MARK: ══════════════════════════════════════════════════════════

enum MockTraceElTonyMate {

    // MARK: Certifications
    static let certRA = TomapoCertification(
        id: "cert-eltony-ra-001",
        type: .rainforestAlliance,
        name: "Rainforest Alliance",
        issuingBody: "Rainforest Alliance",
        certificateNumber: nil,
        validFrom: date("2024-09-01T00:00:00Z"),
        validUntil: date("2025-08-31T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: "https://www.rainforest-alliance.org/certificate/eltony-mate-001",
        scope: .product,
        source: .thirdParty,
        offLabelTag: "en:rainforest-alliance"
    )

    static let certBio = TomapoCertification(
        id: "cert-eltony-bio-001",
        type: .euOrganic,
        name: "EU Bio",
        issuingBody: "Bio Suisse",
        certificateNumber: nil,
        validFrom: date("2025-01-01T00:00:00Z"),
        validUntil: date("2025-12-31T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: nil,
        scope: .ingredient,
        source: .thirdParty,
        offLabelTag: "en:eu-organic"
    )

    static let certISO22000 = TomapoCertification(
        id: "cert-eltony-iso22000-001",
        type: .iso22000,
        name: "ISO 22000",
        issuingBody: "SGS SA",
        certificateNumber: nil,
        validFrom: date("2024-03-01T00:00:00Z"),
        validUntil: date("2027-03-01T00:00:00Z"),
        logoUrl: nil,
        verificationUrl: "https://www.sgs.com/certifications/iso22000/intelligentfood-001",
        scope: .facility,
        source: .thirdParty,
        offLabelTag: nil
    )

    // MARK: Stations
    static let stationMateFarm = TomapoStation(
        id: "sta-eltony-001",
        type: .farming,
        status: .completed,
        title: "Yerba Mate Ernte Misiones",
        subtitle: "Provinz Misiones, Argentinien",
        location: TomapoLocation(
            name: "Cooperativa Mate Misiones",
            country: "AR",
            region: "Misiones",
            city: "Posadas",
            address: nil,
            latitude: -27.3621,
            longitude: -55.8938,
            embCode: nil,
            gln: nil
        ),
        startedAt: date("2024-10-01T00:00:00Z"),
        completedAt: date("2024-11-30T00:00:00Z"),
        durationHours: 1464,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-eltony-001",
                type: .pesticideResidue,
                status: .passed,
                performedAt: date("2024-12-05T10:00:00Z"),
                performedBy: "SGS Argentina SA",
                accreditationNumber: "OAA-LA-0045",
                reportNumber: "SGS-ARG-2024-1205",
                resultSummary: "Keine Pestizid-Rückstände über EU-Grenzwerten. Koffeingehalt 23 mg/100ml bestätigt.",
                detail: .chemical(ChemicalCheckDetail(
                    substancesTested: [
                        ChemicalSubstanceResult(substance: "Glyphosat",    category: .pesticide,    measuredMgPerKg: 0.001, limitMgPerKg: 0.1,  limitExceeded: false, unit: "mg/kg"),
                        ChemicalSubstanceResult(substance: "Chlorpyrifos", category: .pesticide,  measuredMgPerKg: 0.000, limitMgPerKg: 0.01, limitExceeded: false, unit: "mg/kg"),
                        ChemicalSubstanceResult(substance: "Imidacloprid", category: .pesticide,  measuredMgPerKg: 0.002, limitMgPerKg: 0.05, limitExceeded: false, unit: "mg/kg")
                    ],
                    laboratoryName: "SGS Argentina SA",
                    testMethod: "LC-MS/MS"
                )),
                nextCheckDue: nil,
                isMandatory: true
            )
        ],
        certificationIds: ["cert-eltony-ra-001"],
        co2KgPerKg: 1.2,
        environmentSummary: nil,
        detail: .farming(FarmingDetail(
            farmName: "Cooperativa Mate Misiones",
            farmingMethod: .conventional,
            cropYear: 2024,
            animalSpecies: nil,
            husbandrySystem: nil,
            areaHectares: 320.0,
            fertilizerTypes: [.organic],
            pesticideTypes: [],
            fieldCoordinates: [FieldCoordinate(latitude: -27.3621, longitude: -55.8938)],
            irrigationType: .rainFed,
            soilType: nil,
            plantingDate: nil,
            expectedHarvestStart: date("2024-10-01T00:00:00Z"),
            expectedHarvestEnd: date("2024-11-30T00:00:00Z")
        )),
        isVerified: true,
        verifiedBy: "Rainforest Alliance",
        notes: "Traditioneller Anbau in der feuchten subtropischen Klimazone. Schattenanbau unter Baumkronen.",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationGuarana = TomapoStation(
        id: "sta-eltony-002",
        type: .farming,
        status: .completed,
        title: "Guarana-Anbau Maués",
        subtitle: "Amazonas, Brasilien",
        location: TomapoLocation(
            name: "Associação dos Produtores de Guaraná de Maués",
            country: "BR",
            region: "Amazonas",
            city: "Maués",
            address: nil,
            latitude: -3.3842,
            longitude: -57.7178,
            embCode: nil,
            gln: nil
        ),
        startedAt: date("2024-08-01T00:00:00Z"),
        completedAt: date("2024-10-15T00:00:00Z"),
        durationHours: 1836,
        qualityChecks: [],
        certificationIds: [],
        co2KgPerKg: 0.8,
        environmentSummary: nil,
        detail: .farming(FarmingDetail(
            farmName: "Associação Maués",
            farmingMethod: .conventional,
            cropYear: 2024,
            animalSpecies: nil,
            husbandrySystem: nil,
            areaHectares: 45.0,
            fertilizerTypes: [.organic],
            pesticideTypes: [],
            fieldCoordinates: [FieldCoordinate(latitude: -3.3842, longitude: -57.7178)],
            irrigationType: .rainFed,
            soilType: nil,
            plantingDate: nil,
            expectedHarvestStart: nil,
            expectedHarvestEnd: nil
        )),
        isVerified: false,
        verifiedBy: nil,
        notes: "Guaranaextrakt 0.1% im Endprodukt. Natürliche Koffeinquelle.",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationZucker = TomapoStation(
        id: "sta-eltony-003",
        type: .processing,
        status: .completed,
        title: "Bio-Rohrzucker Produktion",
        subtitle: "São Paulo State, Brasilien",
        location: TomapoLocation(
            name: "Usina São Martinho",
            country: "BR",
            region: "São Paulo",
            city: "Pradópolis",
            address: nil,
            latitude: -21.3667,
            longitude: -48.0667,
            embCode: nil,
            gln: nil
        ),
        startedAt: date("2025-01-10T06:00:00Z"),
        completedAt: date("2025-01-20T18:00:00Z"),
        durationHours: 252,
        qualityChecks: [],
        certificationIds: ["cert-eltony-bio-001"],
        co2KgPerKg: 0.35,
        environmentSummary: nil,
        detail: .processing(ProcessingDetail(
            facilityName: "Usina São Martinho",
            facilityEmbCode: nil,
            processTypes: [.extraction],
            processingTemperatureCelsius: nil,
            pasteurization: nil,
            sterilization: nil,
            additivesAdded: [],
            isHaccpCertified: true,
            foodSafetyStandard: .fssc22000,
            batchSizeKg: nil
        )),
        isVerified: true,
        verifiedBy: "Bureau Veritas Brasil",
        notes: "Biologischer Rohrzucker, EU-Bio-Zertifizierung. Keine Bleichung oder chemische Raffination.",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationAbfuellung = TomapoStation(
        id: "sta-eltony-004",
        type: .processing,
        status: .completed,
        title: "Cold Brew & Abfüllung Zürich",
        subtitle: "intelligentfood AG, Zürich",
        location: TomapoLocation(
            name: "intelligentfood AG",
            country: "CH",
            region: "Zürich",
            city: "Zürich",
            address: "Hardturmstrasse 161, 8005 Zürich",
            latitude: 47.3892,
            longitude: 8.5190,
            embCode: "CH-ZH 015 EG",
            gln: "7640150490001"
        ),
        startedAt: date("2025-06-01T06:00:00Z"),
        completedAt: date("2025-06-03T14:00:00Z"),
        durationHours: 56,
        qualityChecks: [
            TomapoQualityCheck(
                id: "qc-eltony-002",
                type: .microbiologicalTest,
                status: .passed,
                performedAt: date("2025-06-03T07:00:00Z"),
                performedBy: "intelligentfood AG QC Labor",
                accreditationNumber: "STS 0612",
                reportNumber: "IFG-QC-2025-L250634716",
                resultSummary: "Keine pathogenen Keime nachgewiesen. Koffeingehalt 23 mg/100ml. pH 3.8. Pasteurisiert.",
                detail: .microbiological(MicrobiologicalCheckDetail(
                    pathogensTested: [
                        PathogenResult(pathogen: "E. coli",               detected: false, cfu: 0, limit: 100, limitExceeded: false),
                        PathogenResult(pathogen: "Salmonella spp.",        detected: false, cfu: 0, limit: 0,   limitExceeded: false),
                        PathogenResult(pathogen: "Listeria monocytogenes", detected: false, cfu: 0, limit: 0,   limitExceeded: false)
                    ],
                    totalBacterialCount: nil,
                    laboratoryName: "intelligentfood AG Internes Labor",
                    iso17025Accredited: true
                )),
                nextCheckDue: date("2025-09-03T00:00:00Z"),
                isMandatory: true
            ),
            TomapoQualityCheck(
                id: "qc-eltony-003",
                type: .nutritionAnalysis,
                status: .passed,
                performedAt: date("2025-06-03T08:00:00Z"),
                performedBy: "SQTS Swiss Quality Testing Services",
                accreditationNumber: "STS 0492",
                reportNumber: "SQTS-2025-0603-001",
                resultSummary: "Nährwerte innerhalb EU-Toleranz. Koffein- und Guaranagehalt deklarationskonform.",
                detail: .nutritional(NutritionalCheckDetail(
                    energyKcal: 24,
                    fatG: 0.5,
                    saturatedFatG: 0.1,
                    carbohydratesG: 5.8,
                    sugarsG: 5.8,
                    fiberG: nil,
                    proteinsG: 0.5,
                    saltG: 0.01,
                    deviationFromLabelPercent: nil,
                    deviationAcceptable: true
                )),
                nextCheckDue: nil,
                isMandatory: true
            )
        ],
        certificationIds: ["cert-eltony-iso22000-001"],
        co2KgPerKg: 0.09,
        environmentSummary: nil,
        detail: .processing(ProcessingDetail(
            facilityName: "intelligentfood AG Zürich",
            facilityEmbCode: "CH-ZH 015 EG",
            processTypes: [.pasteurization, .filtration],
            processingTemperatureCelsius: 4,
            pasteurization: nil,
            sterilization: nil,
            additivesAdded: [],
            isHaccpCertified: true,
            foodSafetyStandard: .ifsFood,
            batchSizeKg: nil
        )),
        isVerified: true,
        verifiedBy: "SGS SA Zürich",
        notes: "Cold Brew Verfahren: Mate-Tee wird bei 4°C für 12–24h aufgebrüht. Charge L250634716:41. Pasteurisiert.",
        wasRefrigerated: true,
        refrigerationTemperatureCelsius: 4
    )

    static let stationTransport = TomapoStation(
        id: "sta-eltony-005",
        type: .truckTransport,
        status: .completed,
        title: "Logistik Schweiz",
        subtitle: "Lager → Coop / Migros Filialen",
        location: nil,
        startedAt: date("2025-06-04T04:00:00Z"),
        completedAt: date("2025-06-04T18:00:00Z"),
        durationHours: 14,
        qualityChecks: [],
        certificationIds: [],
        co2KgPerKg: 0.03,
        environmentSummary: nil,
        detail: .transport(TransportDetail(
            mode: .truck,
            carrierName: "Planzer Transport AG",
            trackingId: nil,
            originLocation: nil,
            destinationLocation: nil,
            distanceKm: 180,
            isRefrigerated: false,
            coldStorageDetail: nil,
            co2EmissionsKg: 0.03,
            vehicleType: "LKW",
            fuelType: .diesel,
            scheduledArrival: nil,
            actualArrival: date("2025-06-04T18:00:00Z"),
            delayReasons: []
        )),
        isVerified: false,
        verifiedBy: nil,
        notes: "Kühlunbedürftiges Produkt. Raumtemperatur-Transport.",
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    static let stationRetail = TomapoStation(
        id: "sta-eltony-006",
        type: .retailDisplay,
        status: .completed,
        title: "Coop City Zürich Bellevue",
        subtitle: "Einzelhandel Schweiz",
        location: TomapoLocation(
            name: "Coop City Zürich Bellevue",
            country: "CH",
            region: "Zürich",
            city: "Zürich",
            address: "Theaterstrasse 12, 8001 Zürich",
            latitude: 47.3663,
            longitude: 8.5447,
            embCode: nil,
            gln: "7610200020001"
        ),
        startedAt: date("2025-06-05T05:00:00Z"),
        completedAt: nil,
        durationHours: nil,
        qualityChecks: [],
        certificationIds: [],
        co2KgPerKg: 0.02,
        environmentSummary: nil,
        detail: .retail(RetailDetail(
            storeName: "Coop City Zürich Bellevue",
            storeChain: "Coop",
            storeGln: "7610200020001",
            displayType: .ambient,
            displayTemperatureCelsius: 18,
            firstOnShelfDate: date("2025-06-05T05:00:00Z"),
            bestBeforeDate: nil,
            priceChf: nil
        )),
        isVerified: false,
        verifiedBy: nil,
        notes: nil,
        wasRefrigerated: false,
        refrigerationTemperatureCelsius: nil
    )

    // MARK: Response
    static let response = TomapoResponse(
        barcode: "7640150491001",
        batchId: "L250634716:41",
        generatedAt: date("2025-06-03T08:00:00Z"),
        productName: "El Tony Mate",
        genericName: "Cold Brew Mate-Tee",
        brands: "El Tony",
        quantity: "330ml",
        productQuantity: 330,
        productQuantityUnit: "ml",
        servingSize: "330ml",
        servingQuantity: 330,
        storesTags: ["coop", "migros"],
        imageUrl: "https://images.openfoodfacts.org/images/products/764/015/049/1001/front.jpg",
        imageFrontUrl: "https://images.openfoodfacts.org/images/products/764/015/049/1001/front.jpg",
        imageIngredientsUrl: nil,
        imageNutritionUrl: nil,
        imagePackagingUrl: nil,
        categoriesTags: ["en:beverages", "en:sodas", "en:mate"],
        foodGroupsTags: ["en:beverages"],
        foodGroups: "Beverages",
        pnnsGroups1: "Beverages",
        pnnsGroups2: "Sweetened beverages",
        nutriscoreGrade: "b",
        nutriscoreScore: 2,
        ecoscoreGrade: "b",
        ecoscoreScore: 61,
        novaGroup: 3,
        novaGroupError: nil,
        nutriments: ProductNutriments(
            energyKcal100g: 24,
            energyKj100g: 100,
            energyKcalServing: 79,
            energyKjServing: 330,
            fat100g: 0.5,
            saturatedFat100g: 0.1,
            fatServing: 1.65,
            saturatedFatServing: 0.33,
            carbohydrates100g: 5.8,
            sugars100g: 5.8,
            fiber100g: 0,
            addedSugars100g: 5.8,
            starch100g: nil,
            carbohydratesServing: 19.1,
            sugarsServing: 19.1,
            fiberServing: nil,
            proteins100g: 0.5,
            proteinsServing: 1.65,
            salt100g: 0.01,
            sodium100g: 0.004,
            saltServing: 0.033,
            sodiumServing: 0.013,
            novaGroup100g: 3
        ),
        nutrientLevels: ProductNutrientLevels(
            fat: "low",
            saturatedFat: "low",
            sugars: "moderate",
            salt: "low"
        ),
        ingredientsText: "Yerba Mate Tee (Cold Brew Aufguss 90%), Bio-Rohrzucker, Zitronensaft aus Konzentrat (3%), Guaranaextrakt, Koffein.",
        rawIngredients: nil,
        ingredientsN: 5,
        additivesN: 0,
        additivesTags: [],
        allergensTags: [],
        tracesTags: [],
        ingredientsAnalysisTags: ["en:vegan", "en:palm-oil-free"],
        labelsTags: ["en:rainforest-alliance", "en:eu-organic"],
        countriesTags: ["en:switzerland"],
        originsTags: ["en:argentina", "en:brazil", "en:switzerland"],
        manufacturingPlaces: "Zürich, Schweiz",
        manufacturingPlacesTags: ["en:zurich"],
        packagingTags: ["en:glass-bottle", "en:recyclable"],
        packagings: nil,
        packagingText: "Glasflasche",
        conservationConditions: nil,
        dataQualityErrorsTags: [],
        dataQualityWarningsTags: [],
        completeness: 0.82,
        alerts: [MockAlerts.communityElTony],
        stations: [stationMateFarm, stationGuarana, stationZucker, stationAbfuellung, stationTransport, stationRetail],
        environmentSummary: TomapoEnvironmentSummary(
            co2ByPhase: CO2ByPhase(
                agriculture: 1.2,
                processing: 0.09,
                transportation: 0.048,
                packaging: 0.065,
                distribution: 0.03,
                consumption: nil
            ),
            co2TotalKgPerKg: 1.49,
            ecoscoreGrade: "b",
            ecoscoreScore: 61,
            waterFootprintLiterPerKg: 1240,
            waterStressScore: 0.38,
            forestFootprintM2PerKg: 0.12,
            forestFootprintGrade: "b",
            deforestationRisk: 0.18,
            transportEmissionsGramsCo2: 48,
            totalTransportDistanceKm: 12500,
            transportLegCount: 3,
            packagingCo2Kg: 0.065,
            packagingScore: 68,
            recyclablePackagingPercent: 1.0,
            threatenedSpeciesRisk: nil,
            productionSystemBonus: 3,
            originEpiScore: 52
        ),
        certifications: [certRA, certBio, certISO22000],
        traceabilityScore: TomapoTraceabilityScore(
            completeness: 0.82,
            verifiedStations: 3,
            unknownStations: 1,
            hasGaps: false,
            isThirdPartyVerified: true,
            blockchainHash: nil
        ),
        dataSources: [
            TomapoDataSource(id: "ds-eltony-001", name: "intelligentfood AG", type: .manufacturer,  lastSynced: date("2025-06-03T08:00:00Z"), reliability: .verified),
            TomapoDataSource(id: "ds-eltony-002", name: "Open Food Facts",    type: .openFoodFacts, lastSynced: date("2025-06-03T08:01:00Z"), reliability: .community),
            TomapoDataSource(id: "ds-eltony-003", name: "Coop Schweiz",       type: .retailer,      lastSynced: date("2025-06-03T08:02:00Z"), reliability: .community)
        ],
        ingredients: [
            .subProduct(SubProductIngredient(
                id: "ing-eltony-001",
                barcode: "0000000000005",
                batchId: nil,
                name: "Yerba Mate Tee (Cold Brew Aufguss 90%)",
                description: nil,
                category: .extracts,
                percentageInProduct: 90,
                originCountry: "AR",
                originRegion: "Misiones",
                supplierName: "Cooperativa Mate Misiones",
                supplierCountry: "AR",
                imageUrl: nil,
                certifications: [certRA],
                traceData: nil
            )),
            .subProduct(SubProductIngredient(
                id: "ing-eltony-002",
                barcode: "0000000000006",
                batchId: nil,
                name: "Bio-Rohrzucker",
                description: nil,
                category: .sugars,
                percentageInProduct: 5.8,
                originCountry: "BR",
                originRegion: "São Paulo",
                supplierName: "Usina São Martinho",
                supplierCountry: "BR",
                imageUrl: nil,
                certifications: [certBio],
                traceData: nil
            )),
            .subProduct(SubProductIngredient(
                id: "ing-eltony-003",
                barcode: "0000000000007",
                batchId: nil,
                name: "Zitronensaft aus Konzentrat",
                description: nil,
                category: .concentrates,
                percentageInProduct: 3,
                originCountry: nil,
                originRegion: nil,
                supplierName: nil,
                supplierCountry: nil,
                imageUrl: nil,
                certifications: [],
                traceData: nil
            )),
            .chemical(ChemicalIngredient(
                id: "ing-eltony-004",
                eNumber: nil,
                name: "Guaranaextrakt",
                description: "Natürlicher Pflanzenextrakt",
                category: .flavourEnhancer,
                function_: .flavouring,
                percentageInProduct: nil,
                origin: .natural,
                isSynthetic: false,
                euRegulatoryStatus: .approved,
                healthAssessment: .safe,
                healthNotes: nil,
                sensitiveGroups: [],
                acceptableDailyIntakeKgBw: nil,
                maxAllowedMgPerKg: nil,
                actualMgPerKg: 1.0,
                efsaEvaluationUrl: nil,
                allowedInOrganic: true
            )),
            .chemical(ChemicalIngredient(
                id: "ing-eltony-005",
                eNumber: nil,
                name: "Koffein (natürlich aus Guarana und Mate)",
                description: "Natürliches Stimulans",
                category: .flavourEnhancer,
                function_: .flavouring,
                percentageInProduct: nil,
                origin: .natural,
                isSynthetic: false,
                euRegulatoryStatus: .approved,
                healthAssessment: .safe,
                healthNotes: "ADI: 3 mg/kg KG",
                sensitiveGroups: ["Kinder", "Schwangere"],
                acceptableDailyIntakeKgBw: 3,
                maxAllowedMgPerKg: nil,
                actualMgPerKg: 230,
                efsaEvaluationUrl: nil,
                allowedInOrganic: true
            ))
        ],
        requiresColdChain: false,
        coldChainSummary: .notRequired
    )
}

// MARK: ══════════════════════════════════════════════════════════
// MARK: MOCK TRACES – alle zusammen
// MARK: ══════════════════════════════════════════════════════════

enum MockTraces {
    static let cocaCola   = MockTraceCocaCola.response
    static let ovomaltine = MockTraceOvomaltine.response
    static let milch      = MockTraceMigrosMilch.response
    static let lindt      = MockTraceLindt.response
    static let elTonyMate = MockTraceElTonyMate.response

    static let all: [TomapoResponse] = [cocaCola, ovomaltine, milch, lindt, elTonyMate]

    static func find(barcode: String) -> TomapoResponse? {
        all.first { $0.barcode == barcode }
    }
}
