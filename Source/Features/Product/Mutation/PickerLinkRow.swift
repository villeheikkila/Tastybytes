import SwiftUI

struct PickerLinkRow: View {
    @Binding var shownSheet: Sheet?
    let label: String
    let selection: String?
    let sheet: Sheet

    var body: some View {
        Button(action: {
            shownSheet = sheet
        }, label: {
            LabeledContent(label) {
                if let selection {
                    Text(selection)
                        .foregroundColor(.secondary)
                }
            }
        })
    }
}
