import SwiftUI

struct LabeledIdView: View {
    let id: String

    var body: some View {
        LabeledContent("labels.id", value: id)
            .textSelection(.enabled)
            .multilineTextAlignment(.trailing)
    }
}

#Preview {
    LabeledIdView(id: "")
}
