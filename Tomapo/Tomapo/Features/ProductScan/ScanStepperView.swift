//
//  ScanStepperView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

// MARK: - Stepper Pill

struct ScanStepperPill: View {
    let step: ScanStep

    var body: some View {
        HStack(spacing: 0) {
            stepItem(
                number: 1,
                label: "Barcode",
                state: step == .barcode ? .active : .done
            )

            Rectangle()
                .fill(Color.theme.border)
                .frame(width: 16, height: 1)
                .padding(.horizontal, 4)

            stepItem(
                number: 2,
                label: "Batch ID",
                state: step == .batchID ? .active : .inactive
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.border, lineWidth: 0.5)
                )
        )
    }

    // MARK: Step state

    private enum StepState { case active, done, inactive }

    @ViewBuilder
    private func stepItem(number: Int, label: String, state: StepState) -> some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(circleFill(state))
                    .frame(width: 22, height: 22)
                Group {
                    if state == .done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .semibold))
                    } else {
                        Text("\(number)")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(circleFg(state))
            }

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(labelColor(state))
        }
    }

    // MARK: Color helpers

    private func circleFill(_ state: StepState) -> Color {
        switch state {
        case .active:   return Color.theme.accentBg
        case .done:     return Color.theme.primaryBg
        case .inactive: return Color.theme.mutedBg
        }
    }

    private func circleFg(_ state: StepState) -> Color {
        switch state {
        case .active:   return Color.theme.accentFg
        case .done:     return Color.theme.primaryFg
        case .inactive: return Color.theme.mutedFg
        }
    }

    private func labelColor(_ state: StepState) -> Color {
        state == .inactive ? Color.theme.mutedFg : Color.theme.baseFg
    }
}

// MARK: - Scan Overlay

struct ScanOverlayView: View {
    let step: ScanStep

    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width * 0.72
            ZStack {
                Color.black.opacity(0.45)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: size, height: size)
                                    .blendMode(.destinationOut)
                            )
                    )

                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.theme.border.opacity(0.9), lineWidth: 2.5)
                    .frame(width: size, height: size)

                if step == .batchID {
                    ScanLineView(width: size * 0.78)
                }

                VStack {
                    Spacer()
                        .frame(height: geo.size.height * 0.5 + size * 0.5 + 16)
                    Text(step == .barcode
                         ? "QR-Code oder Barcode in den Rahmen halten"
                         : "Batch ID (L-Nummer) auf der Verpackung scannen")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Animated scan line

private struct ScanLineView: View {
    let width: CGFloat
    @State private var offset: CGFloat = -60

    var body: some View {
        Rectangle()
            .fill(Color.theme.secondaryBg.opacity(0.88))
            .frame(width: width, height: 2)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    offset = 60
                }
            }
    }
}

// MARK: - Batch ID Fallback Bar

struct BatchIDFallbackBar: View {
    @Binding var manualText: String
    let onConfirm: (String) -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Text("Batch ID nicht gefunden? Manuell eingeben:")
                .font(.caption2)
                .foregroundColor(Color.theme.mutedFg)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                TextField("L·····", text: $manualText)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.theme.baseFg)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .frame(width: 100)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color.theme.mutedBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .stroke(Color.theme.border, lineWidth: 0.5)
                            )
                    )

                Button {
                    onConfirm(manualText)
                } label: {
                    Text("Bestätigen")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.theme.secondaryFg)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 11)
                                .fill(Color.theme.secondaryBg)
                        )
                }
                .disabled(manualText.trimmingCharacters(in: .whitespaces).count < 4)
            }

            Button("Überspringen") {
                onSkip()
            }
            .font(.caption2)
            .foregroundColor(Color.theme.mutedFg.opacity(0.6))
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(Color.theme.mutedBg)
    }
}

// MARK: - Detected Badge

struct BatchIDDetectedBadge: View {
    let batchID: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
            Text("\(batchID) erkannt")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Color.theme.primaryFg)
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.theme.primaryBg)
                .overlay(
                    Capsule()
                        .stroke(Color.theme.primaryFg.opacity(0.25), lineWidth: 0.5)
                )
        )
    }
}
