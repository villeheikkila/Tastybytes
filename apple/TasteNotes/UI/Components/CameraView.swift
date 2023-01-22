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

extension CameraView {
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: CameraView
    let onClose: () -> Void
    let onCapture: (_ image: UIImage) -> Void

    init(_ parent: CameraView, onClose: @escaping () -> Void, onCapture: @escaping (_ image: UIImage) -> Void) {
      self.parent = parent
      self.onClose = onClose
      self.onCapture = onCapture
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
      onClose()
    }

    func imagePickerController(
      _: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        onCapture(image)
      }
    }
  }
}
