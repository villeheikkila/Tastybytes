import AVFoundation
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    let completion: (Result<Barcode, ScanError>) -> Void
    let scanTypes: [AVMetadataObject.ObjectType]
    let isTorchOn: Bool

    init(
        scanTypes: [AVMetadataObject.ObjectType],
        completion: @escaping (Result<Barcode, ScanError>) -> Void,
        isTorchOn: Bool = false
    ) {
        self.completion = completion
        self.scanTypes = scanTypes
        self.isTorchOn = isTorchOn
    }

    func makeUIViewController(context _: Context) -> Controller {
        Controller(parentView: self)
    }

    func updateUIViewController(_ uiViewController: Controller, context _: Context) {
        uiViewController.parentView = self
        uiViewController.updateViewController(
            isTorchOn: isTorchOn
        )
    }
}

extension ScannerView {
    enum ScanError: Error {
        case badInput
        case badOutput
        case initError(_ error: Error)
        case permissionDenied
    }

    final class Controller: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        AVCaptureMetadataOutputObjectsDelegate
    {
        var parentView: ScannerView?
        var didFinishScanning = false
        var lastTime = Date(timeIntervalSince1970: 0)
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?

        init(parentView: ScannerView) {
            self.parentView = parentView
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            addOrientationDidChangeObserver()
            setBackgroundColor()
            handleCameraPermission()
        }

        override func viewWillLayoutSubviews() {
            previewLayer?.frame = view.layer.bounds
        }

        @objc
        func updateOrientation() {
            guard let orientation = view.window?.windowScene?.interfaceOrientation else { return }
            guard let connection = captureSession?.connections.last, connection.isVideoOrientationSupported else { return }
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateOrientation()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupSession()
        }

        private func setupSession() {
            guard let captureSession else {
                return
            }

            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            }

            guard let previewLayer else { return }

            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            reset()

            if captureSession.isRunning == false {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.startRunning()
                }
            }
        }

        private func handleCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .restricted:
                break
            case .denied:
                didFail(reason: .permissionDenied)
            case .notDetermined:
                requestCameraAccess {
                    self.setupCaptureDevice()
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            case .authorized:
                setupCaptureDevice()
                setupSession()

            default:
                break
            }
        }

        private func requestCameraAccess(completion: (() -> Void)?) {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                guard status else {
                    self?.didFail(reason: .permissionDenied)
                    return
                }
                completion?()
            }
        }

        private func addOrientationDidChangeObserver() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateOrientation),
                name: AVFoundation.Notification.Name("UIDeviceOrientationDidChangeNotification"),
                object: nil
            )
        }

        private func setBackgroundColor(_ color: UIColor = .black) {
            view.backgroundColor = color
        }

        private func setupCaptureDevice() {
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                return
            }

            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                didFail(reason: .initError(error))
                return
            }

            guard let captureSession else { return }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                didFail(reason: .badInput)
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                guard let parentView else { return }
                metadataOutput.metadataObjectTypes = parentView.scanTypes
            } else {
                didFail(reason: .badOutput)
                return
            }
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            if captureSession?.isRunning == true {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.stopRunning()
                }
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        override var prefersStatusBarHidden: Bool {
            true
        }

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            .all
        }

        override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
            guard touches.first?.view == view,
                  let touchPoint = touches.first,
                  let device = AVCaptureDevice.default(for: .video),
                  device.isFocusPointOfInterestSupported
            else { return }

            let videoView = view
            guard let videoView else { return }
            let screenSize = videoView.bounds.size
            let xPoint = touchPoint.location(in: videoView).y / screenSize.height
            let yPoint = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
            let focusPoint = CGPoint(x: xPoint, y: yPoint)

            do {
                try device.lockForConfiguration()
            } catch {
                return
            }

            device.focusPointOfInterest = focusPoint
            device.focusMode = .continuousAutoFocus
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.unlockForConfiguration()
        }

        func updateViewController(isTorchOn: Bool) {
            if let backCamera = AVCaptureDevice.default(for: AVMediaType.video),
               backCamera.hasTorch
            {
                try? backCamera.lockForConfiguration()
                backCamera.torchMode = isTorchOn ? .on : .off
                backCamera.unlockForConfiguration()
            }
        }

        func reset() {
            didFinishScanning = false
            lastTime = Date(timeIntervalSince1970: 0)
        }

        func metadataOutput(
            _: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from _: AVCaptureConnection
        ) {
            guard let metadataObject = metadataObjects.first else { return }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            guard didFinishScanning == false else { return }
            let result = Barcode(barcode: stringValue, type: readableObject.type)
            found(result)
            didFinishScanning = true
        }

        func isPastScanInterval() -> Bool {
            Date().timeIntervalSince(lastTime) >= 2.0
        }

        func isWithinManualCaptureInterval() -> Bool {
            Date().timeIntervalSince(lastTime) <= 0.5
        }

        func found(_ result: Barcode) {
            lastTime = Date()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            guard let parentView else { return }
            parentView.completion(.success(result))
        }

        func didFail(reason: ScanError) {
            guard let parentView else { return }
            parentView.completion(.failure(reason))
        }
    }
}
