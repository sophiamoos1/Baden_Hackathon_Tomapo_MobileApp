//
//  BottomBar.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI
internal import PhosphorSwift
 
enum BottomBarSelectedTab: Int {
    case home     = 0
    case history  = 1
    case scan     = 2
    case messages = 3
    case profile  = 4
}
 
struct BottomBar: View {
    @Binding var selectedTab: BottomBarSelectedTab
 
    var body: some View {
        HStack(spacing: 4) {
            BottomBarButton(
                icon: Ph.house.duotone,
                text: "Home",
                isActive: selectedTab == .home
            ) { selectedTab = .home }
 
            BottomBarButton(
                icon: Ph.clockCounterClockwise.duotone,
                text: "History",
                isActive: selectedTab == .history
            ) { selectedTab = .history }
 
            BottomBarButton(
                icon: Ph.scan.duotone,
                text: "Scan",
                isActive: selectedTab == .scan
            ) { selectedTab = .scan }
 
            BottomBarButton(
                icon: Ph.chatTeardropText.duotone,
                text: "Messages",
                isActive: selectedTab == .messages
            ) { selectedTab = .messages }
 
            BottomBarButton(
                icon: Ph.userGear.duotone,
                text: "Profile",
                isActive: selectedTab == .profile
            ) { selectedTab = .profile }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Color.theme.oatMilk
                .cornerRadius(30)
        )
        // Abstand zu den 3 Seiten (links, rechts, unten)
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }
}
 
// MARK: - Single Tab Button
private struct BottomBarButton<Icon: View>: View {
    let icon: Icon
    let text: String
    let isActive: Bool
    let action: () -> Void
 
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                icon
                    .frame(width: 20, height: 20)
                    .foregroundColor(
                        isActive ? Color.theme.bodyText : Color.theme.oatMilk
                    )
 
                if isActive {
                    Text(text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.theme.bodyText)
                        .lineLimit(1)
                        .fixedSize()
                        .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .leading)))
                }
            }
            .padding(.horizontal, isActive ? 12 : 14)
            .padding(.vertical, 8)
            .background(
                isActive
                    ? Color.theme.softOliveFog.cornerRadius(30)
                    : Color.clear.cornerRadius(30)
            )
            // Aktiver Tab: so breit wie nötig (Icon + Text + Padding)
            // Inaktiver Tab: nur Icon-Breite, kein maxWidth: .infinity
            .fixedSize(horizontal: !isActive, vertical: false)
            // Aktiver Tab füllt den verbleibenden Raum nicht auf –
            // stattdessen drängen die inaktiven Tabs zusammen
            .frame(maxWidth: isActive ? .infinity : nil)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isActive)
    }
}
 
#Preview {
    VStack {
        Spacer()
        BottomBar(selectedTab: .constant(.messages))
    }
    .background(Color.theme.oatMilk)
}
