//
//  CameraScanner.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//  Updated: Two-step scan flow — Barcode + Batch ID via OCR (Vision)
//

internal import AVFoundation
internal import SwiftUI
internal import Vision

// MARK: - Scan Result Model

struct ScanResult: Identifiable {
    let id = UUID()
    let value: String
    let type: String
}

// MARK: - Scan Step

enum ScanStep {
    case barcode   // Step 1: EAN / QR
    case batchID   // Step 2: OCR for L-number printed on packaging
}

// MARK: - Camera Permission State

enum CameraPermissionState {
    case notDetermined
    case authorized
    case denied
}

// MARK: - Scanner Coordinator (AVFoundation Delegates)

nonisolated class ScannerCoordinator: NSObject,
    AVCaptureMetadataOutputObjectsDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate,
    @unchecked Sendable
{
    var onCodeScanned: ((ScanResult) -> Void)?
    var onBatchIDDetected: ((String) -> Void)?
    var ocrEnabled: Bool = false

    private var lastScannedValue: String = ""
    private var lastScanTime: Date = .distantPast
    private var lastOCRTime: Date = .distantPast
    private var lastBatchID: String = ""

    // Matches L followed by 4-10 uppercase alphanumerics, dash optional
    // e.g. L7234B, L2025001, L-7234B
    private let batchIDRegex = try! NSRegularExpression(
        pattern: #"\bL[-]?[A-Z0-9]{4,10}\b"#,
        options: .caseInsensitive
    )

    // MARK: Barcode delegate

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = metadata.stringValue else { return }

        let now = Date()
        guard value != lastScannedValue || now.timeIntervalSince(lastScanTime) > 2.0 else { return }

        lastScannedValue = value
        lastScanTime = now

        let typeName = metadata.type.rawValue
            .replacingOccurrences(of: "org.iso.", with: "")
            .replacingOccurrences(of: "com.apple.", with: "")
            .uppercased()

        let result = ScanResult(value: value, type: typeName)

        DispatchQueue.main.async {
            self.onCodeScanned?(result)
        }
    }

    // MARK: Video frame delegate (OCR)

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard ocrEnabled else { return }
        let now = Date()
        guard now.timeIntervalSince(lastOCRTime) >= 1.0 else { return }
        lastOCRTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNRecognizeTextRequest { [weak self] req, _ in
            guard let self else { return }
            guard let observations = req.results as? [VNRecognizedTextObservation] else { return }
            for obs in observations {
                guard let candidate = obs.topCandidates(1).first else { continue }
                let text = candidate.string
                let range = NSRange(text.startIndex..., in: text)
                if let match = self.batchIDRegex.firstMatch(in: text, range: range),
                   let swiftRange = Range(match.range, in: text) {
                    let normalised = String(text[swiftRange])
                        .uppercased()
                        .replacingOccurrences(of: "-", with: "")
                    guard normalised != self.lastBatchID else { continue }
                    self.lastBatchID = normalised
                    DispatchQueue.main.async { self.onBatchIDDetected?(normalised) }
                    return
                }
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    func resetBatchID() { lastBatchID = "" }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    /// Eigene UIView-Subklasse, deren layoutSubviews() den PreviewLayer
    /// automatisch auf die aktuelle Grösse anpasst.
    class PreviewUIView: UIView {
        let previewLayer = AVCaptureVideoPreviewLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .black
            layer.addSublayer(previewLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
        }
    }
}

// MARK: - Scanner ViewModel

@MainActor
class ScannerViewModel: ObservableObject {

    @Published var scanResult: ScanResult? = nil
    @Published var batchID: String? = nil
    @Published var showSheet: Bool = false
    @Published var permissionState: CameraPermissionState = .notDetermined
    @Published var isTorchOn: Bool = false
    @Published var scanStep: ScanStep = .barcode

    nonisolated(unsafe) let session = AVCaptureSession()
    nonisolated(unsafe) private let coordinator = ScannerCoordinator()
    nonisolated(unsafe) private let sessionQueue = DispatchQueue(label: "dev.wheresmytomato.sessionQueue")
    nonisolated(unsafe) private let videoQueue = DispatchQueue(label: "dev.wheresmytomato.videoQueue")
    nonisolated(unsafe) private var isConfiguring = false
    nonisolated(unsafe) private var stopRequestedDuringConfig = false
    nonisolated(unsafe) private var isStopped = false

    init() {
        coordinator.onCodeScanned = { [weak self] result in
            guard let self else { return }
            self.scanResult = result
            self.scanStep = .batchID
            self.coordinator.ocrEnabled = true
            self.pauseBarcodeScanning()
        }
        coordinator.onBatchIDDetected = { [weak self] id in
            guard let self else { return }
            self.batchID = id
            self.coordinator.ocrEnabled = false
            self.showSheet = true
        }
    }

    // MARK: Public API

    func startScanning() {
        scanStep = .barcode
        batchID = nil
        coordinator.ocrEnabled = false
        coordinator.resetBatchID()
        sessionQueue.async { [weak self] in self?.isStopped = false }
        Task { await checkPermissionAndSetup() }
    }

    func stopScanning() {
        setTorch(on: false)
        coordinator.ocrEnabled = false
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.isStopped = true
            if self.isConfiguring { self.stopRequestedDuringConfig = true; return }
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    /// Call on sheet dismiss — resets state and restarts barcode scanning from Step 1
    func resetAfterSheet() {
        scanResult = nil
        batchID = nil
        scanStep = .barcode
        coordinator.resetBatchID()
        coordinator.ocrEnabled = false
        resumeBarcodeScanning()
    }

    /// Fallback: user typed batch ID manually
    func confirmManualBatchID(_ id: String) {
        let trimmed = id.trimmingCharacters(in: .whitespaces).uppercased()
        guard trimmed.count >= 4 else { return }
        batchID = trimmed
        coordinator.ocrEnabled = false
        showSheet = true
    }

    /// Skip batch ID step and show sheet with barcode only
    func skipBatchID() {
        coordinator.ocrEnabled = false
        showSheet = true
    }

    func toggleTorch() {
        isTorchOn.toggle()
        setTorch(on: isTorchOn)
    }

    // MARK: Private

    private func pauseBarcodeScanning() {
        sessionQueue.async { [weak self] in
            guard let self,
                  let out = self.session.outputs
                    .first(where: { $0 is AVCaptureMetadataOutput }) as? AVCaptureMetadataOutput
            else { return }
            out.setMetadataObjectsDelegate(nil, queue: .main)
        }
    }

    private func resumeBarcodeScanning() {
        sessionQueue.async { [weak self] in
            guard let self,
                  let out = self.session.outputs
                    .first(where: { $0 is AVCaptureMetadataOutput }) as? AVCaptureMetadataOutput
            else { return }
            out.setMetadataObjectsDelegate(self.coordinator, queue: .main)
        }
    }

    private func setTorch(on: Bool) {
        sessionQueue.async {
            guard let device = AVCaptureDevice.default(for: .video),
                  device.hasTorch, device.isTorchAvailable else { return }
            try? device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        }
    }

    private func checkPermissionAndSetup() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionState = .authorized
            setupSession()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            permissionState = granted ? .authorized : .denied
            if granted { setupSession() }
        default:
            permissionState = .denied
        }
    }

    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            guard !self.stopRequestedDuringConfig else {
                self.stopRequestedDuringConfig = false; return
            }

            // Session bereits konfiguriert – einfach neu starten und Delegate setzen
            if !self.session.inputs.isEmpty {
                if let out = self.session.outputs
                    .first(where: { $0 is AVCaptureMetadataOutput }) as? AVCaptureMetadataOutput {
                    out.setMetadataObjectsDelegate(self.coordinator, queue: .main)
                }
                if !self.session.isRunning && !self.isStopped {
                    self.session.startRunning()
                }
                return
            }

            // Erstkonfiguration
            self.isConfiguring = true
            self.session.beginConfiguration()

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                self.isConfiguring = false
                return
            }
            self.session.addInput(input)

            // Barcode output
            let metaOut = AVCaptureMetadataOutput()
            if self.session.canAddOutput(metaOut) {
                self.session.addOutput(metaOut)
                metaOut.setMetadataObjectsDelegate(self.coordinator, queue: .main)
                metaOut.metadataObjectTypes = [
                    .qr, .ean8, .ean13, .pdf417, .upce,
                    .code39, .code93, .code128, .aztec,
                    .dataMatrix, .interleaved2of5, .itf14
                ]
            }

            // Video output for OCR
            let videoOut = AVCaptureVideoDataOutput()
            videoOut.alwaysDiscardsLateVideoFrames = true
            videoOut.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]
            if self.session.canAddOutput(videoOut) {
                self.session.addOutput(videoOut)
                videoOut.setSampleBufferDelegate(self.coordinator, queue: self.videoQueue)
            }

            self.session.commitConfiguration()
            self.isConfiguring = false

            if self.stopRequestedDuringConfig || self.isStopped {
                self.stopRequestedDuringConfig = false
                if self.session.isRunning { self.session.stopRunning() }
                return
            }
            self.session.startRunning()
        }
    }
}
