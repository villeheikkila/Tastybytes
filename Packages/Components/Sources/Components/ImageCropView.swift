
internal import BrightroomEngine
internal import BrightroomUI
import SwiftUI
import UIKit

public struct ImageCropView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var editingStack: EditingStack

    let initialmage: UIImage
    let onSubmit: (_ image: UIImage?) -> Void

    public init(image: UIImage, onSubmit: @escaping (_ image: UIImage?) -> Void) {
        _editingStack = .init(wrappedValue: .init(imageProvider: .init(image: image)))
        initialmage = image
        self.onSubmit = onSubmit
    }

    public var body: some View {
        SwiftUIPhotosCropView(editingStack: editingStack, onDone: {
            let image = try? editingStack.makeRenderer().render().uiImage
            onSubmit(image)
            dismiss()
        }, onCancel: {
            onSubmit(initialmage)
            dismiss()
        })
        .ignoresSafeArea(.all)
        .onAppear {
            editingStack.start()
        }
    }
}
