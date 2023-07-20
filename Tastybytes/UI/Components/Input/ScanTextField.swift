import SwiftUI

struct ScanTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        HStack {
            TextField(title, text: $text, axis: .vertical)
            Spacer()
            ScanTextButton(text: $text)
        }
    }
}
