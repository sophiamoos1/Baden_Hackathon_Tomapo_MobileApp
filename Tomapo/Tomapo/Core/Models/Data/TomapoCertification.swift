//
//  TomapoCertification.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

//
//  Typen:
//  • TomapoCertification  – einzelnes Zertifikat mit Gültigkeitsdatum
//  • CertificationType    – 30+ Typen (euOrganic, fairtrade, msc, haccp …)
//  • CertificationScope   – product / facility / company / ingredient / process
//  • CertificationSource  – openFoodFacts / manufacturer / certificationBody …
//  • Extension            – from(offLabelTags:) erstellt Liste aus OFF labels_tags
//

internal import Foundation

// MARK: - TomapoCertification

struct TomapoCertification: Codable, Identifiable {

    let id: String
    let type: CertificationType
    let name: String
    let issuingBody: String?
    let certificateNumber: String?
    let validFrom: Date?
    let validUntil: Date?
    let logoUrl: String?
    let verificationUrl: String?
    let scope: CertificationScope
    let source: CertificationSource
    let offLabelTag: String?

    var isCurrentlyValid: Bool {
        guard let until = validUntil else { return true }
        return until > Date()
    }

    enum CodingKeys: String, CodingKey {
        case id, type, name, scope, source
        case issuingBody       = "issuing_body"
        case certificateNumber = "certificate_number"
        case validFrom         = "valid_from"
        case validUntil        = "valid_until"
        case logoUrl           = "logo_url"
        case verificationUrl   = "verification_url"
        case offLabelTag       = "off_label_tag"
    }
}

// MARK: - CertificationType

enum CertificationType: String, Codable, CaseIterable {
    // Bio / Ökologisch
    case euOrganic          = "eu_organic"
    case demeter            = "demeter"
    case bioSuisse          = "bio_suisse"
    case naturland          = "naturland"
    case soilAssociation    = "soil_association"

    // Sozial / Fair
    case fairtrade          = "fairtrade"
    case rainforestAlliance = "rainforest_alliance"
    case uti                = "uti"

    // Umwelt / Wald
    case fsc                = "fsc"
    case rspo               = "rspo"
    case msc                = "msc"
    case asc                = "asc"

    // Diät / Lebensmittel
    case glutenFree         = "gluten_free"
    case vegan              = "vegan"
    case vegetarian         = "vegetarian"
    case halal              = "halal"
    case kosher             = "kosher"

    // GMO-frei
    case nonGmo             = "non_gmo"
    case genTechFreeDE      = "gen_tech_free_de"

    // Qualität & Herkunft
    case pdo                = "pdo"
    case pgi                = "pgi"
    case tsg                = "tsg"
    case ipSuisse           = "ip_suisse"
    case aop                = "aop"

    // Lebensmittelsicherheit
    case haccp              = "haccp"
    case iso22000           = "iso_22000"
    case ifs                = "ifs_food"
    case brc                = "brc"
    case fssc22000          = "fssc_22000"
    case globalGap          = "global_gap"

    // Tierwohl
    case animalWelfare      = "animal_welfare"
    case rspca              = "rspca"

    // Energie / Klima
    case climateNeutral     = "climate_neutral"
    case carbonfootprint    = "carbon_footprint_certified"

    case other              = "other"
}

// MARK: - CertificationScope

enum CertificationScope: String, Codable {
    case product    = "product"
    case facility   = "facility"
    case company    = "company"
    case ingredient = "ingredient"
    case process    = "process"
}

// MARK: - CertificationSource

enum CertificationSource: String, Codable {
    case openFoodFacts     = "open_food_facts"
    case manufacturer      = "manufacturer"
    case certificationBody = "certification_body"
    case government        = "government"
    case thirdParty        = "third_party"
}

// MARK: - Extension: Zertifikat aus OFF Label-Tag erstellen

extension TomapoCertification {

