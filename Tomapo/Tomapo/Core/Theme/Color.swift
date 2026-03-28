//
//  Color.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import Foundation
internal import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    //Primary Colors
     let primaryBg = Color("primaryBG")
     let primaryFg = Color("primaryFG")
     
     //Secondary Colors
     let secondaryBg = Color("secondaryBG") //kein plan
     let secondaryFg = Color("secondaryFG") //Dark Oat dark Palette

     //Accent
     let accentBg = Color("accentBG")
     let accentFg = Color("accentFG")

     //Base
     let baseBg = Color("baseBG")
     let baseFg = Color("baseFG")

     //Card
     let cardBg = Color("cardBG")
     let cardFg = Color("cardFG") //Night Soil

     //Popover
     let popoverBg = Color("popoverBG")
     let popoverFg = Color("popoverFG") //kein plan dark Palette

     //Muted
     let mutedBg = Color("mutedBG")
     let mutedFg = Color("mutedFG")

     //Destructive
     let destructiveBg = Color("destructiveBG") //kein plan
     let destructiveFg = Color("destructiveFG")

     //Border
     let border = Color("border")
     let input = Color("input")
     let ring = Color("ring")

     //Chart
     let cart1 = Color("core-dustyOlive")
     let cart2 = Color("core-softMossTeal")
     let cart3 = Color("core-terracottaRose")
     let cart4 = Color("core-warmSandAmber")
     let cart5 = Color("core-MutedSkyClay")

     //Sidebar
     let navBg = Color("navBG")
     let navFg = Color("navFG")
     let navPrimaryBg = Color("navPrimaryBG")
     let navPrimaryFg = Color("navPrimaryFG")
    
    // Status Colors
    let error = Color("status-error")
    let warning = Color("status-warning")
    let success = Color("status-success")
    let infso = Color("status-info")
  
    
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
    
    
    // Chart Colors
    let chartDustyOlive = Color("chart-dustyOlive")
    let chartSoftMossTeal = Color("chart-softMossTeal")
    let chartMutedSkyClay = Color("chart-MutedSkyClay")
    let chartWarmSandAmber = Color("chart-warmSandAmber")
    let chartTerracottaRose = Color("chart-terracottaRose")
    let chartMutedPlumEarth = Color("chart-mutedPlumEarth")

}
