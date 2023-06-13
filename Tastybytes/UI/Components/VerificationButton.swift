import SFSafeSymbols
import SwiftUI

struct VerificationButton: View {
    @Environment(ProfileManager.self) private var profileManager
    let isVerified: Bool
    let verify: () async -> Void
    let unverify: () async -> Void

    var label: String { isVerified ? "Verified" : "Not Verified Yet" }
    var systemSymbol: SFSymbol { isVerified ? .checkmarkCircle : .xCircle }
    var action: () async -> Void {
        isVerified ? unverify : verify
    }

    var body: some View {
        if profileManager.hasPermission(.canVerify) {
            ProgressButton(label, systemSymbol: systemSymbol, action: { await action() })
        } else {
            Label(label, systemSymbol: systemSymbol)
        }
    }
}
