import PhotosUI
import SwiftUI

extension LegacyPhotoPicker {
  class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: LegacyPhotoPicker
    let onSelection: (_ image: UIImage) -> Void

    init(_ parent: LegacyPhotoPicker, onSelection: @escaping (_ image: UIImage) -> Void) {
      self.parent = parent
      self.onSelection = onSelection
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      picker.dismiss(animated: true)

      guard let provider = results.first?.itemProvider else { return }

      if provider.canLoadObject(ofClass: UIImage.self) {
        provider.loadObject(ofClass: UIImage.self) { image, _ in
          guard let image = image as? UIImage else { return }
          self.onSelection(image)
        }
      }
    }
  }
}
