import SwiftUI

public struct LabeledTextField: View {
    let title: String
    let placeholder: String?
    @Binding var text: String

    public init(title: String, placeholder: String? = nil, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        _text = text
    }

    public var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            TextField(placeholder ?? "", text: $text)
                .multilineTextAlignment(.trailing)
        }
    }
}