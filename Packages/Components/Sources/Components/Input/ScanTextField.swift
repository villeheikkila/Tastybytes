import Extensions
import SwiftUI

public struct ScanTextField: View {
    let title: String
    @State var scannedText: String = ""

    @Binding var text: String

    public init(title: String, text: Binding<String>) {
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
