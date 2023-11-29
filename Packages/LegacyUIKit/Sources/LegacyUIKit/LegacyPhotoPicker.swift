import PhotosUI
import SwiftUI

public struct LegacyPhotoPicker: UIViewControllerRepresentable {
    let onSelection: (_ image: UIImage, _ metadata: ImageMetadata) -> Void

    public init(onSelection: @escaping (_ image: UIImage, _ metadata: ImageMetadata) -> Void) {
        self.onSelection = onSelection
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
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
        let onSelection: (_ image: UIImage, _ metadata: ImageMetadata) -> Void

        public init(
            _ parent: LegacyPhotoPicker,
            onSelection: @escaping (_ image: UIImage, _ metadata: ImageMetadata) -> Void
        ) {
            self.parent = parent
            self.onSelection = onSelection
        }

        func getMetadataFromAssetIdentifier(assetIdentifier: String?) -> ImageMetadata {
            if let assetId = assetIdentifier {
                let assetResults = PHAsset.fetchAssets(
                    withLocalIdentifiers: [assetId],
                    options: nil
                )
                return .init(
                    location: assetResults.firstObject?.location?.coordinate,
                    date: assetResults.firstObject?.creationDate
                )
            }
            return .init()
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let image = results.first else { return }

            let metadata = getMetadataFromAssetIdentifier(assetIdentifier: image.assetIdentifier)

            let provider = image.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    guard let image = image as? UIImage else { return }
                    self.onSelection(image, metadata)
                }
            }
        }
    }
}

public struct ImageMetadata {
    public let location: CLLocationCoordinate2D?
    public let date: Date?

    public init(location: CLLocationCoordinate2D?, date: Date?) {
        self.location = location
        self.date = date
    }

    public init() {
        location = nil
        date = nil
    }
}
