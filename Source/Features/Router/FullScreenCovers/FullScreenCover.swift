import Components
import SwiftUI

@MainActor
enum FullScreenCover: Identifiable, Equatable {
    case camera(selectedImage: Binding<UIImage?>)
    case cameraWithCropping(onSubmit: (UIImage?) -> Void)
    case cropImage(image: UIImage, onSubmit: (UIImage?) -> Void)

    @ViewBuilder
    var view: some View {
        switch self {
        case let .camera(selectedImage):
            CameraPickerView(selectedImage: selectedImage)
        case let .cameraWithCropping(onSubmit):
            CameraWithCroppingView(onSubmit: onSubmit)
        case let .cropImage(image, onSubmit):
            ImageCropView(image: image, onSubmit: onSubmit)
        }
    }

    nonisolated var id: String {
        switch self {
        case .camera:
            "camera"
        case .cameraWithCropping:
            "cameraWithCropping"
        case let .cropImage(image, _):
            "crop_image_\(image.hashValue)"
        }
    }

    nonisolated static func == (lhs: FullScreenCover, rhs: FullScreenCover) -> Bool {
        lhs.id == rhs.id
    }
}
