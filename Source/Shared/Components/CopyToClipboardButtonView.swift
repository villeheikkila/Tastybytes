import SwiftUI

struct CopyToClipboardButtonView: View {
    let content: String

    var body: some View {
        Button("labels.copyToClipboard", systemImage: "doc.on.doc") {
            UIPasteboard.general.string = content
        }
    }
}
