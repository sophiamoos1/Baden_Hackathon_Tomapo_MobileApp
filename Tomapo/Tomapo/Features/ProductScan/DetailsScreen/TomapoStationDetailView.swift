//
//  TomapoStationDetailView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

 internal import SwiftUI
 internal import PhosphorSwift
 
 // MARK: - Haupt-View
 
 struct TomapoStationDetailView: View {
 let station: TomapoStation
 var onBack: () -> Void
 
 var body: some View {
 ZStack(alignment: .top) {
 Color.theme.baseBg.ignoresSafeArea()
 ScrollView(showsIndicators: false) {
 VStack(alignment: .leading, spacing: 20) {
 Color.clear.frame(height: 60) // Platz für BackBar
 stationHero
 stationMeta
 stationDetailSection
 qualityChecksSection
 Spacer(minLength: 40)
 }
 .padding(.horizontal, 16)
 .padding(.bottom, 32)
 }
 }
 .safeAreaInset(edge: .top, spacing: 0) {
 BackNavigationBar(title: station.title, onBack: onBack)
 }
 }
 
 // MARK: Hero
 
 private var stationHero: some View {
 HStack(spacing: 14) {
 ZStack {
 Circle()
 .fill(statusColor.opacity(0.15))
 .frame(width: 56, height: 56)
 Circle()
 .strokeBorder(statusColor, lineWidth: 2)
 .frame(width: 56, height: 56)
 stationIconLarge
 .frame(width: 28, height: 28)
 .foregroundColor(statusColor)
 }
 
 VStack(alignment: .leading, spacing: 5) {
 Text(station.title)
 .font(.title3.weight(.bold))
 .foregroundColor(Color.theme.cardFg)
 
 HStack(spacing: 6) {
 Circle()
 .fill(statusColor)
 .frame(width: 8, height: 8)
 Text(statusLabel)
 .font(.caption)
 .foregroundColor(statusColor)
 Text("·")
 .foregroundColor(Color.theme.mutedFg.opacity(0.35))
 Text(stationTypeLabel)
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg)
 }
 }
 Spacer()
 }
 .padding()
 .background(Color.theme.cardBg)
 .cornerRadius(16)
 }
 
 // MARK: Meta-Infos
 
 private var stationMeta: some View {
 VStack(alignment: .leading, spacing: 0) {
 SectionHeader(title: "Allgemein", icon: "info.circle")
 .padding(.bottom, 8)
 
 VStack(spacing: 0) {
 if let sub = station.subtitle {
 DetailRow(label: "Beschreibung", value: sub)
 Divider().padding(.leading, 16)
 }
 if let loc = station.location {
 LocationRow(location: loc)
 Divider().padding(.leading, 16)
 }
 if let start = station.startedAt {
 DetailRow(label: "Start", value: start.formatted(.dateTime.day().month(.wide).year().hour().minute()), icon: "calendar")
 Divider().padding(.leading, 16)
 }
 if let end = station.completedAt {
 DetailRow(label: "Abgeschlossen", value: end.formatted(.dateTime.day().month(.wide).year().hour().minute()), icon: "calendar.badge.checkmark")
 Divider().padding(.leading, 16)
 }
 if let dur = station.durationHours {
 DetailRow(label: "Dauer", value: formatDuration(dur), icon: "clock")
 Divider().padding(.leading, 16)
 }
 if let co2 = station.co2KgPerKg {
 DetailRow(label: "CO₂ Fussabdruck", value: "\(String(format: "%.4f", co2)) kg CO₂eq/kg")
 Divider().padding(.leading, 16)
 }
 if station.isVerified {
 DetailRow(label: "Verifiziert von",
 value: station.verifiedBy ?? "Ja",
 valueColor: Color.theme.success)
 } else {
 DetailRow(label: "Verifiziert", value: "Nicht verifiziert",
 valueColor: Color.theme.mutedFg.opacity(0.5))
 }
 if let notes = station.notes {
 Divider().padding(.leading, 16)
 VStack(alignment: .leading, spacing: 4) {
 Text("Notizen")
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg)
 Text(notes)
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg)
 .fixedSize(horizontal: false, vertical: true)
 }
 .padding(.horizontal, 16)
 .padding(.vertical, 12)
 }
 }
 .background(Color.theme.cardBg)
 .cornerRadius(14)
 }
 }
 
 // MARK: Typisierte Detail-Sektion
 
 @ViewBuilder
 private var stationDetailSection: some View {
 switch station.detail {
 case .farming(let d):       FarmingDetailSection(detail: d)
 case .fishing(let d):       FishingDetailSection(detail: d)
 case .harvest(let d):       HarvestDetailSection(detail: d)
 case .processing(let d):    ProcessingDetailSection(detail: d)
 case .packaging(let d):     PackagingDetailSection(detail: d)
 case .storage(let d):       StorageDetailSection(detail: d)
 case .coldStorage(let d):   ColdStorageDetailSection(detail: d)
 case .transport(let d):     TransportDetailSection(detail: d)
 case .laboratory(let d):    LaboratoryDetailSection(detail: d)
 case .distribution(let d):  DistributionDetailSection(detail: d)
 case .retail(let d):        RetailDetailSection(detail: d)
 case .generic(let d):
 if let desc = d.description ?? d.operatorName {
 GenericDetailSection(description: desc, operator_: d.operatorName)
 }
 }
 }
 
 // MARK: Qualitätschecks
 
 @ViewBuilder
 private var qualityChecksSection: some View {
 if !station.qualityChecks.isEmpty {
 VStack(alignment: .leading, spacing: 10) {
 SectionHeader(title: "Qualitätsprüfungen (\(station.qualityChecks.count))",
 icon: "checklist")
 ForEach(station.qualityChecks) { check in
 QualityCheckCard(check: check)
 }
 }
 }
 }
 
 // MARK: Helpers
 
 private var statusColor: Color {
 switch station.status {
 case .completed:  return Color.theme.success
 case .warning:    return Color.theme.warning
 case .failed:     return Color.theme.error
 case .active:     return Color.theme.infso
 case .pending:    return Color.theme.mutedFg
 case .skipped:    return Color.theme.mutedFg.opacity(0.35)
 case .unknown:    return Color.theme.mutedFg.opacity(0.4)
 }
 }
 
 private var statusLabel: String {
 switch station.status {
 case .completed:  return "Abgeschlossen"
 case .warning:    return "Mit Auffälligkeiten"
 case .failed:     return "Fehlgeschlagen"
 case .active:     return "Aktiv"
 case .pending:    return "Ausstehend"
 case .skipped:    return "Übersprungen"
 case .unknown:    return "Unbekannt"
 }
 }
 
 private var stationTypeLabel: String { station.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
 
 @ViewBuilder
 private var stationIconLarge: some View {
 switch station.type {
 case .farming:          Ph.plant.duotone
 case .fishing:          Ph.fish.duotone
 case .harvest:          Ph.knife.duotone
 case .sorting:          Ph.funnel.duotone
 case .processing:       Ph.gear.duotone
 case .cleaning:         Ph.dropHalf.duotone
 case .cutting:          Ph.scissors.duotone
 case .cooking:          Ph.thermometerHot.duotone
 case .fermenting:       Ph.flask.duotone
 case .drying:           Ph.sun.duotone
 case .freezing:         Ph.snowflake.duotone
 case .packaging:        Ph.package.duotone
 case .labeling:         Ph.tag.duotone
 case .sealing:          Ph.seal.duotone
 case .storage:          Ph.warehouse.duotone
 case .coldStorage:      Ph.thermometerCold.duotone
 case .frozenStorage:    Ph.snowflake.duotone
 case .ripening:         Ph.timer.duotone
 case .aging:            Ph.hourglass.duotone
 case .truckTransport, .refrigeratedTruck: Ph.truck.duotone
 case .railTransport:    Ph.train.duotone
 case .shipTransport:    Ph.boat.duotone
 case .airTransport:     Ph.airplane.duotone
 case .localDelivery:    Ph.van.duotone
 case .distribution:     Ph.arrowsOutLineHorizontal.duotone
 case .customsClearance: Ph.seal.duotone
 case .importInspection: Ph.magnifyingGlass.duotone
 case .retailStorage, .retailDisplay: Ph.storefront.duotone
 case .pointOfSale:      Ph.shoppingCart.duotone
 case .qualityInspection: Ph.clipboardText.duotone
 case .laboratoryTest:   Ph.flask.duotone
 case .certificationCheck: Ph.certificate.duotone
 case .veterinaryCheck:  Ph.firstAid.duotone
 case .unknown:          Ph.question.duotone
 }
 }
 
 private func formatDuration(_ hours: Double) -> String {
 if hours < 1 { return "\(Int(hours * 60)) Min." }
 if hours < 24 { return "\(Int(hours)) Std." }
 let d = Int(hours / 24); let h = Int(hours.truncatingRemainder(dividingBy: 24))
 return h > 0 ? "\(d) Tage \(h) Std." : "\(d) Tage"
 }
 }
 
 // MARK: ── Detail Sections ─────────────────────────────────────────────
 
 private struct FarmingDetailSection: View {
 let detail: FarmingDetail
 var body: some View {
 DetailCardSection(title: "Anbau / Landwirtschaft", icon: "leaf.fill") {
 if let name = detail.farmName { InfoDetailRow(label: "Betrieb", value: name) }
 InfoDetailRow(label: "Methode", value: detail.farmingMethod.rawValue.capitalized)
 if let year = detail.cropYear { InfoDetailRow(label: "Erntejahr", value: "\(year)") }
 if let species = detail.animalSpecies { InfoDetailRow(label: "Tierart", value: species) }
 if let system = detail.husbandrySystem { InfoDetailRow(label: "Haltungsform", value: system.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) }
 if let area = detail.areaHectares { InfoDetailRow(label: "Fläche", value: "\(String(format: "%.1f", area)) ha") }
 if !detail.fertilizerTypes.isEmpty { InfoDetailRow(label: "Dünger", value: detail.fertilizerTypes.map { $0.rawValue }.joined(separator: ", ")) }
 if !detail.pesticideTypes.isEmpty { InfoDetailRow(label: "⚠ Pestizide", value: detail.pesticideTypes.joined(separator: ", "), valueColor: Color.theme.warning) }
 else { InfoDetailRow(label: "Pestizide", value: "Keine", valueColor: Color.theme.success) }
 if let irr = detail.irrigationType { InfoDetailRow(label: "Bewässerung", value: irr.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) }
 if let soil = detail.soilType { InfoDetailRow(label: "Bodentyp", value: soil) }
 if let planting = detail.plantingDate { InfoDetailRow(label: "Pflanzung", value: planting.formatted(.dateTime.day().month(.abbreviated).year())) }
 if let hs = detail.expectedHarvestStart { InfoDetailRow(label: "Ernte von", value: hs.formatted(.dateTime.day().month(.abbreviated).year())) }
 if let he = detail.expectedHarvestEnd { InfoDetailRow(label: "Ernte bis", value: he.formatted(.dateTime.day().month(.abbreviated).year())) }
 if !detail.fieldCoordinates.isEmpty {
 InfoDetailRow(label: "Koordinaten",
 value: detail.fieldCoordinates.prefix(2)
 .map { "(\(String(format: "%.4f", $0.latitude)), \(String(format: "%.4f", $0.longitude)))" }
 .joined(separator: " · "))
 }
 }
 }
 }
 
 private struct FishingDetailSection: View {
 let detail: FishingDetail
 var body: some View {
 DetailCardSection(title: "Fischfang / Aquakultur", icon: "fish.fill") {
 InfoDetailRow(label: "Methode", value: detail.method.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 if let area = detail.catchArea { InfoDetailRow(label: "Fanggebiet", value: area) }
 if let vessel = detail.vessel { InfoDetailRow(label: "Schiff", value: vessel) }
 if let id = detail.vesselId { InfoDetailRow(label: "IMO-Nummer", value: id) }
 if let date = detail.catchDate { InfoDetailRow(label: "Fangdatum", value: date.formatted(.dateTime.day().month().year())) }
 InfoDetailRow(label: "MSC-zertifiziert", value: detail.isMscCertified ? "Ja" : "Nein", valueColor: detail.isMscCertified ? Color.theme.success : Color.theme.mutedFg)
 InfoDetailRow(label: "ASC-zertifiziert", value: detail.isAscCertified ? "Ja" : "Nein", valueColor: detail.isAscCertified ? Color.theme.success : Color.theme.mutedFg)
 if let bc = detail.bycatchInfo { InfoDetailRow(label: "Beifang-Info", value: bc) }
 }
 }
 }
 
 private struct HarvestDetailSection: View {
 let detail: HarvestDetail
 var body: some View {
 DetailCardSection(title: "Ernte / Schlachtung", icon: "scissors") {
 InfoDetailRow(label: "Methode", value: detail.isManual ? "Manuell" : "Maschinell")
 if let date = detail.harvestDate { InfoDetailRow(label: "Datum", value: date.formatted(.dateTime.day().month().year())) }
 if let grade = detail.gradeAfterHarvest { InfoDetailRow(label: "Qualitätsklasse", value: grade) }
 if let yield = detail.yieldPercent { InfoDetailRow(label: "Ausbeute", value: "\(String(format: "%.1f", yield))%") }
 if let temp = detail.harvestTemperatureCelsius { InfoDetailRow(label: "Temperatur", value: "\(String(format: "%.1f", temp))°C") }
 if let workers = detail.workerCount { InfoDetailRow(label: "Mitarbeiter", value: "\(workers)") }
 InfoDetailRow(label: "Sofortgekühlt", value: detail.immediatelyPrecooled ? "Ja" : "Nein")
 }
 }
 }
 
 private struct ProcessingDetailSection: View {
 let detail: ProcessingDetail
 var body: some View {
 DetailCardSection(title: "Verarbeitung", icon: "gearshape.fill") {
 if let name = detail.facilityName { InfoDetailRow(label: "Werk", value: name) }
 if let emb = detail.facilityEmbCode { InfoDetailRow(label: "EMB-Code", value: emb) }
 if !detail.processTypes.isEmpty { InfoDetailRow(label: "Prozesse", value: detail.processTypes.map { $0.rawValue.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", ")) }
 if let temp = detail.processingTemperatureCelsius { InfoDetailRow(label: "Temperatur", value: "\(String(format: "%.0f", temp))°C") }
 if let past = detail.pasteurization { InfoDetailRow(label: "Pasteurisierung", value: "\(past.method.rawValue.uppercased()) · \(Int(past.temperatureCelsius))°C / \(past.durationSeconds)s") }
 if let steril = detail.sterilization { InfoDetailRow(label: "Sterilisierung", value: "\(Int(steril.temperatureCelsius))°C / \(steril.durationMinutes) Min.") }
 if !detail.additivesAdded.isEmpty { InfoDetailRow(label: "Zusatzstoffe", value: detail.additivesAdded.map { $0.replacingOccurrences(of: "en:", with: "").uppercased() }.joined(separator: ", ")) }
 InfoDetailRow(label: "HACCP", value: detail.isHaccpCertified ? "Zertifiziert" : "Nicht zertifiziert", valueColor: detail.isHaccpCertified ? Color.theme.success : Color.theme.mutedFg)
 if let standard = detail.foodSafetyStandard { InfoDetailRow(label: "Standard", value: standard.rawValue.uppercased().replacingOccurrences(of: "_", with: " ")) }
 if let batch = detail.batchSizeKg { InfoDetailRow(label: "Chargengrösse", value: "\(String(format: "%.0f", batch)) kg") }
 }
 }
 }
 
 private struct PackagingDetailSection: View {
 let detail: PackagingDetail
 var body: some View {
 DetailCardSection(title: "Verpackung", icon: "shippingbox.fill") {
 if let name = detail.facilityName { InfoDetailRow(label: "Werk", value: name) }
 if !detail.materials.isEmpty {
 ForEach(detail.materials, id: \.material) { mat in
 HStack {
 VStack(alignment: .leading, spacing: 2) {
 Text(mat.shape ?? mat.material.replacingOccurrences(of: "en:", with: ""))
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg)
 Text(mat.isRecyclable ? "♻ Recyclebar" : "Nicht recyclebar")
 .font(.caption2)
 .foregroundColor(mat.isRecyclable ? Color.theme.success : Color.theme.error)
 }
 Spacer()
 if let w = mat.weightGrams {
 Text("\(String(format: "%.1f", w))g")
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg)
 }
 }
 .padding(.horizontal, 16).padding(.vertical, 10)
 }
 }
 if let map = detail.modifiedAtmosphere {
 InfoDetailRow(label: "Schutzatmosphäre",
 value: [
 map.oxygenPercent.map { "O₂: \(String(format: "%.0f", $0))%" },
 map.co2Percent.map { "CO₂: \(String(format: "%.0f", $0))%" },
 map.nitrogenPercent.map { "N₂: \(String(format: "%.0f", $0))%" }
 ].compactMap { $0 }.joined(separator: " · "))
 }
 InfoDetailRow(label: "Vakuumverpackt", value: detail.isVacuumPacked ? "Ja" : "Nein")
 if let total = detail.totalPackagingWeightGrams { InfoDetailRow(label: "Gesamtgewicht", value: "\(String(format: "%.1f", total))g") }
 if !detail.labelLanguages.isEmpty { InfoDetailRow(label: "Etikettensprachen", value: detail.labelLanguages.joined(separator: ", ")) }
 if let exp = detail.expirationDate { InfoDetailRow(label: "MHD", value: exp.formatted(.dateTime.day().month().year())) }
 if let batch = detail.batchCodeOnPackaging { InfoDetailRow(label: "Chargennummer", value: batch) }
 }
 }
 }
 
 private struct StorageDetailSection: View {
 let detail: StorageDetail
 var body: some View {
 DetailCardSection(title: "Lagerung", icon: "building.2.fill") {
 if let name = detail.facilityName { InfoDetailRow(label: "Lager", value: name) }
 InfoDetailRow(label: "Lagertyp", value: detail.facilityType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 if let dur = detail.storageDurationHours { InfoDetailRow(label: "Dauer", value: "\(String(format: "%.0f", dur)) Std.") }
 if let temp = detail.averageTemperatureCelsius { InfoDetailRow(label: "Ø Temperatur", value: "\(String(format: "%.1f", temp))°C") }
 if let hum = detail.humidityPercent { InfoDetailRow(label: "Luftfeuchtigkeit", value: "\(String(format: "%.0f", hum))%") }
 if let light = detail.lightCondition { InfoDetailRow(label: "Lichtverhältnis", value: light.rawValue.capitalized) }
 InfoDetailRow(label: "Max. Dauer überschritten", value: detail.maxDurationExceeded ? "⚠ Ja" : "Nein", valueColor: detail.maxDurationExceeded ? Color.theme.error : Color.theme.success)
 }
 }
 }
 
 private struct ColdStorageDetailSection: View {
 let detail: ColdStorageDetail
 var body: some View {
 DetailCardSection(title: "Kühllagerung / Kühltransport", icon: "thermometer.snowflake") {
 if let name = detail.facilityName { InfoDetailRow(label: "Anlage", value: name) }
 InfoDetailRow(label: "Solltemperatur", value: "\(String(format: "%.1f", detail.targetTemperatureCelsius))°C")
 if let min = detail.minActualTemperatureCelsius { InfoDetailRow(label: "Minimum", value: "\(String(format: "%.1f", min))°C") }
 if let max = detail.maxActualTemperatureCelsius { InfoDetailRow(label: "Maximum", value: "\(String(format: "%.1f", max))°C") }
 if let avg = detail.avgActualTemperatureCelsius { InfoDetailRow(label: "Durchschnitt", value: "\(String(format: "%.1f", avg))°C") }
 InfoDetailRow(label: "Kühlkette unterbrochen", value: detail.coldChainBroken ? "⚠ Ja" : "Intakt", valueColor: detail.coldChainBroken ? Color.theme.error : Color.theme.success)
 if !detail.coldChainBreaks.isEmpty {
 ForEach(Array(detail.coldChainBreaks.enumerated()), id: \.offset) { i, brk in
 InfoDetailRow(label: "Unterbrechung \(i+1)",
 value: "\(brk.occurredAt.formatted(.dateTime.hour().minute())) · \(brk.durationMinutes) Min. · max \(String(format: "%.1f", brk.maxTemperatureReached))°C",
 valueColor: Color.theme.warning)
 }
 }
 if let sensor = detail.sensorId { InfoDetailRow(label: "Sensor-ID", value: sensor) }
 if let last = detail.lastSensorReading {
 InfoDetailRow(label: "Letzte Messung",
 value: "\(String(format: "%.1f", last.temperatureCelsius))°C · \(last.timestamp.formatted(.dateTime.hour().minute()))",
 valueColor: last.isWithinRange ? Color.theme.success : Color.theme.warning)
 }
 }
 }
 }
 
 private struct TransportDetailSection: View {
 let detail: TransportDetail
 var body: some View {
 DetailCardSection(title: "Transport", icon: "truck.box.fill") {
 InfoDetailRow(label: "Transportmittel", value: detail.mode.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 if let carrier = detail.carrierName { InfoDetailRow(label: "Spediteur", value: carrier) }
 if let id = detail.trackingId { InfoDetailRow(label: "Tracking-ID", value: id) }
 if let dist = detail.distanceKm { InfoDetailRow(label: "Distanz", value: "\(String(format: "%.0f", dist)) km") }
 InfoDetailRow(label: "Kühlstransport", value: detail.isRefrigerated ? "Ja" : "Nein")
 if let fuel = detail.fuelType { InfoDetailRow(label: "Treibstoff", value: fuel.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) }
 if let vehicle = detail.vehicleType { InfoDetailRow(label: "Fahrzeug", value: vehicle) }
 if let co2 = detail.co2EmissionsKg { InfoDetailRow(label: "CO₂ Emission", value: "\(String(format: "%.2f", co2)) kg CO₂eq") }
 if let sched = detail.scheduledArrival { InfoDetailRow(label: "Geplante Ankunft", value: sched.formatted(.dateTime.day().month().hour().minute())) }
 if let actual = detail.actualArrival { InfoDetailRow(label: "Tatsächliche Ankunft", value: actual.formatted(.dateTime.day().month().hour().minute())) }
 if let origin = detail.originLocation { InfoDetailRow(label: "Von", value: [origin.city, origin.country].compactMap { $0 }.joined(separator: ", ")) }
 if let dest = detail.destinationLocation { InfoDetailRow(label: "Nach", value: [dest.city, dest.country].compactMap { $0 }.joined(separator: ", ")) }
 if !detail.delayReasons.isEmpty { InfoDetailRow(label: "Verspätung", value: detail.delayReasons.joined(separator: ", "), valueColor: Color.theme.warning) }
 if let cold = detail.coldStorageDetail {
 InfoDetailRow(label: "Kühltemperatur", value: "\(String(format: "%.1f", cold.targetTemperatureCelsius))°C Soll")
 if cold.coldChainBroken { InfoDetailRow(label: "⚠ Kühlkette", value: "Unterbrochen", valueColor: Color.theme.error) }
 }
 }
 }
 }
 
 private struct DistributionDetailSection: View {
 let detail: DistributionDetail
 var body: some View {
 DetailCardSection(title: "Distribution / Verteilzentrum", icon: "building.2") {
 if let name = detail.centerName { InfoDetailRow(label: "Zentrum", value: name) }
 InfoDetailRow(label: "Typ", value: detail.centerType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 if let inb = detail.inboundDate { InfoDetailRow(label: "Eingang", value: inb.formatted(.dateTime.day().month().year().hour().minute())) }
 if let out = detail.outboundDate { InfoDetailRow(label: "Ausgang", value: out.formatted(.dateTime.day().month().year().hour().minute())) }
 if let count = detail.handlingCount { InfoDetailRow(label: "Umschlagsvorgänge", value: "\(count)") }
 InfoDetailRow(label: "Zollabgefertigt", value: detail.customsCleared ? "Ja" : "Nein", valueColor: detail.customsCleared ? Color.theme.success : Color.theme.mutedFg)
 if let imp = detail.importInspectionPassed { InfoDetailRow(label: "Einfuhrkontrolle", value: imp ? "Bestanden" : "Nicht bestanden", valueColor: imp ? Color.theme.success : Color.theme.error) }
 if let by = detail.inspectedBy { InfoDetailRow(label: "Kontrolliert von", value: by) }
 }
 }
 }
 
 private struct RetailDetailSection: View {
 let detail: RetailDetail
 var body: some View {
 DetailCardSection(title: "Verkauf / Retail", icon: "storefront.fill") {
 if let chain = detail.storeChain { InfoDetailRow(label: "Kette", value: chain) }
 if let name = detail.storeName { InfoDetailRow(label: "Filiale", value: name) }
 InfoDetailRow(label: "Regaltyp", value: detail.displayType.rawValue.capitalized)
 if let temp = detail.displayTemperatureCelsius { InfoDetailRow(label: "Regaltemperatur", value: "\(String(format: "%.1f", temp))°C") }
 if let first = detail.firstOnShelfDate { InfoDetailRow(label: "Erstmals im Regal", value: first.formatted(.dateTime.day().month().year())) }
 if let mhd = detail.bestBeforeDate { InfoDetailRow(label: "MHD", value: mhd.formatted(.dateTime.day().month().year())) }
 if let price = detail.priceChf { InfoDetailRow(label: "Preis", value: "CHF \(String(format: "%.2f", price))") }
 }
 }
 }
 
 private struct LaboratoryDetailSection: View {
 let detail: LaboratoryDetail
 
 var body: some View {
 VStack(alignment: .leading, spacing: 16) {
 // Lab-Identität
 DetailCardSection(title: "Labor", icon: "flask.fill") {
 if let name = detail.laboratoryName { InfoDetailRow(label: "Labor", value: name) }
 if let accred = detail.accreditationNumber { InfoDetailRow(label: "Akkreditierung", value: accred) }
 if let body = detail.accreditationBody { InfoDetailRow(label: "Akkreditierungsstelle", value: body) }
 InfoDetailRow(label: "ISO 17025", value: detail.isIso17025Accredited ? "Akkreditiert ✓" : "Nicht akkreditiert", valueColor: detail.isIso17025Accredited ? Color.theme.success : Color.theme.mutedFg)
 InfoDetailRow(label: "Labortyp", value: detail.laboratoryType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 }
 
 // Probe
 DetailCardSection(title: "Probe", icon: "eyedropper.halffull") {
 if let sid = detail.sampleId { InfoDetailRow(label: "Probe-ID", value: sid) }
 if let matrix = detail.sampleMatrix { InfoDetailRow(label: "Matrix", value: matrix) }
 if let batch = detail.batchId { InfoDetailRow(label: "Charge", value: batch) }
 InfoDetailRow(label: "Entnahme-Methode", value: detail.samplingMethod.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 if let by = detail.sampledBy { InfoDetailRow(label: "Entnommen von", value: by) }
 if let at = detail.sampledAt { InfoDetailRow(label: "Entnahmezeitpunkt", value: at.formatted(.dateTime.day().month().year().hour().minute())) }
 if let w = detail.sampleWeightGrams { InfoDetailRow(label: "Probengewicht", value: "\(String(format: "%.0f", w))g") }
 InfoDetailRow(label: "Gekühlt transportiert", value: detail.sampleTransportedCooled ? "Ja" : "Nein")
 if let at = detail.sampleArrivalTemperatureCelsius { InfoDetailRow(label: "Eingangstemperatur", value: "\(String(format: "%.1f", at))°C") }
 if let start = detail.analysisStartedAt { InfoDetailRow(label: "Analyse gestartet", value: start.formatted(.dateTime.day().month().year())) }
 if let end = detail.analysisCompletedAt { InfoDetailRow(label: "Analyse abgeschlossen", value: end.formatted(.dateTime.day().month().year())) }
 }
 
 // Mikrobiologie
 if !detail.microbiologicalResults.isEmpty {
 DetailCardSection(title: "Mikrobiologie", icon: "microbe.fill") {
 ForEach(Array(detail.microbiologicalResults.enumerated()), id: \.offset) { _, r in
 MicroResultRow(result: r)
 }
 }
 }
 
 // Chemie
 if !detail.chemicalResults.isEmpty {
 DetailCardSection(title: "Chemische Rückstände", icon: "atom") {
 ForEach(Array(detail.chemicalResults.enumerated()), id: \.offset) { _, r in
 ChemResultRow(result: r)
 }
 }
 }
 
 // Nährwerte
 if let n = detail.nutritionalAnalysis {
 DetailCardSection(title: "Nährwertanalyse (gemessen)", icon: "fork.knife") {
 if let kcal = n.energyKcal { InfoDetailRow(label: "Energie", value: "\(String(format: "%.0f", kcal)) kcal/100g") }
 if let fat = n.fatG { InfoDetailRow(label: "Fett", value: "\(String(format: "%.1f", fat))g/100g") }
 if let prot = n.proteinsG { InfoDetailRow(label: "Protein", value: "\(String(format: "%.1f", prot))g/100g") }
 if let salt = n.saltG { InfoDetailRow(label: "Salz", value: "\(String(format: "%.2f", salt))g/100g") }
 if let dev = n.deviationFromDeclarationPercent {
 InfoDetailRow(label: "Abweichung Deklaration", value: "\(String(format: "%.1f", dev))%",
 valueColor: abs(dev) <= 20 ? Color.theme.success : Color.theme.error)
 }
 InfoDetailRow(label: "EU-Toleranz ±20%", value: n.isWithinEuTolerance ? "Eingehalten ✓" : "Überschritten ✗", valueColor: n.isWithinEuTolerance ? Color.theme.success : Color.theme.error)
 }
 }
 
 // Physikalisch
 if !detail.physicalResults.isEmpty {
 DetailCardSection(title: "Physikalische Parameter", icon: "ruler.fill") {
 ForEach(Array(detail.physicalResults.enumerated()), id: \.offset) { _, r in
 HStack {
 VStack(alignment: .leading, spacing: 2) {
 Text(r.parameter.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg)
 if let notes = r.notes {
 Text(notes).font(.caption2).foregroundColor(Color.theme.mutedFg).lineLimit(2)
 }
 }
 Spacer()
 Text("\(String(format: "%.2f", r.measuredValue)) \(r.unit)")
 .font(.subheadline)
 .foregroundColor(r.isWithinSpec ? Color.theme.cardFg : Color.theme.error)
 }
 .padding(.horizontal, 16).padding(.vertical, 10)
 }
 }
 }
 
 // Allergene
 if !detail.allergenResults.isEmpty {
 DetailCardSection(title: "Allergen-Tests", icon: "exclamationmark.shield.fill") {
 ForEach(Array(detail.allergenResults.enumerated()), id: \.offset) { _, r in
 AllergenResultRow(result: r)
 }
 }
 }
 
 // Authentizität
 if !detail.authenticityResults.isEmpty {
 DetailCardSection(title: "Authentizitäts-Tests", icon: "shield.checkered") {
 ForEach(Array(detail.authenticityResults.enumerated()), id: \.offset) { _, r in
 HStack(alignment: .top, spacing: 10) {
 Image(systemName: r.isAuthentic ? "checkmark.circle.fill" : "xmark.circle.fill")
 .foregroundColor(r.isAuthentic ? Color.theme.success : Color.theme.error)
 .font(.subheadline)
 VStack(alignment: .leading, spacing: 2) {
 Text(r.claim)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg)
 if let method = r.method { Text(method).font(.caption2).foregroundColor(Color.theme.mutedFg) }
 if let conf = r.confidencePercent { Text("Konfidenz: \(String(format: "%.1f", conf))%").font(.caption2).foregroundColor(Color.theme.mutedFg) }
 if let notes = r.notes { Text(notes).font(.caption2).foregroundColor(Color.theme.mutedFg).lineLimit(3) }
 }
 }
 .padding(.horizontal, 16).padding(.vertical, 10)
 }
 }
 }
 
 // Gesamtbewertung
 DetailCardSection(title: "Laborurteil", icon: "checkmark.seal.fill") {
 InfoDetailRow(label: "Gesamturteil", value: detail.overallVerdict.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
 valueColor: detail.overallVerdict == .compliant ? Color.theme.success : detail.overallVerdict == .minorDeviation ? Color.theme.warning : Color.theme.error)
 InfoDetailRow(label: "Grenzwertüberschreitungen", value: "\(detail.exceedanceCount)",
 valueColor: detail.exceedanceCount == 0 ? Color.theme.success : Color.theme.error)
 if let rec = detail.recommendation { InfoDetailRow(label: "Empfehlung", value: rec.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) }
 if let signed = detail.signedBy { InfoDetailRow(label: "Unterzeichnet von", value: signed) }
 if let issued = detail.reportIssuedAt { InfoDetailRow(label: "Berichtsdatum", value: issued.formatted(.dateTime.day().month().year())) }
 if let report = detail.reportNumber { InfoDetailRow(label: "Berichts-Nr.", value: report) }
 }
 }
 }
 }
 
 private struct GenericDetailSection: View {
 let description: String
 let operator_: String?
 var body: some View {
 DetailCardSection(title: "Details", icon: "doc.text") {
 if let op = operator_ { InfoDetailRow(label: "Betreiber", value: op) }
 VStack(alignment: .leading, spacing: 4) {
 Text(description)
 .font(.subheadline)
 .foregroundColor(Color.theme.mutedFg)
 .fixedSize(horizontal: false, vertical: true)
 }
 .padding(.horizontal, 16).padding(.vertical, 12)
 }
 }
 }
 
 // MARK: - Qualitätscheck Card
 
 private struct QualityCheckCard: View {
 let check: TomapoQualityCheck
 @State private var expanded = false
 
 private var statusColor: Color {
 switch check.status {
 case .passed: return Color.theme.success
 case .failed: return Color.theme.error
 case .warning: return Color.theme.warning
 default: return Color.theme.mutedFg.opacity(0.5)
 }
 }
 
 private var statusIcon: String {
 switch check.status {
 case .passed: return "checkmark.circle.fill"
 case .failed: return "xmark.circle.fill"
 case .warning: return "exclamationmark.triangle.fill"
 default: return "questionmark.circle.fill"
 }
 }
 
 var body: some View {
 VStack(alignment: .leading, spacing: 0) {
 // Header
 Button {
 withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
 } label: {
 HStack(spacing: 10) {
 Image(systemName: statusIcon)
 .foregroundColor(statusColor)
 .font(.subheadline)
 
 VStack(alignment: .leading, spacing: 2) {
 Text(check.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 .font(.subheadline.weight(.semibold))
 .foregroundColor(Color.theme.cardFg)
 .lineLimit(1)
 if let by = check.performedBy {
 Text(by)
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 .lineLimit(1)
 }
 }
 Spacer()
 if let date = check.performedAt {
 Text(date.formatted(.dateTime.day().month(.abbreviated)))
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg.opacity(0.5))
 }
 Image(systemName: expanded ? "chevron.up" : "chevron.down")
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg.opacity(0.4))
 }
 .padding(12)
 }
 
 // Expanded Content
 if expanded {
 Divider().padding(.leading, 12)
 
 VStack(alignment: .leading, spacing: 8) {
 if let summary = check.resultSummary {
 Text(summary)
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg)
 .fixedSize(horizontal: false, vertical: true)
 }
 HStack(spacing: 12) {
 if let accred = check.accreditationNumber {
 Label(accred, systemImage: "shield.checkered")
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 if let report = check.reportNumber {
 Label(report, systemImage: "doc.text")
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 }
 if let next = check.nextCheckDue {
 Label("Nächste Prüfung: \(next.formatted(.dateTime.day().month().year()))",
 systemImage: "calendar.badge.clock")
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 
 // Detail-spezifische Inhalte
 QualityDetailContent(detail: check.detail)
 }
 .padding(12)
 }
 }
 .background(Color.theme.cardBg)
 .cornerRadius(12)
 .overlay(
 RoundedRectangle(cornerRadius: 12)
 .stroke(statusColor.opacity(0.2), lineWidth: 1)
 )
 }
 }
 
 private struct QualityDetailContent: View {
 let detail: QualityCheckDetail
 
 var body: some View {
 switch detail {
 case .temperature(let d):
 VStack(alignment: .leading, spacing: 4) {
 HStack {
 Text("Gemessen: \(String(format: "%.1f", d.measuredCelsius))°C")
 Spacer(minLength: 4)
 Text("Bereich: \(String(format: "%.1f", d.minAllowedCelsius))–\(String(format: "%.1f", d.maxAllowedCelsius))°C")
 .lineLimit(1)
 }
 .font(.caption2)
 .foregroundColor(Color.theme.cardFg.opacity(0.6))
 if !d.log.isEmpty {
 Text("\(d.log.count) Messungen · Min: \(String(format: "%.1f", d.log.map(\.temperatureCelsius).min() ?? 0))°C · Max: \(String(format: "%.1f", d.log.map(\.temperatureCelsius).max() ?? 0))°C")
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 }
 
 case .microbiological(let d):
 VStack(alignment: .leading, spacing: 4) {
 ForEach(d.pathogensTested, id: \.pathogen) { p in
 HStack(spacing: 6) {
 Circle()
 .fill(p.detected ? Color.theme.error : Color.theme.success)
 .frame(width: 6, height: 6)
 Text(p.pathogen)
 .font(.caption2)
 .foregroundColor(Color.theme.cardFg.opacity(0.65))
 Spacer()
 Text(p.detected ? (p.limitExceeded ? "⚠ Limit überschritten" : "Nachgewiesen") : "n.d.")
 .font(.caption2)
 .foregroundColor(p.detected ? (p.limitExceeded ? Color.theme.error : Color.theme.warning) : Color.theme.success)
 }
 }
 if let total = d.totalBacterialCount {
 Text("Gesamtkeimzahl: \(Int(total.totalCfu)) / \(Int(total.acceptableLimit)) KBE/g")
 .font(.caption2)
 .foregroundColor(total.isAcceptable ? Color.theme.success : Color.theme.error)
 }
 }
 
 case .chemical(let d):
 VStack(alignment: .leading, spacing: 4) {
 ForEach(d.substancesTested, id: \.substance) { s in
 HStack(spacing: 6) {
 Circle()
 .fill(s.limitExceeded ? Color.theme.error : (s.measuredMgPerKg != nil ? Color.theme.success : Color.theme.mutedFg.opacity(0.35)))
 .frame(width: 6, height: 6)
 Text(s.substance)
 .font(.caption2)
 .foregroundColor(Color.theme.cardFg.opacity(0.65))
 Spacer()
 if let v = s.measuredMgPerKg {
 Text("\(String(format: "%.4f", v)) \(s.unit)")
 .font(.caption2)
 .foregroundColor(s.limitExceeded ? Color.theme.error : Color.theme.mutedFg)
 } else {
 Text("n.d.").font(.caption2).foregroundColor(Color.theme.success)
 }
 }
 }
 }
 
 case .nutritional(let d):
 HStack(spacing: 12) {
 if let e = d.energyKcal { VStack { Text("\(Int(e))").font(.caption.weight(.bold)).foregroundColor(Color.theme.cardFg); Text("kcal").font(.caption2).foregroundColor(Color.theme.mutedFg) } }
 if let f = d.fatG { VStack { Text("\(String(format: "%.1f", f))g").font(.caption.weight(.bold)).foregroundColor(Color.theme.cardFg); Text("Fett").font(.caption2).foregroundColor(Color.theme.mutedFg) } }
 if let p = d.proteinsG { VStack { Text("\(String(format: "%.1f", p))g").font(.caption.weight(.bold)).foregroundColor(Color.theme.cardFg); Text("Protein").font(.caption2).foregroundColor(Color.theme.mutedFg) } }
 if let dev = d.deviationFromLabelPercent {
 VStack {
 Text("\(String(format: "%.1f", dev))%").font(.caption.weight(.bold)).foregroundColor(abs(dev) <= 20 ? Color.theme.success : Color.theme.error)
 Text("Abw.").font(.caption2).foregroundColor(Color.theme.mutedFg)
 }
 }
 }
 
 case .packaging(let d):
 HStack(spacing: 12) {
 Label(d.isSealed ? "Dicht" : "Undicht", systemImage: d.isSealed ? "checkmark" : "xmark")
 .foregroundColor(d.isSealed ? Color.theme.success : Color.theme.error)
 Label(d.barcodeReadable ? "Barcode OK" : "Barcode Fehler", systemImage: "barcode")
 .foregroundColor(d.barcodeReadable ? Color.theme.success : Color.theme.error)
 }
 .font(.caption2)
 .lineLimit(1)
 
 case .visual(let d):
 HStack(spacing: 8) {
 if let grade = d.gradeAssigned { Text(grade).font(.caption2).foregroundColor(Color.theme.cardFg.opacity(0.65)) }
 if let rej = d.rejectionRate { Text("Ausschuss: \(String(format: "%.1f", rej))%").font(.caption2).foregroundColor(rej < 5 ? Color.theme.mutedFg : Color.theme.warning) }
 }
 
 case .weight(let d):
 HStack(spacing: 12) {
 VStack { Text("\(String(format: "%.1f", d.targetWeightG))g").font(.caption.weight(.bold)).foregroundColor(Color.theme.cardFg).lineLimit(1); Text("Soll").font(.caption2).foregroundColor(Color.theme.mutedFg) }
 VStack { Text("\(String(format: "%.1f", d.measuredWeightG))g").font(.caption.weight(.bold)).foregroundColor(d.isWithinTolerance ? Color.theme.cardFg : Color.theme.error).lineLimit(1); Text("Ist").font(.caption2).foregroundColor(Color.theme.mutedFg) }
 VStack { Text("±\(String(format: "%.1f", d.tolerancePercent))%").font(.caption.weight(.bold)).foregroundColor(Color.theme.cardFg).lineLimit(1); Text("Toleranz").font(.caption2).foregroundColor(Color.theme.mutedFg) }
 }
 
 case .certification(let d):
 VStack(alignment: .leading, spacing: 4) {
 HStack {
 Text(d.certificationBody).font(.caption2).foregroundColor(Color.theme.cardFg.opacity(0.65))
 Spacer()
 if let score = d.score { Text("\(Int(score))/100").font(.caption2.weight(.bold)).foregroundColor(score >= 90 ? Color.theme.success : score >= 70 ? Color.theme.warning : Color.theme.error) }
 }
 if !d.nonConformities.isEmpty {
 Text("\(d.nonConformities.count) Abweichungen · \(d.nonConformities.filter { $0.severity == .critical }.count) kritisch")
 .font(.caption2)
 .foregroundColor(d.nonConformities.contains(where: { $0.severity == .critical }) ? Color.theme.error : Color.theme.warning)
 }
 if let valid = d.certificateValidUntil {
 Text("Gültig bis \(valid.formatted(.dateTime.day().month().year()))")
 .font(.caption2).foregroundColor(Color.theme.mutedFg)
 }
 }
 
 case .generic(let d):
 if let desc = d.description { Text(desc).font(.caption2).foregroundColor(Color.theme.cardFg.opacity(0.65)).lineLimit(3) }
 }
 }
 }
 
 // MARK: - Sub-Row Components
 
 private struct MicroResultRow: View {
 let result: MicrobiologicalResult
 var body: some View {
 HStack(spacing: 8) {
 Circle()
 .fill(result.detected ? (result.limitExceeded ? Color.theme.error : Color.theme.warning) : Color.theme.success)
 .frame(width: 7, height: 7)
 VStack(alignment: .leading, spacing: 2) {
 Text(result.pathogen)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg)
 Text(result.testMethod)
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 Spacer()
 VStack(alignment: .trailing, spacing: 2) {
 Text(result.detected ? (result.limitExceeded ? "⚠ Limit!" : "Nachgewiesen") : "n.d.")
 .font(.caption.weight(.semibold))
 .foregroundColor(result.detected ? (result.limitExceeded ? Color.theme.error : Color.theme.warning) : Color.theme.success)
 if let cfu = result.cfuPerGram, cfu > 0 {
 Text("\(String(format: "%.0f", cfu)) KBE/g")
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 }
 }
 .padding(.horizontal, 16).padding(.vertical, 10)
 }
 }
 
 private struct ChemResultRow: View {
 let result: ChemicalResiduResult
 var body: some View {
 HStack(spacing: 8) {
 Circle()
 .fill(result.mrlExceeded ? Color.theme.error : (result.measuredValue != nil ? Color.theme.warning : Color.theme.success))
 .frame(width: 7, height: 7)
 VStack(alignment: .leading, spacing: 2) {
 Text(result.substanceName)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg)
 Text(result.category.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 }
 Spacer()
 VStack(alignment: .trailing, spacing: 2) {
 if let v = result.measuredValue {
 Text("\(String(format: "%.4f", v)) \(result.unit)")
 .font(.caption.weight(.semibold))
 .foregroundColor(result.mrlExceeded ? Color.theme.error : Color.theme.cardFg)
 } else {
 Text("n.d.")
 .font(.caption.weight(.semibold))
 .foregroundColor(Color.theme.success)
 }
 if let mrl = result.mrlValue {
 Text("MRL: \(String(format: "%.4f", mrl)) \(result.unit)")
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg.opacity(0.5))
 }
 }
 }
 .padding(.horizontal, 16).padding(.vertical, 10)
 }
 }
 
 private struct AllergenResultRow: View {
 let result: AllergenTestResult
 var body: some View {
 HStack(spacing: 8) {
 Image(systemName: result.detected ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
 .foregroundColor(result.detected ? Color.theme.warning : Color.theme.success)
 .font(.caption)
 VStack(alignment: .leading, spacing: 2) {
 Text(result.allergen)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg)
 HStack(spacing: 6) {
 Text(result.method.rawValue.uppercased())
 .font(.caption2)
 .foregroundColor(Color.theme.mutedFg)
 if result.isEuMajorAllergen { Text("EU-Hauptallergen").font(.caption2).foregroundColor(Color.theme.warning) }
 }
 }
 Spacer()
 VStack(alignment: .trailing, spacing: 2) {
 if let v = result.measuredMgPerKg {
 Text("\(String(format: "%.0f", v)) mg/kg")
 .font(.caption.weight(.semibold))
 .foregroundColor(Color.theme.cardFg)
 }
 Text(result.declarationOnLabelCorrect ? "Dekl. korrekt ✓" : "⚠ Deklaration prüfen")
 .font(.caption2)
 .foregroundColor(result.declarationOnLabelCorrect ? Color.theme.success : Color.theme.error)
 }
 }
 .padding(.horizontal, 16).padding(.vertical, 10)
 }
 }
 
 // MARK: - Shared Sub-Components
 
 private struct DetailCardSection<Content: View>: View {
 let title: String
 let icon: String
 @ViewBuilder let content: () -> Content
 
 var body: some View {
 VStack(alignment: .leading, spacing: 8) {
 SectionHeader(title: title, icon: icon)
 VStack(spacing: 0) {
 content()
 }
 .background(Color.theme.cardBg)
 .cornerRadius(14)
 }
 }
 }
 
 struct SectionHeader: View {
 let title: String
 let icon: String
 var body: some View {
 HStack(spacing: 6) {
 Image(systemName: icon)
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg)
 Text(title.uppercased())
 .font(.caption.weight(.semibold))
 .foregroundColor(Color.theme.mutedFg)
 .tracking(0.5)
 }
 }
 }
 
 struct InfoDetailRow: View {
 let label: String
 let value: String
 var valueColor: Color = Color.theme.cardFg
 var body: some View {
 HStack(spacing: 8) {
 Text(label)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg.opacity(0.6))
 .layoutPriority(1)
 Spacer(minLength: 4)
 Text(value)
 .font(.subheadline)
 .foregroundColor(valueColor)
 .multilineTextAlignment(.trailing)
 .lineLimit(3)
 .fixedSize(horizontal: false, vertical: true)
 }
 .padding(.horizontal, 16).padding(.vertical, 11)
 }
 }
 
 private struct DetailRow: View {
 let label: String
 let value: String
 var icon: String? = nil
 var valueColor: Color = Color.theme.cardFg
 var body: some View {
 HStack(spacing: 8) {
 if let icon = icon {
 Image(systemName: icon)
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg.opacity(0.5))
 .frame(width: 16)
 }
 Text(label)
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg.opacity(0.6))
 .layoutPriority(1)
 Spacer(minLength: 4)
 Text(value)
 .font(.subheadline)
 .foregroundColor(valueColor)
 .multilineTextAlignment(.trailing)
 .lineLimit(3)
 .fixedSize(horizontal: false, vertical: true)
 }
 .padding(.horizontal, 16).padding(.vertical, 11)
 }
 }
 
 private struct LocationRow: View {
 let location: TomapoLocation
 var body: some View {
 HStack(spacing: 8) {
 Image(systemName: "location.fill")
 .font(.caption)
 .foregroundColor(Color.theme.mutedFg.opacity(0.5))
 .frame(width: 16)
 Text("Standort")
 .font(.subheadline)
 .foregroundColor(Color.theme.cardFg.opacity(0.6))
 Spacer()
 VStack(alignment: .trailing, spacing: 1) {
 if let name = location.name { Text(name).font(.caption).foregroundColor(Color.theme.cardFg).lineLimit(1) }
 let parts = [location.city, location.region, location.country.flatMap { Locale.current.localizedString(forRegionCode: $0) }].compactMap { $0 }
 if !parts.isEmpty { Text(parts.joined(separator: ", ")).font(.caption2).foregroundColor(Color.theme.mutedFg).lineLimit(1) }
 if let emb = location.embCode { Text("EMB: \(emb)").font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.5)).lineLimit(1) }
 if let gln = location.gln { Text("GLN: \(gln)").font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.4)).lineLimit(1) }
 }
 }
 .padding(.horizontal, 16).padding(.vertical, 11)
 }
 }
 
 // MARK: - Preview
 
 #Preview {
 let stations = TomapoMockData.trace(for: "4316268651288")?.stations ?? []
 TomapoStationDetailView(
 station: stations.first!,
 onBack: {}
 )
 }
 
