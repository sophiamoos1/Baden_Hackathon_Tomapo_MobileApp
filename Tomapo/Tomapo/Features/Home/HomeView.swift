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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: ── Begrüssung + Carousel ───────────────────────
                // .ignoresSafeArea() sorgt dafür dass der Hintergrund
                // auch den Bereich hinter der Statusleiste abdeckt —
                // keine Lücke oben.
                HomeGreetingSection()
                    .padding(.top, 16)
                // EVT: Oppacity ane tue
                    .background(
                        Color.theme.sandMist
                            .ignoresSafeArea(edges: .top)
                    )
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
