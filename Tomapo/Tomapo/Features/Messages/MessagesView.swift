//
//  MessagesView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
 
struct MessagesView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager
 
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
 
                // MARK: - following content..
 
            }
            .padding(.top, 16)
        }
    }
}
 
#Preview {
    MessagesView(selectedTab: .constant(.messages))
        .environmentObject(ThemeManager())
        .background(Color.theme.background)
}
