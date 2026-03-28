import SwiftUI
@preconcurrency import AVFoundation

// MARK: - ScannerView

/// The main scanner tab view — full-screen camera preview with a Pokedex HUD overlay,
/// a capture button, and a species picker sheet after photo capture.
struct ScannerView: View {

    @State private var viewModel: ScannerViewModel = {
        let catchService = CatchService(modelContainer: try! .init(for: CatchRecord.self, DiscoveryState.self))
        let locationService = LocationService()
        let iNatService = INaturalistService()
        let idService = FishIdentificationService(iNatService: iNatService)
        return ScannerViewModel(
            catchService: catchService,
            locationService: locationService,
            identificationService: idService
        )
    }()

    @State private var discoveredFishIds: Set<Int> = []

    // MARK: - Camera State

    @State private var cameraSession = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    @State private var isCameraConfigured: Bool = false
    @StateObject private var photoCaptureDelegate = PhotoCaptureDelegate()

    // MARK: - Body

    var body: some View {
        ZStack {
            // Full-screen camera preview
            CameraPreviewView(session: cameraSession)
                .ignoresSafeArea()

            // Pokedex HUD overlay
            ScannerHUDView(
                currentLocation: viewModel.currentLocation,
                isScanning: viewModel.isScanning
            )
            .ignoresSafeArea()

            // Bottom capture button (only when scanning)
            if viewModel.isScanning {
                VStack {
                    Spacer()

                    ScannerCaptureButton(isActive: viewModel.isScanning) {
                        capturePhoto()
                    }
                    .padding(.bottom, 40)
                }
            }

            // Auto-identification result overlay
            if viewModel.identificationState != .idle {
                ScannerResultView(viewModel: viewModel) {
                    viewModel.cancelCapture()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.identificationState)
        .sheet(isPresented: $viewModel.showSpeciesPicker) {
            FishSpeciesPickerView(
                discoveredFishIds: discoveredFishIds,
                onSelect: { fishId in
                    Task {
                        await viewModel.confirmCatch(fishId: fishId)
                    }
                },
                onCancel: {
                    viewModel.cancelCapture()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.startScanning()
            configureCamera()
        }
        .onDisappear {
            stopCamera()
        }
        .onChange(of: photoCaptureDelegate.capturedImage) { _, image in
            guard let image else { return }
            Task {
                await viewModel.capturePhoto(image)
            }
        }
    }

    // MARK: - Camera Configuration

    private func configureCamera() {
        guard !isCameraConfigured else { return }

        cameraSession.beginConfiguration()
        cameraSession.sessionPreset = .photo

        // Add video input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              cameraSession.canAddInput(input) else {
            cameraSession.commitConfiguration()
            return
        }
        cameraSession.addInput(input)

        // Add photo output
        guard cameraSession.canAddOutput(photoOutput) else {
            cameraSession.commitConfiguration()
            return
        }
        cameraSession.addOutput(photoOutput)
        photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)

        cameraSession.commitConfiguration()
        isCameraConfigured = true

        // Start on a background thread
        let session = cameraSession
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func stopCamera() {
        let session = cameraSession
        DispatchQueue.global(qos: .userInitiated).async {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    private func capturePhoto() {
        guard isCameraConfigured else { return }

        let settings = AVCapturePhotoSettings()
        settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)

        HapticsService.scanPulse()
    }
}

// MARK: - CameraPreviewView (UIViewRepresentable)

/// Wraps `AVCaptureVideoPreviewLayer` in a UIKit view for use in SwiftUI.
struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.previewLayer.session = session
    }
}

/// UIKit backing view that hosts the camera preview layer.
final class CameraPreviewUIView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

// MARK: - PhotoCaptureDelegate

/// Handles the `AVCapturePhotoCaptureDelegate` callback and publishes the captured image.
@MainActor
final class PhotoCaptureDelegate: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    @Published var capturedImage: UIImage?

    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        let capturedImg = image
        Task { @MainActor [weak self] in
            self?.capturedImage = capturedImg
        }
    }
}

// MARK: - Preview

#Preview("Scanner View") {
    ScannerView()
}
