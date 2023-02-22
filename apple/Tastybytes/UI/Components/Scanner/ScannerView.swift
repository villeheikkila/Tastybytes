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
