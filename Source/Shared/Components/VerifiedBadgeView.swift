import SwiftUI

struct VerifiedBadgeView: View {
    var body: some View {
        Label("label.isVerified", systemImage: "checkmark.seal")
            .labelStyle(.iconOnly)
            .foregroundColor(.green)
    }
}
