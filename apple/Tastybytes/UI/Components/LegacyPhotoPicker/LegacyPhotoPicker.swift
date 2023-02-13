import PhotosUI
import SwiftUI

// TODO: Drop this when SwiftUI PhotoPicker supports being nested under a menu 19.11.2022
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
