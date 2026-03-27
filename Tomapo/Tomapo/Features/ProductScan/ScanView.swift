//
//  ScanView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

import SwiftUI
 
struct ScanView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager
   // @EnvironmentObject private var historyStore: ScanHistoryStore
    @StateObject private var viewModel = ScannerViewModel()
 
    var body: some View {
        ZStack {
            // Deckt das globale Hintergrundbild der ContentView ab
            Color.theme.oatMilk.ignoresSafeArea()
 
            // MARK: - Kamera oder Fallback
            switch viewModel.permissionState {
            case .authorized:
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()
 
                ScanOverlayView()
 
                VStack {
                    HStack {
                        Spacer()
                        TorchButton(isOn: viewModel.isTorchOn) {
                            viewModel.toggleTorch()
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }
 
            case .denied:
                CameraPermissionDeniedView()
 
            case .notDetermined:
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear  { viewModel.startScanning() }
        .onDisappear { viewModel.stopScanning() }
        // MARK: - Bottom Sheet bei erkanntem Code
        .sheet(isPresented: $viewModel.showSheet, onDismiss: {
            viewModel.scanResult = nil
        }) {
            if let result = viewModel.scanResult {
                ScanResultSheetView2(result: result)
                    // EnvironmentObjects werden von Sheets nicht automatisch
                    // geerbt – müssen explizit weitergegeben werden.
                    // https://developer.apple.com/documentation/swiftui/view/sheet
                    .environmentObject(historyStore)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.theme.background)
            }
        }
    }
}
 
// MARK: - Torch Button
struct TorchButton: View {
    let isOn: Bool
    let onLongPress: () -> Void
 
    var body: some View {
        ZStack {
            Circle()
                .fill(isOn ? Color.yellow.opacity(0.85) : Color.black.opacity(0.45))
                .frame(width: 48, height: 48)
            Image(systemName: isOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isOn ? .black : .white)
        }
        .onLongPressGesture(minimumDuration: 0.4) { onLongPress() }
    }
}
 
// MARK: - Scan Overlay
struct ScanOverlayView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.45)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: geo.size.width * 0.72, height: geo.size.width * 0.72)
                                    .blendMode(.destinationOut)
                            )
                    )
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: geo.size.width * 0.72, height: geo.size.width * 0.72)
                VStack {
                    Spacer()
                        .frame(height: geo.size.height * 0.5 + geo.size.width * 0.38)
                    Text("QR-Code oder Barcode in den Rahmen halten")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
        .ignoresSafeArea()
    }
}
 
// MARK: - Kamera verweigert
struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.theme.secondaryText)
            Text("Kamerazugriff verweigert")
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
            Text("Bitte erlaube den Kamerazugriff in den Einstellungen um QR-Codes scannen zu können.")
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Einstellungen öffnen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
            .tint(Color.theme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Deckt das globale Hintergrundbild vollständig ab
        .background(Color.theme.oatMilk.ignoresSafeArea())
    }
}
 
#Preview {
    ScanView(selectedTab: .constant(.scan))
        .environmentObject(ThemeManager())
}
