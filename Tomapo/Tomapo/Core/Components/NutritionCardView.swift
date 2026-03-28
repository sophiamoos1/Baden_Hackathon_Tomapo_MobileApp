//
//  NutritionCardView.swift
//  Tomapo
//
//  Created by Sophia Moos on 28.03.2026.
//

internal import SwiftUI

// MARK: - Public API

struct NutritionCardView: View {
    let nutriments: ProductNutriments
    var servingSize: String? = nil

    // Macro colors from chart theme
    private var carbsColor: Color { Color.theme.chartWarmSandAmber }
    private var proteinColor: Color { Color.theme.chartTerracottaRose }
    private var fatColor: Color { Color.theme.chartMutedSkyClay }
    private var saltColor: Color { Color.theme.chartSoftMossTeal }

    // EU daily reference intake values
    private let refCarbs: Double = 300
    private let refSugars: Double = 90
    private let refProtein: Double = 50
    private let refFat: Double = 70
    private let refSaturatedFat: Double = 20
    private let refSalt: Double = 6
    private let refFiber: Double = 25

    private var kcal: Int { Int(nutriments.energyKcal100g ?? 0) }
    private var carbs: Double { nutriments.carbohydrates100g ?? 0 }
    private var protein: Double { nutriments.proteins100g ?? 0 }
    private var fat: Double { nutriments.fat100g ?? 0 }
    private var sugars: Double { nutriments.sugars100g ?? 0 }
    private var saturatedFat: Double { nutriments.saturatedFat100g ?? 0 }
    private var salt: Double { nutriments.salt100g ?? 0 }
    private var fiber: Double { nutriments.fiber100g ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("Nutrition")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.cardFg)
                Spacer()
                Text("pro 100 g")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.theme.mutedFg)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 3)
                    .background(Color.theme.mutedBg)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            // Ring chart + macro legend
            HStack(spacing: 24) {
                MacroRingChart(
                    kcal: kcal,
                    carbs: carbs,
                    protein: protein,
                    fat: fat,
                    carbsColor: carbsColor,
                    proteinColor: proteinColor,
                    fatColor: fatColor
                )
                .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: 11) {
                    MacroLegendRow(color: carbsColor, name: "Carbohydrates", value: carbs)
                    MacroLegendRow(color: proteinColor, name: "Protein", value: protein)
                    MacroLegendRow(color: fatColor, name: "Fat", value: fat)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 20)

            // Divider
            Rectangle()
                .fill(Color.theme.border)
                .frame(height: 0.5)
                .padding(.horizontal, 20)

            // Nutrient bars
            VStack(spacing: 13) {
                NutrientBar(name: "Carbohydrates", value: carbs, ref: refCarbs, color: carbsColor)
                NutrientBar(name: "of which sugars", value: sugars, ref: refSugars, color: carbsColor, isSub: true)
                NutrientBar(name: "Protein", value: protein, ref: refProtein, color: proteinColor)
                NutrientBar(name: "Fat", value: fat, ref: refFat, color: fatColor)
                NutrientBar(name: "of which saturated", value: saturatedFat, ref: refSaturatedFat, color: fatColor, isSub: true)
                NutrientBar(name: "Salt", value: salt, ref: refSalt, color: saltColor)
                if fiber > 0 {
                    NutrientBar(name: "Fiber", value: fiber, ref: refFiber, color: Color.theme.mutedFg)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Reference note
            Text("Reference values based on a daily intake of 2,000 kcal for an average adult")
                .font(.system(size: 10))
                .foregroundColor(Color.theme.mutedFg)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, servingSize != nil ? 10 : 18)

            // Serving size (optional)
            if let serving = servingSize {
                Text("Serving size: \(serving)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.theme.mutedFg)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
            }
        }
        .background(Color.theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.theme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Macro Ring Chart

private struct MacroRingChart: View {
    let kcal: Int
    let carbs: Double
    let protein: Double
    let fat: Double
    let carbsColor: Color
    let proteinColor: Color
    let fatColor: Color

    private let lineWidth: CGFloat = 11
    private let gap: CGFloat = 0.008

    private var carbsKcal: Double { carbs * 4 }
    private var proteinKcal: Double { protein * 4 }
    private var fatKcal: Double { fat * 9 }
    private var totalKcal: Double { carbsKcal + proteinKcal + fatKcal }

    private var carbsFrac: CGFloat {
        totalKcal > 0 ? CGFloat(carbsKcal / totalKcal) : 0.33
    }
    private var proteinFrac: CGFloat {
        totalKcal > 0 ? CGFloat(proteinKcal / totalKcal) : 0.33
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.theme.mutedBg, lineWidth: lineWidth)

            // Carbs segment
            Circle()
                .trim(from: gap / 2, to: carbsFrac - gap / 2)
                .stroke(carbsColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Protein segment
            Circle()
                .trim(from: carbsFrac + gap / 2, to: carbsFrac + proteinFrac - gap / 2)
                .stroke(proteinColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Fat segment
            Circle()
                .trim(from: carbsFrac + proteinFrac + gap / 2, to: 1.0 - gap / 2)
                .stroke(fatColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Center kcal label
            VStack(spacing: 2) {
                Text("\(kcal)")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.theme.cardFg)
                Text("kcal")
                    .font(.system(size: 10))
                    .foregroundColor(Color.theme.mutedFg)
            }
        }
    }
}

// MARK: - Macro Legend Row

private struct MacroLegendRow: View {
    let color: Color
    let name: String
    let value: Double

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(Color.theme.mutedFg)
            Spacer()
            Text(formatGrams(value))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.theme.cardFg)
        }
    }

    private func formatGrams(_ v: Double) -> String {
        v >= 10 ? "\(Int(v)) g" : String(format: "%.1f g", v)
    }
}

// MARK: - Nutrient Bar

private struct NutrientBar: View {
    let name: String
    let value: Double
    let ref: Double
    let color: Color
    var isSub: Bool = false

    private var fraction: CGFloat {
        ref > 0 ? min(CGFloat(value / ref), 1.0) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(isSub ? .system(size: 11) : .system(size: 12, weight: .medium))
                    .foregroundColor(isSub ? Color.theme.mutedFg : Color.theme.cardFg)
                    .padding(.leading, isSub ? 14 : 0)
                Spacer()
                HStack(spacing: 2) {
                    Text(formatGrams(value))
                        .font(.system(size: 11))
                        .foregroundColor(Color.theme.mutedFg)
                    Text("/ \(Int(ref)) g")
                        .font(.system(size: 10))
                        .foregroundColor(Color.theme.mutedFg)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.theme.mutedBg)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(isSub ? 0.5 : 1.0))
                        .frame(width: max(geo.size.width * fraction, 2))
                }
            }
            .frame(height: isSub ? 4 : 6)
        }
    }

    private func formatGrams(_ v: Double) -> String {
        if v >= 10 { return "\(Int(v)) g" }
        return String(format: "%.1f g", v)
    }
}
