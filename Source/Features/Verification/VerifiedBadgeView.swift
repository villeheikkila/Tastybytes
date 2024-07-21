import Models
import SwiftUI

struct VerifiedBadgeView: View {
    @Environment(\.verificationBadgeVisibility) private var verificationBadgeVisibility
    let verifiable: Verifiable

    var body: some View {
        if verificationBadgeVisibility == .visible, verifiable.isVerified {
            Label("label.isVerified", systemImage: "checkmark.seal")
                .labelStyle(.iconOnly)
                .foregroundColor(.green)
        }
    }
}

public enum VerificationBadgeVisibility: Sendable {
    case hidden, visible
}

public extension EnvironmentValues {
    @Entry var verificationBadgeVisibility: VerificationBadgeVisibility = .hidden
}

public extension View {
    func verificationBadgeVisibility(_ visibility: VerificationBadgeVisibility) -> some View {
        environment(\.verificationBadgeVisibility, visibility)
    }
}
