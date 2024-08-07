import Extensions
import SwiftUI

public struct ScanTextFieldView: View {
    let title: LocalizedStringKey
    @State private var scannedText: String = ""
    @Binding var text: String

    public init(title: LocalizedStringKey, text: Binding<String>) {
        self.title = title
        _text = text
    }

    public var body: some View {
        HStack {
            TextField(title, text: $text, axis: .vertical)
            Spacer()
            ScanTextButton(text: $scannedText)
        }
        .onChange(of: scannedText) { _, newValue in
            if !newValue.isEmpty {
                text = newValue.formatStringEveryWordCapitalized()
            }
        }
    }
}
