import PhotosUI
import SwiftUI

struct LegacyPhotoPicker: UIViewControllerRepresentable {
  let onSelection: (_ image: UIImage) -> Void

  func makeUIViewController(context: Context) -> PHPickerViewController {
    var config = PHPickerConfiguration()
    config.filter = .images
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_: PHPickerViewController, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self, onSelection: onSelection)
  }
}
