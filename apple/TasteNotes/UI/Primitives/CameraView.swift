import Foundation
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

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }

    func makeCoordinator() -> CameraView.Coordinator {
        return Coordinator(self, onClose: onClose, onCapture: onCapture)
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

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onClose()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                onCapture(image)
            }
        }
    }
}