    static func from(offLabelTags: [String]) -> [TomapoCertification] {
        offLabelTags.compactMap { tag in
            guard let type = typeFromOffTag(tag) else { return nil }
            return TomapoCertification(
                id: UUID().uuidString, type: type,
                name: displayName(for: type),
                issuingBody: issuingBody(for: type),
                certificateNumber: nil, validFrom: nil, validUntil: nil,
                logoUrl: nil, verificationUrl: verificationUrl(for: type),
                scope: .product, source: .openFoodFacts, offLabelTag: tag)
        }
    }

    private static func typeFromOffTag(_ tag: String) -> CertificationType? {
        switch tag {
        case "en:organic", "en:eu-organic":        return .euOrganic
        case "en:demeter":                         return .demeter
        case "en:fairtrade":                       return .fairtrade
        case "en:rainforest-alliance":             return .rainforestAlliance
        case "en:fsc", "en:fsc-mix":               return .fsc
        case "en:msc":                             return .msc
        case "en:asc":                             return .asc
        case "en:rspo":                            return .rspo
        case "en:no-gmos", "de:ohne-gentechnik":   return .nonGmo
        case "en:no-gluten", "en:gluten-free":     return .glutenFree
        case "en:vegan", "en:the-vegan-society":   return .vegan
        case "en:vegetarian":                      return .vegetarian
        case "en:halal":                           return .halal
        case "en:kosher":                          return .kosher
        case "en:ip-suisse":                       return .ipSuisse
        case "en:pdo":                             return .pdo
        case "en:pgi":                             return .pgi
        case "en:global-gap":                      return .globalGap
        case "en:haccp":                           return .haccp
        case "en:iso-22000":                       return .iso22000
        case "en:de-oko-005", "en:bio-suisse":     return .bioSuisse
        default:                                   return nil
        }
    }

    private static func displayName(for type: CertificationType) -> String {
        switch type {
        case .euOrganic:          return "EU Organic"
        case .demeter:            return "Demeter"
        case .bioSuisse:          return "Bio Suisse Bud"
        case .naturland:          return "Naturland"
        case .fairtrade:          return "Fairtrade"
        case .rainforestAlliance: return "Rainforest Alliance"
        case .fsc:                return "FSC"
        case .msc:                return "MSC Sustainable Fishing"
        case .asc:                return "ASC Aquaculture"
        case .rspo:               return "RSPO Sustainable Palm Oil"
        case .nonGmo:             return "Non-GMO"
        case .glutenFree:         return "Gluten Free"
        case .vegan:              return "Vegan"
        case .vegetarian:         return "Vegetarian"
        case .halal:              return "Halal"
        case .kosher:             return "Kosher"
        case .ipSuisse:           return "IP-Suisse"
        case .pdo:                return "PDO – Protected Designation of Origin"
        case .pgi:                return "PGI – Protected Geographical Indication"
        case .aop:                return "AOP"
        case .globalGap:          return "GlobalG.A.P."
        case .haccp:              return "HACCP"
        case .iso22000:           return "ISO 22000"
        case .ifs:                return "IFS Food"
        case .brc:                return "BRC Global Standard"
        case .fssc22000:          return "FSSC 22000"
        case .animalWelfare:      return "Animal Welfare Certificate"
        case .climateNeutral:     return "Climate Neutral"
        case .carbonfootprint:    return "Carbon Footprint Certified"
        default:                  return type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private static func issuingBody(for type: CertificationType) -> String? {
        switch type {
        case .euOrganic:          return "European Union"
        case .demeter:            return "Demeter International"
        case .bioSuisse:          return "Bio Suisse"
        case .fairtrade:          return "Fairtrade International"
        case .rainforestAlliance: return "Rainforest Alliance"
        case .fsc:                return "Forest Stewardship Council"
        case .msc:                return "Marine Stewardship Council"
        case .asc:                return "Aquaculture Stewardship Council"
        default:                  return nil
        }
    }

    private static func verificationUrl(for type: CertificationType) -> String? {
        switch type {
        case .euOrganic:  return "https://ec.europa.eu/farming/organic/eu-policy/eu-legislation_en"
        case .fairtrade:  return "https://www.fairtrade.net/product"
        case .fsc:        return "https://fsc.org/en/fsc-certificate-search"
        case .msc:        return "https://www.msc.org/track-a-product"
        default:          return nil
        }
    }
}
