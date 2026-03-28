//
//  HomeView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: ── Begrüssung + Carousel ───────────────────────
                    HomeGreetingSection()
                        .padding(.top, geo.safeAreaInsets.top + 16)
                        .background(Color.theme.sandMist)
                        .padding(.bottom, 28)

                    // MARK: ── Restlicher Home-Content ─────────────────────
                    VStack(alignment: .leading, spacing: 24) {

                        // TODO: - Following content..
                        Color.clear.frame(height: 600)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    ZStack {
        GeometryReader { geo in
            Image("TomapBackground")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .ignoresSafeArea()
        HomeView(selectedTab: .constant(.home))
            .environmentObject(ThemeManager())
    }
}
