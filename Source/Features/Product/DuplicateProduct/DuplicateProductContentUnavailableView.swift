import SwiftUI

@MainActor
struct DuplicateProductContentUnavailableView: View {
    let productName: String

    private var title: String {
        "Find a duplicate of\n \(productName)"
    }

    private var description: String {
        "Your request will be reviewed and products will be combined if appropriate."
    }

    private var systemImage: String {
        "square.filled.on.square"
    }

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
    }
}
