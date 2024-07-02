import SwiftUI

struct PickerLinkRow: View {
    @Environment(Router.self) private var router
    let label: LocalizedStringKey
    let selection: String?
    let sheet: Sheet

    var body: some View {
        Button(action: {
            router.openRootSheet(sheet)
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
