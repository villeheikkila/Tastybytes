import SwiftUI

public struct ScanTextField: View {
    let title: String
    @Binding var text: String

    public init(title: String, text: Binding<String>) {
        self.title = title
        _text = text
    }

    public var body: some View {
        HStack {
            TextField(title, text: $text, axis: .vertical)
            Spacer()
            ScanTextButton(text: $text)
        }
    }
}
