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

extension LegacyPhotoPicker {
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
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
