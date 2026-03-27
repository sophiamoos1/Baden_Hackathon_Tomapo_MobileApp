//
//  ProfileView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Theme Switcher
                Toggle("Dark Mode", isOn: Binding(
                    get: { themeManager.currentScheme == .dark },
                    set: { _ in themeManager.toggleTheme() }
                ))
                .padding()
                .background(Color.theme.bottomBarBackground)
                .cornerRadius(12)
                .padding(.horizontal)

                // TODO: - Following content..

            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    ProfileView(selectedTab: .constant(.profile))
        .environmentObject(ThemeManager())
        .background(Color.theme.background)
}
