//
//  ContentView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
 
struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var popupManager = PopupManager()
   // @StateObject private var historyStore = ScanHistoryStore()
    @State var selectedTab: BottomBarSelectedTab = .home
    @State private var scanSessionID = UUID()
 
    var body: some View {
        ZStack {
 
            // MARK: – Globales Hintergrundbild
            GeometryReader { geo in
                Image("TomapBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
 
            // MARK: – App-Screens + BottomBar
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)
                    case .history:
                        ScannedProductsHistoryView(selectedTab: $selectedTab)
                    case .scan:
                        ScanView(selectedTab: $selectedTab).id(scanSessionID)
                    case .messages:
                        MessagesView(selectedTab: $selectedTab)
                    case .profile:
                        ProfileView(selectedTab: $selectedTab)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomBar(selectedTab: $selectedTab)
                    .background(.clear)
            }
 
            // MARK: – Screen-Level Popup
            if let item = popupManager.activeItem {
                CardDetailsPopup(item: item) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        popupManager.dismiss()
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(100)
                .animation(.easeInOut(duration: 0.22), value: popupManager.isShowing)
            }
        }
        .preferredColorScheme(themeManager.currentScheme)
        .environmentObject(themeManager)
        .environmentObject(popupManager)
        .environmentObject(historyStore)
        .onChange(of: selectedTab) { newTab in
            if newTab == .scan { scanSessionID = UUID() }
        }
    }
}
 
#Preview { ContentView() }
struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView() }
}
