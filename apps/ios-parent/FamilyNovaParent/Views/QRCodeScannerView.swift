//
//  QRCodeScannerView.swift
//  FamilyNovaParent
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
    let onCodeScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanner = QRCodeScanner()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                QRCodeScannerPreview(scanner: scanner)
                    .ignoresSafeArea()
                
                // Overlay
                VStack {
                    Spacer()
                    
                    VStack(spacing: ParentAppSpacing.m) {
                        Text("Position the QR code within the frame")
                            .font(ParentAppFonts.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(ParentAppCornerRadius.medium)
                        
                        // Scanning frame
                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                            .stroke(ParentAppColors.primaryBlue, lineWidth: 3)
                            .frame(width: 250, height: 250)
                            .overlay(
                                RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                    .stroke(Color.white, lineWidth: 1)
                                    .frame(width: 250, height: 250)
                            )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                scanner.startScanning { code in
                    onCodeScanned(code)
                    dismiss()
                }
            }
            .onDisappear {
                scanner.stopScanning()
            }
        }
    }
}

class QRCodeScanner: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var captureSession: AVCaptureSession?
    var onCodeFound: ((String) -> Void)?
    
    func startScanning(onCodeFound: @escaping (String) -> Void) {
        self.onCodeFound = onCodeFound
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        let captureSession = AVCaptureSession()
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        self.captureSession = captureSession
        captureSession.startRunning()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        
        // Extract code from QR string (format: "FAMILYNOVA:XXXXXXXX" or just "XXXXXXXX")
        // Supports both 6-digit login codes and 8-character friend codes
        let code = stringValue.replacingOccurrences(of: "FAMILYNOVA:", with: "")
        if code.count == 6 || code.count == 8 {
            onCodeFound?(code)
        }
    }
}

struct QRCodeScannerPreview: UIViewControllerRepresentable {
    @ObservedObject var scanner: QRCodeScanner
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.scanner = scanner
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // Update if needed
    }
}

class ScannerViewController: UIViewController {
    var scanner: QRCodeScanner?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func setupPreview() {
        guard let session = scanner?.captureSession else { return }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
}

