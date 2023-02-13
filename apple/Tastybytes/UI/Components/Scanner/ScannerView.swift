import AVFoundation
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
  var isTorchOn: Bool
  var completion: (Result<Barcode, ScanError>) -> Void
  let scanTypes: [AVMetadataObject.ObjectType]

  init(
    isTorchOn: Bool = false,
    scanTypes: [AVMetadataObject.ObjectType],
    completion: @escaping (Result<Barcode, ScanError>) -> Void
  ) {
    self.isTorchOn = isTorchOn
    self.completion = completion
    self.scanTypes = scanTypes
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
