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

            // MARK: Greeting + Illustration
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back, \(username)!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.cardFg)
                        .lineLimit(2)

                    Text("wanna see what's new?")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.mutedFg)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image("IllustrationScan")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
            }
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
        .background(Color.theme.cardBg)
}
 
