import SwiftUI

public struct LabeledTextFieldView: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey?
    @Binding var text: String

    public init(title: LocalizedStringKey, placeholder: LocalizedStringKey? = nil, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        _text = text
    }

    public var body: some View {
        LabeledContent(title) {
            TextField(placeholder ?? "", text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }.foregroundColor(.primary)
    }
}
