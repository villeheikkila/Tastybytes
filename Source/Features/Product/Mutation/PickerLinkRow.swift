import SwiftUI

struct PickerLinkRow: View {
    @Environment(Router.self) private var router
    let label: LocalizedStringKey
    let selection: String?
    let sheet: Sheet

    var body: some View {
        RouterLink(sheet: sheet) {
            LabeledContent(label) {
                if let selection {
                    Text(selection)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
