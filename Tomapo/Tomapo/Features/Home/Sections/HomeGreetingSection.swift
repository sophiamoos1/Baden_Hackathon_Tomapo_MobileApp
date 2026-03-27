//
//  HomeGreetingSection.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
 
struct HomeGreetingSection: View {
 
    @AppStorage("username") private var username: String = "Sophia"
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
 
            // MARK: Begrüssungstitel
            Text("Welcome back, \(username)!")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.importantText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
 
            // MARK: Subtitle
            Text("wanna see what's new?")
                .font(.body)
                .foregroundColor(Color.theme.bodyText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
 
            // MARK: News Carousel
            NewsCarousel()
                .padding(.top, 4)
                .padding(.bottom, 8)
        }
    }
}
 
#Preview {
    HomeGreetingSection()
        .background(Color.theme.oatMilk)
}
 
