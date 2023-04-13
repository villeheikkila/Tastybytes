import SwiftUI

struct VerificationButton: View {
  @EnvironmentObject private var profileManager: ProfileManager
  let isVerified: Bool
  let verify: () async -> Void
  let unverify: () async -> Void

  var label: String { isVerified ? "Verified" : "Not Verified Yet" }
  var systemImage: String { isVerified ? "checkmark.circle" : "x.circle" }
  var action: () async -> Void {
    isVerified ? unverify : verify
  }

  var body: some View {
    if profileManager.hasPermission(.canVerify) {
      ProgressButton(label, systemImage: systemImage, action: { await action() })
    } else {
      Label(label, systemImage: systemImage)
    }
  }
}
