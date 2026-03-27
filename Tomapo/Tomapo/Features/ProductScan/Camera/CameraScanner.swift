//
//  CameraScanner.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

// MARK: - Scan Result Model
import AVFoundation
import SwiftUI
 
// MARK: - Scan Result Model
struct ScanResult: Identifiable {
    let id = UUID()
    let value: String
    let type: String
}
 
// MARK: - Camera Permission State
enum CameraPermissionState {
    case notDetermined
    case authorized
    case denied
}
 
// MARK: - Scanner Coordinator (AVFoundation Delegate)
class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((ScanResult) -> Void)?
    private var lastScannedValue: String = ""
    private var lastScanTime: Date = .distantPast
 
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
}
 
// MARK: - Camera Preview (UIViewRepresentable)
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
 
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
 
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
 
        return view
    }
 
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}
 
// MARK: - Scanner ViewModel
@MainActor
class ScannerViewModel: ObservableObject {
    @Published var scanResult: ScanResult? = nil
    @Published var showSheet: Bool = false
    @Published var permissionState: CameraPermissionState = .notDetermined
    @Published var isTorchOn: Bool = false
 
    // nonisolated(unsafe): Diese Properties werden ausschliesslich auf der
    // sessionQueue gelesen/geschrieben – nie gleichzeitig vom MainActor.
    // Swift 6 würde sonst fälschlicherweise einen Dataracing-Fehler melden.
    nonisolated(unsafe) let session = AVCaptureSession()
    nonisolated(unsafe) private let coordinator = ScannerCoordinator()
    nonisolated(unsafe) private let sessionQueue = DispatchQueue(label: "dev.wheresmytomato.sessionQueue")
    // Läuft gerade ein beginConfiguration/commitConfiguration Block?
    nonisolated(unsafe) private var isConfiguring = false
    // Wurde stopScanning() irgendwann während setupSession() aufgerufen?
    nonisolated(unsafe) private var stopRequestedDuringConfig = false
    // Wurde stopScanning() aufgerufen? Verhindert startRunning() nach commitConfiguration
    nonisolated(unsafe) private var isStopped = false
 
    init() {
        coordinator.onCodeScanned = { [weak self] result in
            guard let self else { return }
            self.scanResult = result
            self.showSheet = true
            self.pauseScanning()
        }
    }
 
    // MARK: Permission prüfen und Session starten
    func startScanning() {
        // Flag zurücksetzen damit setupSession() wieder startRunning() aufrufen darf
        sessionQueue.async { [weak self] in
            self?.isStopped = false
        }
        Task {
            await checkPermissionAndSetup()
        }
    }
 
    func stopScanning() {
        setTorch(on: false)
 
        // sync statt async: Der aufrufende Thread (Main) wartet bis die
        // Session vollständig gestoppt ist bevor die View abgebaut wird.
        // Das verhindert den AVFoundation-Assert "err=-17281" der entsteht
        // wenn Session-Ressourcen freigegeben werden während stopRunning()
        // noch nicht abgeschlossen ist.
        //
        // sessionQueue.sync vom MainThread ist sicher weil die sessionQueue
        // niemals zurück auf den MainThread synct – kein Deadlock-Risiko.
        sessionQueue.sync { [weak self] in
            guard let self else { return }
 
            self.isStopped = true
 
            if self.isConfiguring {
                self.stopRequestedDuringConfig = true
                return
            }
 
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
 
    // MARK: Scanning pausieren (Delegate entfernen – Kamera-Feed bleibt sichtbar)
    func pauseScanning() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard let output = self.session.outputs.first as? AVCaptureMetadataOutput else { return }
            output.setMetadataObjectsDelegate(nil, queue: DispatchQueue.main)
        }
    }
 
    // MARK: Scanning fortsetzen (Delegate wieder setzen)
    func resumeScanning() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard let output = self.session.outputs.first as? AVCaptureMetadataOutput else { return }
            output.setMetadataObjectsDelegate(self.coordinator, queue: DispatchQueue.main)
        }
    }
 
    func toggleTorch() {
        isTorchOn.toggle()
        setTorch(on: isTorchOn)
    }
 
    private func setTorch(on: Bool) {
        sessionQueue.async {
            guard let device = AVCaptureDevice.default(for: .video),
                  device.hasTorch,
                  device.isTorchAvailable else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch konnte nicht umgeschaltet werden: \(error)")
            }
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
                self.stopRequestedDuringConfig = false
                return
            }
 
            self.isConfiguring = true
            self.session.beginConfiguration()
 
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }
 
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                self.isConfiguring = false
                return
            }
            self.session.addInput(input)
 
            let output = AVCaptureMetadataOutput()
            guard self.session.canAddOutput(output) else {
                self.session.commitConfiguration()
                self.isConfiguring = false
                return
            }
            self.session.addOutput(output)
 
            output.setMetadataObjectsDelegate(self.coordinator, queue: DispatchQueue.main)
            output.metadataObjectTypes = [
                .qr, .ean8, .ean13, .pdf417, .upce,
                .code39, .code93, .code128, .aztec,
                .dataMatrix, .interleaved2of5, .itf14
            ]
 
            self.session.commitConfiguration()
            self.isConfiguring = false
 
            // Doppelte Absicherung: stopScanning() könnte während der Konfiguration
            // ODER direkt danach aufgerufen worden sein – in beiden Fällen nicht starten
            if self.stopRequestedDuringConfig || self.isStopped {
                self.stopRequestedDuringConfig = false
                if self.session.isRunning {
                    self.session.stopRunning()
                }
                return
            }
 
            self.session.startRunning()
        }
    }
}
