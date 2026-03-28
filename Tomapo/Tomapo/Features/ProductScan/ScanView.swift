//
//  ScanView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//  Updated: Two-step scan flow (Barcode → Batch ID via OCR)
//

internal import SwiftUI

struct ScanView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @StateObject private var viewModel = ScannerViewModel()

    @State private var manualBatchText: String = ""

    /// True when there's a confirmable batch ID (OCR or manual >= 4 chars)
    private var canConfirmBatchID: Bool {
        viewModel.batchID != nil ||
        manualBatchText.trimmingCharacters(in: .whitespaces).count >= 4
    }

    var body: some View {
        ZStack {
            Color.theme.baseBg.ignoresSafeArea()

            switch viewModel.permissionState {
            case .authorized:
                cameraContent

            case .denied:
                CameraPermissionDeniedView()

            case .notDetermined:
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear { viewModel.startScanning() }
        .onDisappear { viewModel.stopScanning() }
        .sheet(isPresented: $viewModel.showSheet, onDismiss: {
            manualBatchText = ""
            viewModel.resetAfterSheet()
        }) {
            if let result = viewModel.scanResult {
                ScanResultSheetView(result: result, batchID: viewModel.batchID)
                    .environmentObject(historyStore)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.theme.popoverBg)
            }
        }
    }

    // MARK: - Camera Content

    @ViewBuilder
    private var cameraContent: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let safeBottom = geo.safeAreaInsets.bottom
            let fullHeight = geo.size.height + safeTop + safeBottom
            let frameSize = geo.size.width * 0.64
            let frameCenterY = fullHeight * 0.42
            let frameBottomY = frameCenterY + frameSize / 2

            ZStack(alignment: .top) {
                // Camera preview — fills full screen
                CameraPreviewView(session: viewModel.session)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                // Overlay (dim + brackets + scan line + OCR text)
                ScanFrameOverlay(
                    step: viewModel.scanStep,
                    detectedBatchID: viewModel.batchID
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

                // Top bar: stepper pill + torch button
                // (safe area is respected here — no need for manual inset)
                HStack(spacing: 8) {
                    ScanStepperPill(step: viewModel.scanStep)

                    TorchButton(isOn: viewModel.isTorchOn) {
                        viewModel.toggleTorch()
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)

                // Below-frame content (positioned relative to scan frame)
                VStack(spacing: 12) {
                    if viewModel.scanStep == .barcode {
                        step1HintText
                    } else {
                        step2Content
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, frameBottomY - safeTop + 14)
                .animation(.easeInOut(duration: 0.3), value: viewModel.scanStep)
                .animation(.easeInOut(duration: 0.25), value: viewModel.batchID != nil)
            }
        }

        // Transition overlay (barcode scanned → batch ID step)
        if viewModel.showStepTransition, let result = viewModel.scanResult {
            StepTransitionOverlay(barcode: result.value)
                .transition(.opacity)
                .zIndex(10)
        }
    }

    // MARK: - Step 1: Hint Text

    private var step1HintText: some View {
        Text("Point QR code or barcode at the frame")
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.65))
            .multilineTextAlignment(.center)
    }

    // MARK: - Step 2: Badge + Hint + Fallback + Skip

    @ViewBuilder
    private var step2Content: some View {
        // Detected badge (from OCR)
        if let detected = viewModel.batchID {
            BatchIDDetectedBadge(batchID: detected)
                .transition(.scale.combined(with: .opacity))
        }

        // Hint text
        Text("Scan the Batch ID (L-number) on the packaging")
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.65))
            .multilineTextAlignment(.center)

        // Fallback label
        Text("Not found? Enter manually:")
            .font(.system(size: 10))
            .foregroundColor(Color.theme.mutedFg)

        // Input row + confirm button
        HStack(spacing: 8) {
            TextField("L\u{00B7}\u{00B7}\u{00B7}\u{00B7}\u{00B7}", text: $manualBatchText)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color.theme.baseFg)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .frame(width: 90)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.mutedBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.theme.border, lineWidth: 0.5)
                        )
                )

            Button {
                if manualBatchText.trimmingCharacters(in: .whitespaces).count >= 4 {
                    viewModel.setManualBatchID(manualBatchText)
                }
                viewModel.confirmBatchID()
            } label: {
                Text("Confirm")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.theme.baseFg)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.theme.accentFg)
                    )
            }
            .disabled(!canConfirmBatchID)
            .opacity(canConfirmBatchID ? 1.0 : 0.45)
        }

        // Skip — subtle underlined text link
        Button {
            viewModel.skipBatchID()
        } label: {
            Text("Skip")
                .font(.system(size: 11))
                .foregroundColor(Color.theme.mutedFg)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.theme.mutedFg),
                    alignment: .bottom
                )
        }
    }
}

// MARK: - Torch Button

struct TorchButton: View {
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(isOn ? Color.theme.accentBg : Color.theme.cardBg)
                .overlay(
                    Circle()
                        .stroke(Color.theme.border, lineWidth: 0.5)
                )
                .frame(width: 36, height: 36)

            Image(systemName: isOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isOn ? Color.theme.accentFg : Color.theme.baseFg)
        }
        .onTapGesture { onToggle() }
    }
}

// MARK: - Camera Permission Denied

struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.theme.baseFg)

            Text("Camera Access Denied")
                .font(.headline)
                .foregroundColor(Color.theme.baseFg)

            Text("Please allow camera access in Settings to scan QR codes and barcodes.")
                .font(.subheadline)
                .foregroundColor(Color.theme.baseFg.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
            .tint(Color.theme.baseFg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.baseBg.ignoresSafeArea())
    }
}

#Preview {
    ScanView(selectedTab: .constant(.scan))
        .environmentObject(ThemeManager())
        .environmentObject(ScanHistoryStore())
}
