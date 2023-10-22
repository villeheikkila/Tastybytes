import PhotosUI
import SwiftUI

public struct LegacyPhotoPicker: UIViewControllerRepresentable {
    let onSelection: (_ image: UIImage) -> Void

    public init(onSelection: @escaping (_ image: UIImage) -> Void) {
        self.onSelection = onSelection
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, onSelection: onSelection)
    }
}

public extension LegacyPhotoPicker {
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LegacyPhotoPicker
        let onSelection: (_ image: UIImage) -> Void

        public init(_ parent: LegacyPhotoPicker, onSelection: @escaping (_ image: UIImage) -> Void) {
            self.parent = parent
            self.onSelection = onSelection
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
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
