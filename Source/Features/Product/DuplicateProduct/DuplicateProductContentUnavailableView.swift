import SwiftUI

struct DuplicateProductContentUnavailableView: View {
    let productName: String

    private var title: LocalizedStringKey {
        "Find a duplicate of\n \(productName)"
    }

    private var description: LocalizedStringKey {
        "Your request will be reviewed and products will be combined if appropriate."
    }

    private var systemImage: String {
        "square.filled.on.square"
    }

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
    }
}
