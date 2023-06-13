import SwiftUI

struct ScanTextButton: View {
    private let responder: ScanTextResponder

    init(text: Binding<String>) {
        responder = ScanTextResponder(title: text)
    }

    var body: some View {
        if responder.canCaptureTextFromCamera {
            Button {
                responder.captureTextFromCamera(nil)
                let backup = responder.title
                responder.title = ""
                responder.title = backup
            } label: {
                Label("Scan Text From Image", systemSymbol: .textViewfinder)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

extension ScanTextButton {
    struct UIScanTextButton: UIViewRepresentable {
        let coordinator: ScanTextResponder

        func makeCoordinator() -> ScanTextResponder {
            coordinator
        }

        func makeUIView(context: Context) -> UIButton {
            UIButton(primaryAction: .captureTextFromCamera(responder: context.coordinator, identifier: nil))
        }

        func updateUIView(_: UIViewType, context _: Context) {}
    }

    class ScanTextResponder: UIResponder, UIKeyInput {
        @Binding var title: String

        init(title: Binding<String>) {
            _title = title
        }

        var canCaptureTextFromCamera: Bool {
            canPerformAction(#selector(captureTextFromCamera(_:)), withSender: self)
        }

        var hasText = false

        func insertText(_ text: String) {
            title = text
        }

        func deleteBackward() {}
    }
}
