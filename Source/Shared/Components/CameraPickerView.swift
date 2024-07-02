import Components
import SwiftUI
import UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let picker: CameraPickerView

        init(picker: CameraPickerView) {
            self.picker = picker
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            picker.selectedImage = selectedImage
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }
}

struct CameraWithCroppingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?

    let onSubmit: (UIImage?) -> Void

    var body: some View {
        Group {
            if let selectedImage {
                ImageCropView(image: selectedImage, onSubmit: onSubmit)
            } else {
                CameraPickerView(selectedImage: $selectedImage)
            }
        }.background(.black)
    }
}
