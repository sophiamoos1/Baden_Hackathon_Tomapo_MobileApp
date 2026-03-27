//
//  Color.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Core Colors
    let warmPearl = Color("core-warmPearl")
    let oatMilk = Color("core-oatMilk")
    let sandMist = Color("core-sandMist")
    let paleMoss = Color("core-paleMoss")
    let softOliveFog = Color("core-softOliveFog")
    let mutedSage = Color("core-mutedSage")
    let clayLinen = Color("core-clayLinen")
    let stoneGreenGrey = Color("core-stoneGreenGrey")
    
    // Accent Colors
    let accentAppricot = Color("accentApricot")
    let accentAppricotLight = Color("accentApricotLight")
    let accentTerracotta = Color("accentTerracotta")
    
    // Text Colors
    let largeTitle = Color("text-largeTitle")
    let importantText = Color("text-importantText")
    let bodyText = Color("text-bodyText")
    
    // Status Colors
    let error = Color("status-error")
    let warning = Color("status-warning")
    let success = Color("status-success")
    let infso = Color("status-info")
    
    // Chart Colors
    let chartDustyOlive = Color("chart-dustyOlive")
    let chartSoftMossTeal = Color("chart-softMossTeal")
    let chartMutedSkyClay = Color("chart-MutedSkyClay")
    let chartWarmSandAmber = Color("chart-warmSandAmber")
    let chartTerracottaRose = Color("chart-terracottaRose")
    let chartMutedPlumEarth = Color("chart-mutedPlumEarth")
}
