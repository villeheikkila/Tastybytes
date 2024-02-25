import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct VerificationButton: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    let isVerified: Bool
    let verify: () async -> Void
    let unverify: () async -> Void

    var label: LocalizedStringKey { isVerified ? "verification.verified.label" : "verification.waitingForVerification.label" }
    var systemImage: String? { isVerified ? "checkmark.circle" : nil }
    var action: () async -> Void {
        isVerified ? unverify : verify
    }

    var body: some View {
        if profileEnvironmentModel.hasPermission(.canVerify) {
            if let systemImage {
                ProgressButton(label, systemImage: systemImage, action: { await action() })
            } else {
                ProgressButton(label, action: { await action() })
            }
        } else {
            if let systemImage {
                Label(label, systemImage: systemImage)
            } else {
                Text(label)
            }
        }
    }
}
