import SwiftUI

struct PickerLinkRow: View {
    let label: LocalizedStringKey
    let selection: String?
    let sheet: Sheet

    var body: some View {
        RouterLink(open: .sheet(sheet)) {
            LabeledContent(label) {
                if let selection {
                    Text(selection)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
