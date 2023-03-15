import SwiftUI

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
      guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
      onCapture(image)
    }
  }
}
