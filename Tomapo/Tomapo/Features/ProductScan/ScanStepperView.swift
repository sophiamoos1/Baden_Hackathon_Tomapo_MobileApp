//
//  ScanStepperView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

// MARK: - Stepper Pill (Segmented Bar)

struct ScanStepperPill: View {
    let step: ScanStep

    private enum StepState { case active, done, inactive }

    var body: some View {
        HStack(spacing: 0) {
            segment(number: 1, label: "Barcode",
                    state: step == .barcode ? .active : .done)

            Rectangle()
                .fill(Color.theme.border.opacity(0.3))
                .frame(width: 0.5)

            segment(number: 2, label: "Batch ID",
                    state: step == .batchID ? .active : .inactive)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.theme.cardBg.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.border, lineWidth: 0.5)
        )
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    @ViewBuilder
    private func segment(number: Int, label: String, state: StepState) -> some View {
        HStack(spacing: 7) {
            // Number badge — rounded rectangle (not circle)
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(numBg(state))
                    .frame(width: 20, height: 20)
                if state == .inactive {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.theme.mutedFg, lineWidth: 0.5)
                        .frame(width: 20, height: 20)
                }

                if state == .done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color.theme.primaryFg)
                } else {
                    Text("\(number)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(numFg(state))
                }
            }

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(labelColor(state))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(state == .active ? Color.theme.border.opacity(0.35) : Color.clear)
    }

    private func numBg(_ state: StepState) -> Color {
        switch state {
        case .active:   return Color.theme.accentBg
        case .done:     return Color.theme.primaryBg
        case .inactive: return .clear
        }
    }

    private func numFg(_ state: StepState) -> Color {
        switch state {
        case .active:   return Color.theme.accentFg
        case .done:     return Color.theme.primaryFg
        case .inactive: return Color.theme.mutedFg
        }
    }

    private func labelColor(_ state: StepState) -> Color {
        switch state {
        case .active:   return Color.theme.baseFg
        case .done, .inactive: return Color.theme.mutedFg
        }
    }
}

// MARK: - Scan Frame Overlay (Dim + Corner Brackets + Scan Line + OCR Text)

struct ScanFrameOverlay: View {
    let step: ScanStep
    var detectedBatchID: String?

    var body: some View {
        GeometryReader { geo in
            let frameSize = geo.size.width * 0.64
            let frameCenterY = geo.size.height * 0.42
            let yOffset = frameCenterY - geo.size.height / 2

            ZStack {
                // Semi-transparent overlay with rounded cutout
                Color.black.opacity(0.42)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: frameSize, height: frameSize)
                                    .offset(y: yOffset)
                                    .blendMode(.destinationOut)
                            )
                    )

                // Corner brackets (L-shaped corners)
                CornerBracketsShape(armLength: 22, cornerRadius: 6)
                    .stroke(Color.theme.border, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: frameSize, height: frameSize)
                    .offset(y: yOffset)

                // Animated scan line (Step 2 only)
                if step == .batchID {
                    ScanLineView(width: frameSize * 0.86)
                        .offset(y: yOffset)
                }

                // OCR detected text inside frame (Step 2)
                if let batchID = detectedBatchID, step == .batchID {
                    Text(batchID)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.9))
                        .offset(y: yOffset)
                        .transition(.opacity)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Corner Brackets Shape

private struct CornerBracketsShape: Shape {
    let armLength: CGFloat
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let a = armLength
        let r = cornerRadius

        // Top-left
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + a))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX + a, y: rect.minY))

        // Top-right
        p.move(to: CGPoint(x: rect.maxX - a, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + a))

        // Bottom-right
        p.move(to: CGPoint(x: rect.maxX, y: rect.maxY - a))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: rect.maxY),
                       control: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX - a, y: rect.maxY))

        // Bottom-left
        p.move(to: CGPoint(x: rect.minX + a, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - r),
                       control: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - a))

        return p
    }
}

// MARK: - Animated Scan Line

private struct ScanLineView: View {
    let width: CGFloat
    @State private var offset: CGFloat = -60

    var body: some View {
        Rectangle()
            .fill(Color.theme.accentFg.opacity(0.85))
            .frame(width: width, height: 2)
            .clipShape(Capsule())
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    offset = 60
                }
            }
    }
}

// MARK: - Step Transition Overlay

struct StepTransitionOverlay: View {
    let barcode: String
    @State private var phase: TransitionPhase = .appearing

    private enum TransitionPhase { case appearing, visible, disappearing }

    var body: some View {
        ZStack {
            Color.black.opacity(overlayOpacity)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.theme.primaryBg)
                        .frame(width: 64, height: 64)
                        .scaleEffect(checkScale)

                    Image(systemName: "checkmark")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color.theme.primaryFg)
                        .scaleEffect(checkScale)
                }

                Text(barcode)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .opacity(textOpacity)

                Text("Continue with Batch ID Scan")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                phase = .visible
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.1))
                withAnimation(.easeOut(duration: 0.4)) {
                    phase = .disappearing
                }
            }
        }
    }

    private var overlayOpacity: Double {
        switch phase {
        case .appearing:    return 0.0
        case .visible:      return 0.65
        case .disappearing: return 0.0
        }
    }

    private var checkScale: CGFloat {
        switch phase {
        case .appearing:    return 0.3
        case .visible:      return 1.0
        case .disappearing: return 1.1
        }
    }

    private var textOpacity: Double {
        switch phase {
        case .appearing:    return 0.0
        case .visible:      return 1.0
        case .disappearing: return 0.0
        }
    }
}

// MARK: - Detected Badge

struct BatchIDDetectedBadge: View {
    let batchID: String

    var body: some View {
        HStack(spacing: 6) {
            Text("\(batchID) detected")
                .font(.system(size: 11, weight: .medium))
            Text("\u{2713}")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(Color.theme.primaryFg)
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.theme.primaryBg)
                .overlay(
                    Capsule()
                        .stroke(Color.theme.primaryFg.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}
