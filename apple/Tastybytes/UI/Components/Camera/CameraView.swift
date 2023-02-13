import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIImagePickerController
  let onClose: () -> Void
  let onCapture: (_ image: UIImage) -> Void

  func makeUIViewController(context: Context) -> UIViewControllerType {
    let viewController = UIViewControllerType()
    viewController.delegate = context.coordinator
    viewController.sourceType = .camera
    return viewController
  }

  func updateUIViewController(_: UIViewControllerType, context _: Context) {}

  func makeCoordinator() -> CameraView.Coordinator {
    Coordinator(self, onClose: onClose, onCapture: onCapture)
  }
}
